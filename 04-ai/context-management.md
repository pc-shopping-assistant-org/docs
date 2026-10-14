# State and recovery

Stateful chat lưu hội thoại và tiến trình vào PostgreSQL. **LangGraph sở hữu execution
state; application quyết định state nào được công bố.**

## Conversation, run, checkpoint

```text
Conversation C1 / thread C1
  ├─ Run R1 → cp1 → cp2 (accepted)
  ├─ Run R2 → cp3 → cp4 (working / failed)
  └─ Run R3 starts from accepted cp2, not latest cp4
```

Một conversation ánh xạ stable thread ID; một turn tạo run mới; mỗi run có nhiều
checkpoints. Recovery của cùng run không tạo conversation/thread mới.

## Sources of truth

| Data | Owner |
| --- | --- |
| Account, runs/requests, revision/head, active slot, attempts | Application PostgreSQL |
| Published messages | `conversation_messages` |
| Accepted requirements/build | Exact accepted native checkpoint |
| Working state, native cursor/tasks/pending writes/parents | LangGraph saver |
| Tool outcomes/evidence | Checkpointed ledger |
| Model messages/public DTO/events | Projections, không writable domain state riêng |

Memory hiện conversation-local. Model history window là bounded published messages,
không long-term memory xuyên conversation.

## Accepted head and working checkpoints

Public reads và turn mới dùng exact `accepted_checkpoint_ref`, không latest.
Checkpoint ref nội bộ gồm thread/namespace/checkpoint; client không chọn chúng.

Run claim giữ immutable base revision/ref. New-turn native input có server metadata;
resume dùng exact eligible working ref với input `None`, giữ next/tasks/pending writes.
Không reconstruct execution bằng copy `StateSnapshot.values`.

Working merge đổi content hash nhưng không accepted state. Ví dụ H0→H1→H2 trong
một run: fail/cancel/conflict vẫn public H0; CAS success publish H2 và tăng
conversation revision một lần. Canonical compatibility revision không thay content hash.

## Initial accepted root

Create conversation INITIALIZING → exclusive initializer → native empty root →
stop/drain → CAS READY ở revision 0. Root không gọi LLM/tool hoặc tạo chat message.

Synchronous POST hiện trả 201 READY. Internal retry reconcile exact unique root
marker sau app rollback; concurrent create không attach hai roots.
Populated legacy threads/ambiguous proof fail closed, không adopt latest.

Nếu R1 lỗi, root vẫn là accepted base để lượt sau tiếp tục theo admission/recovery policy.
Automatic asynchronous initialization và legacy migration còn backlog.

## Managed execution

POST commit PENDING run rồi wake executor. Durable scanning/claim xử lý lost handoff;
wake signal không phải source of truth. Lifespan sở hữu supervisor và resources.

HTTP/SSE disconnect không cancel. Explicit cancel được lưu trước signal.
Shutdown dừng admission, cancel/join graph/children/streams/CPU work/checkpoint writes,
rồi persist stop ACK. Chưa drain thì không ACK hoặc release resources/slot.

CPU optimizer dùng awaited bounded worker; cancellation không kill computation.
Không dùng detached fire-and-forget task làm durable executor.

## Admission and stop evidence

Một execution active mỗi conversation/thread. Run status/lease timeout **không
nhường quyền dùng thread**; application fencing không chặn stale saver writes.

Selected runtime dùng owning EXECUTOR_STOP_ACK sau drain. PROCESS_TERMINATED là
contract cần trusted supervisor/operator proof đúng process incarnation; recovery
adapter cho hard process-death chưa enabled.

Heartbeat mất, PID, cancel request hoặc network timeout không là stop proof.
Không nhận execution proof từ HTTP client.

## Run and failure semantics

```text
PENDING → RUNNING → COMPLETED / WAITING_INPUT / FAILED_TERMINAL / CANCELLED
                  └→ FAILED_RETRYABLE → RECOVERING → RUNNING
```

Retryable chỉ khi transient error allowlisted, đủ budgets/deadline/stop proof,
matching versions/refs và accepted base chưa đổi. Unexpected bug mặc định terminal.
Completed/waiting/cancelled không revive cùng run; follow-up là run mới.

Selected V2 tối đa hai execution attempts: retry sau stored owning ACK.
V1 dùng một. Retry không reset call budget hoặc deadline; request retry chỉ đọc
run/result cũ, không tự spawn recovery. Third attempt/process-death takeover chưa supported.

Cleanup retryable đã hết limits/cancel chỉ release khi owning ACK hợp lệ.
Missing/stale ACK hoặc run còn executing vẫn busy.

## Durable call budget

Trước mỗi MODEL/TOOL_IO outbound:

1. Lock/check run authority/cancel/deadline/cap, commit RESERVED attempt.
2. Claimant dispatch reservation mới đúng một lần.
3. Record outcome/usage nếu biết.
4. Sau crash, unresolved attempt là UNKNOWN, vẫn consumed; retry reserve mới.

SDK retries disable hoặc phải instrument mỗi attempt. Backend fan-out tính từng
request; logical tool count khác outbound count.
Checkpoint counters là projections, không hard spending authority.

Attempt cap không exactly-once external execution, total-token hoặc billing guarantee.
Tool success chưa có checkpoint vẫn có thể chạy lại khi resume, nhưng phải reserve mới.

## Native checkpoint and finalization protocol

Saver transaction và application transaction không atomic:

1. Application persist request/user message/base/run.
2. Graph commit working checkpoints ngoài DB transaction dài.
3. Executor drain; validate terminal snapshot/native lineage.
4. Locked CAS atomically publish head/revision/assistant message/run result/events.

Finalizer kiểm tra owner/conversation/run/execution/generation/input/base/graph versions,
native parent lineage và terminal next/tasks/interrupt. Same-thread orphan/sibling/debug
hoặc missing ancestor không đủ để publish.

Checkpoint input boundary có thể giữ values của run cũ; validator dùng server metadata,
START input/direct parent, không chỉ `values.run_id`.
Recovery chỉ bước qua authorized previous-generation ref có bound owning ACK.

Missed working-ref DB record sau saver commit được reconcile bằng bounded exact
execution enumeration, shared lineage validator và unique tip, không global latest.
Same-execution forks/corrupt state reject.

CAS conflict/failure không overwrite accepted result. Same finalized ref/hash trả saved
result, không thêm message/revision hoặc chạy lại optimizer.

## Stage completion markers and invalidation

Reuse requires explicit COMPLETED status, validated result, input hash và versions.
Không dùng `field != None` làm terminal marker.

Requirements/catalog/compiler/engine/policy đổi → invalidate dependent optimizer/explanation.
Chỉ explanation input đổi → giữ valid optimizer result. Native resume sau committed
optimization không optimize lại chỉ vì explanation lỗi.

Historical build giữ original financial snapshot và stale label; không lấy current prices
hoặc current accessories để reconstruct spending cũ.

## Context bounds and retention

Model nhận tối đa bốn published user/assistant pairs, tổng 12.000 chars. SQL filter
owner/conversation/accepted revision; loại current/failed/debug turns; window freeze
trong execution context cho recovery.

Current-run ledger/context/output có finite bounds; turn mới không copy ledger history.
Không trim pending state, complete provider pairs hoặc ancestor/evidence cần recovery.

Retention policy: chat/run/checkpoint90 ngày; unprotected orphan/debug7 ngày.
Delete phải stop/drain rồi purge related data. Jobs/public delete/GC còn backlog,
không được enable chỉ từ policy. Replay internal-only, snapshot-based và không publish;
replay tooling cũng còn backlog.

## Core acceptance

Exact accepted vs orphan; native root/reopen/resume; one execution + stop ACK;
durable attempts không reset; failed/cancel/conflicting publication giữ accepted state;
committed optimizer/tool work được reuse với matching hashes/versions.

Evidence: [core audit](core-audit.md), [current status](stateful-implementation-status.md).
Reference: [database](../03-data/ai-stateful-schema.md), [HTTP V2](../05-api/stateful-chat-v2.md).

**Next:** [Model providers](model-strategy.md) · [Testing](testing.md).
