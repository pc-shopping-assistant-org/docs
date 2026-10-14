# Agent and tools

ReAct ở đây là vòng **chọn action → gọi tool → quan sát → chọn tiếp** trong LangGraph.
Agent được linh hoạt khám phá; application giữ requirements và kết quả đúng contract.

Đã đọc [Architecture](../02-architecture/ai-architecture.md)? Trang này đi sâu vào vòng agent.

## Agent lifecycle

```text
Load accepted context → Register/continue tasks → Agent
                                               │
                  ┌────────────────────────────┼───────────────────────┐
                  ▼                            ▼                       ▼
              CALL_TOOL               PROPOSE_REQUIREMENTS     ASK_CLARIFICATION
              Policy/dispatch         Resolve/confirm/merge     Persist pending
                  │                            │                       │
                  └──── Observe → Agent ◄───────┘                 WAITING_INPUT
                                      │
                                 FINAL_ANSWER
                          Grounding + completion
                                      │
                              Prepare publication
```

Requirement resolution không là mandatory prefix của mọi câu hỏi. Agent có thể
đọc catalog/web trước khi đủ thông tin build. Nó không được đổi BUILD/COMPARE thành
ANSWER chỉ để kết thúc sớm.

Clarification kết thúc execution với pending artifact; user trả lời ở run sau,
không giữ coroutine chờ user.

## Actions and protocol

| Action | Effect |
| --- | --- |
| `CALL_TOOL` | Một typed tool invocation |
| `PROPOSE_REQUIREMENTS` | Draft được application resolve/validate; không tự merge |
| `ASK_CLARIFICATION` | Hỏi đúng thông tin thiếu hoặc confirmation |
| `FINAL_ANSWER` | Candidate phải qua grounding/completion trước publish |

Model response không cấp owner, revision, checkpoint selector hay trusted task kind.
V2 action schemas: [tool reference](../05-api/tool-contracts.md).

Native tool calling dùng OpenAI/Gemini adapters; không text parser/`exec`.
Chỉ bind allowed subset. Khi hỗ trợ thì tắt parallel calls, nhưng vẫn validate:
multiple/malformed/mixed calls bị reject cả response. Không append hai calls rồi
trả một ToolMessage. Repair hữu hạn dùng static feedback và durable attempt mới.

Gemini provider signature được giữ opaque theo call cho protocol recovery, không
là tool args/public output. Không gửi hidden reasoning ra frontend.

## Tools

| Tool | Used for |
| --- | --- |
| `search_catalog` | Tìm canonical products |
| `get_product_details` | Đọc detail/evidence một product |
| `compare_products` | So sánh 2–5 products |
| `build_pc` | Tạo mới/điều chỉnh từ trusted requirements qua optimizer/verifier |
| `search_web` | Tìm nguồn |
| `read_web_page` | Đọc nội dung/facts của nguồn đã chọn |

Không cần `adjust_build`; requirements đã merge quyết định lần build tiếp theo.
Commerce helpers không tự thành tools. Runtime không expose cart/order/payment mutation.

## Tool policy

`allowed_tools(context)` tính subset theo trusted state; dispatcher recheck ngay
trước execution. Thiếu canonical catalog hoặc requirements chưa compile-ready thì
không expose `build_pc`. Read tools vẫn dùng được khi user đang khám phá.

Schema validation, policy và authorization khác nhau. Tool args hợp lệ không có
nghĩa được phép execute. Budget/deadline/cancel và principal do application cấp,
không lấy từ model.

## Ledger and observation

Typed ToolResult là canonical execution truth. LangGraph checkpoint giữ ledger;
AIMessage/ToolMessage được project từ complete, context-matching ToolRecords.

- Call ID khác args bị reject; cùng ID không cho phép sửa outcome.
- Current-run ledger giữ nguyên sau merge; stale-context results bị loại khỏi projection.
- Turn mới không copy toàn bộ ledger cũ; ancestors/evidence vẫn giữ trong checkpoint history.
- Native resume dùng outcomes đã commit, không execute lại tool chỉ để tạo ToolMessage.
- Attempt SUCCEEDED không chứng minh ToolResult đã checkpoint; hai loại ledger khác nhau.

Hash binds args/requirements/catalog. Giá hoặc build từ context cũ không tự thỏa
task sau khi requirements đã đổi.

## Requirements and consent

Proposal branch dùng [requirement pipeline](requirements.md). Explicit user changes
cần source-bound extraction/resolution; agent-origin changes cần immutable confirmation.

Ví dụ: user yêu cầu RAM32GB; agent muốn giảm RAM để tăng GPU. Đây là proposal,
không phải user instruction. “OK” phải gửi đúng proposal ID/hash/revision/base hash;
không chấp nhận một proposal đã bị đổi nội dung.

Merge chỉ sửa working state. Application replay/revalidate receipts từ accepted/
confirmed base trước publish; model confidence/source span không là authority tự thân.

## Requested tasks

Task registration dùng bounded accepted history để hiểu follow-up, nhưng không
được dùng history làm current facts hoặc new consent.

| Task | Completion requirement |
| --- | --- |
| BUILD | Verified feasible build hoặc scope-proven infeasibility |
| COMPARE | Đủ requested product subjects/evidence |
| EXPLAIN_SAVED_BUILD | Exact authorized accepted snapshot, đúng historical/stale label |
| ANSWER | Grounded selected evidence |
| Pending clarification | Original task giữ pending, không downgrade |

Product attachments dùng product IDs: một product là ANSWER; 2–5 là COMPARE.
Names cần canonical resolution; ambiguous binding giữ pending và có offered options.
Chưa bind đủ subjects không chặn read exploration nhưng không được công nhận completion.

Saved-build explanation không tạo fake tool call. Nó dùng snapshot từ accepted base,
giữ historical spending; không đáp ứng một task BUILD mới. Arbitrary older-run selectors
còn backlog.

## Grounding and completion

**Grounding:** câu trả lời dựa vào evidence nào?
**Completion:** evidence đó có đáp ứng đúng task user yêu cầu không?

Facts về giá/SKU/spec/tổng tiền được server render từ typed results. Web content-only
dùng exact excerpts; [web research](web-research.md) giải thích structured facts.

Qualitative explanation cần refs thuộc selected evidence và được ghi nhãn nhận định.
Ref validation không chứng minh mọi câu prose đúng; factuality/semantic eval là quality
gate riêng. Full claim-level extension không được giả là đã implemented.

| Final outcome | Required evidence |
| --- | --- |
| BUILT | Current verified optimizer receipt/build |
| INFEASIBLE | Actual sound search proof trong declared candidate scope |
| SEARCH_INCOMPLETE | Chưa tìm được nghiệm, thiếu completeness proof |
| INSUFFICIENT_EVIDENCE | Typed missing/empty/UNKNOWN/CONFLICT evidence phù hợp |
| DEPENDENCY_UNAVAILABLE | Actual failed dependency/tool outcome |
| ANSWERED | Grounded answer cho registered task |

Không tìm thấy ≠ không tồn tại. Backend error, advice hoặc stale result không là
infeasibility proof. SEARCH_INCOMPLETE không hoàn thành BUILD bằng khẳng định vô nghiệm.

Multi-task candidate phải cover từng registered task index đúng một lần.
Application validate từng task; có thể lưu build hợp lệ dù một task nghiên cứu web
còn unresolved. Overall completion chỉ khi tất cả tasks hoàn thành.

## Publication

Final action vẫn là candidate. Graph chuẩn bị sanitized accepted snapshot; coordinator
recheck task/grounding, receipts, native lineage, stop proof và CAS revision/head.
Working refs, ledger, internal owner/execution metadata không ra public DTO.

SSE chỉ project journal; COMPLETED sau successful publication. Disconnect không cancel,
không reconnect tự động. [State/recovery](context-management.md) giữ protocol chi tiết.

## Core acceptance

Read trước khi đủ budget; clarification không mất task; agent changes không tự merge;
unsupported không bị bỏ ngầm; stale evidence không publish; build cần optimizer/verifier;
resume reuse committed work; stop/lineage/CAS giữ accepted head bất biến khi fail.

Verification records: [core audit](core-audit.md), không suy live correctness từ test counts.

**Next:** [Requirements](requirements.md) · [Add a tool](guides/add-tool.md).
