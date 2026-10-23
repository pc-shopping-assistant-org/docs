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

Dialogue history vẫn conversation-local. Account memory riêng cho phép user lưu
context xuyên conversation; không trộn nó vào canonical requirements.

## Response và tiến độ nghiệp vụ

Mỗi turn có thể publish `response` mà không hoàn tất business task. Snapshot giữ
response riêng với `answer`/task outcomes: hội thoại không có task không tạo outcome
giả; câu hỏi chen ngang giữ nguyên WAITING_INPUT, original task và pending artifact.
`assistant_message` ưu tiên response của lượt mới; history vẫn lưu qua application.

Agent đọc requirements, saved build và pending projection để hiểu “con đó”, “nâng
lên vậy”. Snapshot/history không trở thành giá hiện tại hoặc quyền confirmation.
Side response vẫn tăng conversation revision qua CAS; proposal id/hash/original
target revision giữ nguyên, confirmation kiểm tra current requirements hash và
CAS dùng current expected revision. Không reissue proposal chỉ vì user hỏi thêm.

Requirements cũng có thể được ghi nhận trước khi có task BUILD. Response sau merge
phải replay source-admission receipts hoặc original confirmation bằng cùng publication
validator; không dùng plain text làm authority. Nếu không đổi requirements, giữ nguyên
pending. Câu hỏi/chọn lựa mới không được vô tình phát lại side-response cũ.

## Account memory

`user_memories` trong PostgreSQL lưu entry do user chủ động PUT qua API; không có
auto-extraction từ raw chat, Mem0 hoặc vector DB. Entry gồm key, kind
PREFERENCE/OWNED_CONTEXT, content, updated_at và expires_at; tối đa20 entry/tài khoản,
400 ký tự/entry, hiệu lực90 ngày từ lần lưu. User xem/sửa/xóa qua [Memory API](../05-api/stateful-chat-v2.md#account-memory).

Run mới đọc memory của verified owner, đóng băng vào ToolContext/checkpoint. Recovery
dùng snapshot đó, không reload memory mới. Model được dùng nó để hỏi/gợi ý, không được
tự merge budget, pin, ownership hay xác nhận proposal. Current explicit requirements
luôn ưu tiên; remembered ownership phải được user xác nhận và catalog resolve lại.
Không coi memory là evidence giá, stock, compatibility hoặc benchmark.

DELETE ảnh hưởng các run tạo sau đó; không viết lại checkpoint/hội thoại đã lưu.
Memory do user quản lý độc lập conversation; xóa conversation không tự xóa entry tài
khoản. Expired entries không được retrieve; upsert dọn expired rows của owner trong
transaction. Global physical purge và protected checkpoint retention vẫn backlog.

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
Giới hạn một attempt của V1 chỉ còn trong fixture lịch sử. Retry không reset call budget hoặc deadline; request retry chỉ đọc
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
Run mới mặc định48 TOOL_IO, định nghĩa bởi DEFAULT_TOOL_IO_LIMIT. Web ports reserve
từng search/read trước I/O; logical tool admission cũng tiêu một attempt. Điều này
cho phép research nhiều nguồn mà vẫn giữ giới hạn durable. Run cũ giữ budget đã lưu.

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
