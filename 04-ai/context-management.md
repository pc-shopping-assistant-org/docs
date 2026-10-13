# State, execution và recovery

Thiết kế V1; root/readiness và canonical-state migration là target extensions.
Hiện trạng/evidence: [status](stateful-implementation-status.md).
DB: [schema](../03-data/ai-stateful-schema.md). Transport: [HTTP/SSE](../05-api/stateful-chat-v1.md).

## Sources of truth

| Dữ liệu | Authority |
| --- | --- |
| Owner, run/request, revision, accepted ref, execution slot, attempts | Application PostgreSQL |
| Published history | conversation_messages |
| Requirements và public build | Exact accepted native checkpoint |
| Working state, next/tasks, pending writes, lineage | LangGraph saver |
| Tool outcomes/evidence | Checkpointed tool_results |
| Model transcript, public DTO, SSE journal | Projections, không writable state riêng |

V1 không memory xuyên conversation. RAM history của legacy chat không phải durable memory.

## Canonical-state migration and task authority — target extension

Canonical requirements và resolution/merge/compiler ở [agent spec](agent-tools.md#4-state-và-trust-boundary).

- Bump graph/schema version khi thay legacy constraints bằng canonical state.
  Legacy constraints là compiled projection; adapter ghi source schema/compiler version.
  Incompatible checkpoint phải migrate hoặc reject, không áp defaults mới.
- Application validate source-bound task draft trước ReAct: BUILD, COMPARE,
  EXPLAIN_SAVED_BUILD, ANSWER. Final model không được downgrade/xóa task.
- CLEAR/replace/pin/owned và UI confirmation phải khớp message, pending options và
  constraints revision. Source span không tự chứng minh intent.
- Pending draft là artifact chưa merge. Clarification giữ task pending và kết thúc
  execution; follow-up tạo run mới sau canonical revalidation.

## Accepted head and working checkpoints

`thread_id = str(conversation_id)` ổn định cho mọi run, recovery và debug branch.
Server resolve refs sau ownership check; client không chọn thread/namespace/checkpoint.

| Operation | Checkpoint |
| --- | --- |
| Public read / new turn | Exact accepted_checkpoint_ref |
| Resume | Exact working ref của eligible run |
| Debug/replay | Authorized branch; không publish |
| Lookup latest | Không dùng làm application head |

Run claim lưu immutable base_revision/base_checkpoint_ref.
Native new turn nhận accepted config + input + server metadata, durability=sync.
Resume dùng input=None; không begin_turn/reset hoặc copy StateSnapshot.values.

Với pinned stack, source=input checkpoint có thể còn values của run trước vì START
chưa apply input. Ownership tại boundary phải kiểm tra server metadata, START input
và direct parent; không chỉ values.run_id. Loop checkpoints phải chứa run mới.

## Managed execution

```text
POST turn → commit PENDING run → executor claim → LangGraph
GET SSE   → authorize → subscribe persisted events
```

Supervisor do composition root/lifespan quản lý, giữ bounded TaskGroup/task registry.
Durable PENDING scan/claim phục hồi lost handoff; wake signal chỉ giảm latency.
HTTP/SSE không sở hữu graph task, không dùng detached task/BackgroundTasks làm durable runner.

Executor giữ execution UUID, worker incarnation UUID và generation; heartbeat,
cancellation và errors thuộc lifecycle này. Engine/saver/provider clients chỉ đóng sau drain.

Shutdown: stop admission → signal cancel → await graph/child tasks/streams/CPU work/
checkpoint writes → stop ACK. Hết grace mà chưa drain thì không ACK.
CPU optimizer phải chạy qua bounded managed worker; thread fire-and-forget không đủ stop proof.
Current build graph và ReAct build_pc dùng `application.cpu_work.run_cpu`: công việc
thuần CPU chạy ở thread pool chuẩn asyncio, được await và drain cả khi cancel.
ManagedExecutor giới hạn run concurrency; graph/tool loop serial chỉ dispatch một
optimizer operation mỗi lượt. Không có thread ghi checkpoint hoặc publish.
Đây chưa phải process isolation: cancellation không kill computation; hết shutdown
grace mà worker còn chạy thì giữ resources/slot và không stop ACK.
POST/SSE disconnect không cancel; explicit cancel ghi cancel_requested và signal executor.

## Durable call budget

Mỗi actual MODEL/TOOL_IO outbound attempt:

1. Transaction lock run, kiểm tra ownership, cancel/deadline/cap; insert RESERVED và commit.
2. Claimant dispatch reservation mới đúng một lần. Không commit → không outbound.
3. Ghi SUCCEEDED/FAILED và usage/provider ref nếu biết.
4. RESERVED còn lại sau crash thành UNKNOWN; vẫn consumed, không dispatch lại/refund.
   Retry reserve attempt mới.

Extraction/agent/explain/repair, SDK retries, backend fallback/revalidation/fan-out
đều tính từng request, không một slot cho toàn handler.
SDK retry phải disable hoặc instrument cùng boundary.
Logical tool invocation count tách actual TOOL_IO attempts.

Ledger fields/keys: [agent_call_attempts](../03-data/ai-stateful-schema.md).
Không duplicate tool outcome/evidence trong attempt table.
Checkpoint counters chỉ projection; SUCCEEDED attempt không chứng minh node checkpoint đã commit.

Limits/deadline snapshot vào run, không reset khi reconnect/restart/generation đổi.
Guarantee chỉ là dispatched-attempt cap nếu tất cả adapters đi qua boundary;
không exactly-once provider execution, hard billing cap hoặc total-token guarantee.
Timeout/cancel vẫn có thể bị provider tính tiền; UNKNOWN không có nghĩa cost=0.

## Native checkpoint and finalization protocol

### Admission và stop evidence

Một execution/conversation, kể cả initialization, resume và debug.
Run status hoặc lease timeout **không nhường thread**; fencing application không chặn saver.put.

First-ever execution dùng atomic initial claim. Các execution sau cần verified stop
evidence của owner gần nhất, rồi CAS generation mới; auth/revision/eligibility vẫn phải pass.

| Evidence | Proof bắt buộc |
| --- | --- |
| EXECUTOR_STOP_ACK | Owning executor đã join graph/children, đóng streams, drain checkpoint-write futures |
| PROCESS_TERMINATED | Trusted supervisor/operator xác nhận đúng process incarnation đã exit; saver transactions/sessions settle |

Evidence gồm kind, execution_id, worker_instance_id, generation, stopped_at UTC,
checkpoint_writes_drained=true và trusted proof ref. Client không được tạo proof.
PID, CancelledError, heartbeat mất, network timeout, Redis/advisory lock mất không đủ.
Sai/stale generation hoặc chưa drain → busy; không takeover theo TTL.
Chưa có termination-proof adapter thì hard-crash recovery fail closed/operator-confirmed.

### Run và failure semantics

```text
PENDING → RUNNING → COMPLETED / WAITING_INPUT / FAILED_RETRYABLE / FAILED_TERMINAL / CANCELLED
FAILED_RETRYABLE → RECOVERING → RUNNING
RUNNING + verified process stop → RECOVERING → RUNNING
```

| Outcome | Resume |
| --- | --- |
| FAILED_RETRYABLE | Allowlisted transient timeout/429/5xx/interruption; đủ stop proof, budgets, refs/versions, base chưa đổi |
| FAILED_TERMINAL | Không; permanent/invalid lineage/corrupt state/incompatible version/budget hết |
| COMPLETED / WAITING_INPUT / CANCELLED | Không; follow-up tạo run mới |
| INFEASIBLE | Domain result của completed optimization, không technical failure |

Unexpected bug mặc định terminal và ghi issue.
Với execution đã claim, cancel request chưa là CANCELLED cho tới verified stop/drain.
P5 public cancel persists cancel_requested before local signal. A PENDING run with
no execution identity may be cancelled under the exclusive claim lock without ACK;
it never started. Claimed runs retain the slot until stop/drain ACK. Missed local
signal is handled by owning heartbeat; no worker takeover follows from cancellation.
Cancellation observed at locked finalize suppresses publish and completes CANCELLED
only after the executor's validated stop evidence. Terminal repeat is a no-op.
Retryable run muốn nhường conversation phải resume xong hoặc controlled cancel/discard.
Không revive cancelled/terminal hoặc run có base đã bị accepted revision mới thay thế.

Resume giữ run_id/request hash/base, CAS tăng attempt/generation sau stop evidence.
retry_policy_version/max_attempts/attempt_count/retry_deadline ghi lúc claim.
Request retry chỉ đọc status/saved result; không tự tạo execution.
Không có working checkpoint chỉ retry stored initial input bằng native path đã verify.
Stage FAILED khác run failure classification; failed run không publish success/head.

Internal native adapter đã có `resume`: kiểm tra exact source metadata, bound stop
identity, same run/base/input/version và generation kế tiếp; gọi native stream với
`None`, giữ pending work thay vì seed values/new input. Terminal/interrupt source
không dùng đường retry này. PostgreSQL reopen test bỏ qua orphan mới hơn và không
chạy lại node đã commit. Coordinator phải xác thực proof, CAS claim/budgets và
authorize exact old-lineage boundary trước khi gọi.

SQL recovery claim có `max_attempts` opt-in 2–3; selected V2 dùng 2, V1 dùng 1.
V2 scanner chỉ retry failed run đã có stored executor ACK. Retryable đã drain giữ active slot; claim chỉ dùng owning
executor ACK đã lưu, không nhận proof từ HTTP. Claim khóa/recheck base, status,
deadline, cancel, attempts và exact native source; generation/attempt tăng, call
budget không reset. Array `authorized_recovery_source_refs` lưu exact ref + previous
execution + stored ACK + graph version. Lineage chỉ chuyển sang generation trước
tại đúng ref đó. Factory reuse catalog/publication context từ exact source, không
refetch/seed execution values. Actual lifespan/HTTP/executor SDK-timeout→resume→publish
pass với model/catalog/auth fixtures. Process-death reconciliation chưa enabled.
Retry thứ ba chưa được đóng gate; không tự mở rộng policy.

Stopped-retry cleanup chạy trước claim scan, có giới hạn batch và conversation/run
locks. FAILED_RETRYABLE hết deadline/attempts hoặc có cancel chỉ chuyển terminal/
cancelled và release slot khi stored owning ACK khớp generation đã drain. Không
sửa accepted head/revision, không thêm assistant message. RUNNING, missing/stale
proof vẫn busy. PostgreSQL gates xác minh cleanup và fresh submit; lease/deadline
không bao giờ được coi là stop evidence.

### Idempotency và finalize

Unique (conversation_id, request_id) + payload hash.
Cùng key/body trả cùng run/result trước revision check; khác body reject.
Không giữ row lock trong lúc LLM/backend/optimizer chạy.

Implemented internal main path: `PostgresRunCoordinator` admits/claims work;
`ConversationExecution` starts from exact accepted head, records each emitted
committed working ref, then stages terminal ref. Working-ref recording checks
thread/root/ref/run/execution/generation/base/input/graph version under current
claim; it is not publication, stop proof or recovery authorization. A missed DB
record after saver commit is reconciled only after verified stored stop ACK:
bounded native enumeration (256), exact execution/input/version filter, shared
ancestry validator and one unique tip. Missing/stale cursor is repaired in the
recovery-claim transaction; other-run orphan cannot become source. Same-execution
forks reject without generation/head changes. No copy of execution values.
managed executor stop ACK authorizes atomic history/head/revision publication.
Native PostgreSQL test covers two optimizer turns and ordinary model failure.
Production HTTP/lifespan wiring has an opt-in V2 gate with model/catalog/auth fixtures;
live-provider acceptance and managed resume remain pending. Current admission defaults:
12 model attempts, 16 tool-I/O attempts, 5-minute deadline, 30-second renewable
lease; these are provisional operational limits, not a provider billing cap.
No automatic retry or lease-only takeover is enabled.

Saver transaction và application transaction không atomic với nhau:

1. Application commit request/user message một lần, base ref/revision và durable run.
2. Executor chạy ngoài transaction dài; saver commit working checkpoints.
3. Executor drain; validator kiểm tra candidate terminal ref/lineage/public payload.
4. Fenced application transaction CAS accepted head/revision, assistant message,
   final_checkpoint_ref và run outcome cùng lúc.
5. Emit COMPLETED sau commit; release thread chỉ với verified stop evidence.

Publish-lineage gate:

- run.kind=CHAT; đúng owner/conversation/thread/root namespace.
- Exact runner terminal ref hoặc exact coordinator-authorized recovery_source_ref,
  không latest. Context do server stamp: run/request/input hash, base revision/ref,
  execution UUID, worker incarnation, generation, graph/schema/policy versions.
- Walk native parents tới đúng input/resume boundary và claimed base.
  Sau base chỉ có authorized attempts của run; sibling/debug/orphan/missing ancestor reject.
- Candidate thuộc current generation hoặc exact stopped recovery source được CAS authorize.
  Không accept mọi checkpoint generation cũ.
- Terminal snapshot không còn next/tasks/interrupt/pending work. READY_TO_PUBLISH,
  current_run_id, input/payload hashes, grounding và task outcomes khớp.
- Transaction recheck lease/generation/stop proof/source và unchanged base head/revision.

Baseline base=null cần verified native first-input boundary, không mọi parent-null checkpoint.
Root target dùng validated initial root ở mục dưới.
Invalid lineage/hash giữ head, ghi lỗi; không sửa provenance/copy values để lách gate.

| Crash point | Recovery |
| --- | --- |
| Trước node checkpoint | Có thể gọi lại external work; reserve attempt mới |
| Sau tool checkpoint, trước observe | Project ToolMessage từ ledger |
| Sau optimize checkpoint, explain fail | Reuse validated optimization marker |
| Sau READY_TO_PUBLISH, trước finalize | Reconcile saved payload/ref; không rerun LLM/optimizer để tạo message |
| Sau finalize, trước SSE | Fetch/retry saved result; không tăng revision lại |

Same finalized ref/hash trả saved result; candidate khác reject.
Working ref chưa ghi application DB thì reconcile theo server metadata/native lineage,
không latest chung. Debug replay serializes cùng thread, internal-only, không publish/
auto-repeat commerce side effects. Optimizer replay dùng [immutable provenance](../03-data/ai-stateful-schema.md);
LLM rerun không bảo đảm cùng câu chữ.

## Stage completion markers and invalidation

Phase mô tả nghiệp vụ, không execution cursor của LangGraph.
optimization_status/explanation_status: NOT_STARTED / COMPLETED / FAILED.

Successful node commit status + validated result + input hash + versions cùng update.
Reuse chỉ khi COMPLETED, result hợp lệ và hashes/versions khớp; result != null không đủ.
INFEASIBLE là computation completed, không feasible build.

| Hash | Inputs |
| --- | --- |
| Optimization | Normalized requirements/units/scope, owned/pinned, catalog snapshot, compiler/engine/scoring/policy/schema |
| Explanation | Build/result, question, locale, evidence, prompt/model configuration |

Optimize input đổi: invalidate optimize/explain/publication; giữ historical build với stale label.
Chỉ explain input đổi: giữ optimize, invalidate explain/publication.
Run mới reset publication marker; old results chỉ là reuse candidates sau validation.
READY_TO_PUBLISH ghi cùng sanitized payload, hashes và current_run_id; không thay CAS authority.

## Initial accepted root — target extension

Implemented main path (0003): POST create tạo root đồng bộ; native update không chạy
LLM/tool, row lock + CAS attach exact ref, revision=0, readiness=READY. GET đọc exact
accepted state. Native create/reopen và core build hai lượt đã pass.
Internal retry now reconciles a unique server-marked native root after app rollback;
concurrent application initialization attaches one root. Native-only populated
legacy threads reject before root creation. Automatic scheduling/asynchronous
initialization and explicit legacy migration remain deferred.

```text
Create INITIALIZING → exclusive initializer → native root
                   → stop/drain → CAS accepted ref + READY
```

- Readiness: INITIALIZING / READY / DELETING, tách RunStatus.
  Stable initialization identity/provenance; internal initialization kind không giả CHAT.
- Native aupdate_state(..., as_node="initialize_root") tạo unknown canonical state,
  public_build=null, terminal next/tasks; không LLM/tool/messages hoặc increment revision.
- READY revision=0 có exact validated root ref; INITIALIZING không submit chat.
- Crash-before-CAS reconcile exact initialization identity/metadata/lineage, không latest.
  Ambiguous proof fail closed; retry không duplicate head.
  Runtime queries at most two exact root-marker candidates, requires terminal empty
  state/root lineage and rejects ambiguous/corrupt markers. Presence of completed
  pending-write rows alone does not imply running tasks; exact next/tasks define
  terminality. Latest is checked only for existence to reject an unmarked legacy
  thread, never adopted as an accepted root.
- R1 terminal fail/orphan không mất root; R2 dùng exact root sau verified stop.
- Legacy no-head tự initialize chỉ khi chứng minh chưa có run/checkpoint/history.
  Populated legacy thread cần explicit migration/recovery, không purge hoặc đổi thread ID.
- Planned POST: 201 READY; asynchronous 202 INITIALIZING + polling GET.
  [API revision](../05-api/stateful-chat-v1.md#planned-revision--initial-accepted-rootreadiness).

ISSUE-092 đóng khi initializer/concurrency/crash/CAS/legacy gates pass, không chỉ native experiment.

## Operational configuration — provisional

| Limit | Default |
| --- | --- |
| Model attempts/run | 12 |
| Logical tool calls/run | 8 |
| Validation repairs/run | 2 |
| Serialized graph state | 512000 bytes |
| Tool result | 128000 bytes |
| Candidates | 100 |
| Model context | 8000 estimated tokens |
| Run deadline | 120 seconds |
| Provider output/call | 1200 tokens nếu supported |

Config/env phải validate và snapshot vào run. Đây là provisional bounds,
không measured production capacity/token billing guarantee.

## Context bounds and retention

Published history tách bounded model context; state chỉ giữ typed fields cần thiết.
Trim không cắt AI/tool pairs hoặc pending draft. Validate size trước writes;
oversize dùng bounded typed projection hoặc explicit error, không truncate mất nghĩa.
Immutable snapshot refs cần hash/version/retention; missing/corrupt ref không fallback live facts.

V2 new-turn initialization windows working ledger to the current run only. Prior
run ledgers remain canonical in immutable native ancestors referenced by accepted/
run heads; no checkpoint/blob is deleted or rewritten. Same-run records, including
old-context results, are retained and filtered only for grounding. Native resume
does not run initialization and keeps its committed pairs/receipts. Pending drafts,
canonical requirements and saved builds are not ledger-windowing targets.

100-turn PostgreSQL fixture with a 6KB catalog description verifies bounded working
state and old evidence readability after reopen. This measures serialized state and
logical native payload, not physical disk/WAL allocation, live LLM cost or GC.

- Chat/run/checkpoint: 90 ngày. User deletion: stop/drain rồi purge toàn bộ related data.
- Orphan/debug: 7 ngày chỉ khi unreachable/unprotected.
- Giữ accepted/root, resumable ancestry, pending writes và referenced evidence trong
  lifetime conversation. Không giữ vô hạn sau conversation expiry/delete.
- Windowing chỉ đổi model context/new checkpoints, không rewrite native ancestors.

## Core acceptance

| Gate | Phải chứng minh |
| --- | --- |
| Accepted vs orphan | R1 accepted A, R2 newer B; stop R2; R3 kế thừa A, input đúng một lần, lineage không B; lặp sau pool restart |
| Input boundary | source=input prior values không làm sai run identity; server metadata/START/parents đúng |
| Resume | Exact working ref, giữ next/tasks/pending writes; không new-turn reset hoặc copy values |
| Root | Terminal native root survive restart; concurrent/crash-before-CAS reconcile; failed R1 → R2 root |
| Stop/admission | Alive stale worker, undrained cancel, wrong generation bị chặn; valid termination + concurrent claims chỉ một winner |
| Attempts | Crash RESERVED/UNKNOWN vẫn consumed; adapter retry/fan-out không bypass cap |
| Publish | Sibling/debug/orphan/pending/missing ancestor reject; two finalizers/crash/retry publish một lần |
| Stage reuse | Optimize committed/explain fail không recompute; changed input/version invalidate |
| Storage | 100 turns: đo serialized/native growth; trim/GC giữ pairs, pending drafts, protected refs; missing refs reject |

Dùng PostgreSQL saver/pinned stack cho native gates; scripted model + optimizer thật
cho core. In-memory/lock check không thay native proof. Commands/evidence chỉ lưu ở
[implementation status](stateful-implementation-status.md).
