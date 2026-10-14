# Add a tool

Một tool mới phải là typed vertical slice, không chỉ một helper function.
Đọc [Agent/tools](../agent-tools.md) và [tool reference](../../05-api/tool-contracts.md) trước.

## 1. Define the capability

Chốt input/output, evidence, failure và requested task nó có thể hoàn thành.
Xác định UC, actor/ownership, preconditions và acceptance; cập nhật tracker trước code.
Không mở cart/order mutation chỉ vì đã có read-tool infrastructure.

## 2. Define a port

Outbound service/HTTP integration nằm sau `application/ports/`.
Network/SDK implementation nằm `infrastructure/`; domain tool không import concrete client.

## 3. Add strict contracts

Trong `capabilities/assistant/react/contracts.py`:

- Thêm ToolName và args schema vào TOOL_SCHEMAS.
- Thêm discriminated result payload và consistency validation.
- Args không nhận owner/revision/price/stock/checkpoint/execution authority.
- Evidence ref phải bind actual source/payload/context; không URL/text do model tự cấp.

Example có sẵn: SearchWebArgs(query, limit) và ReadWebPageArgs(url, offset, max_chars).
Không sửa envelope HTTP để chứa observation riêng.

## 4. Wire policy and dispatcher

`allowed_tools(context)` expose khi prerequisites đúng; `ToolDispatcher.execute`
recheck trước handler. Tool chỉ trả typed outcome, không sửa requirements/public build.

Mỗi outbound attempt reserve trước gọi. Logical invocation count không thay TOOL_IO
budget khi handler gọi nhiều requests.

## 5. Bind runtime

Inject port adapter ở `infrastructure/execution/build_runtime.py`.
Provider bind tool schemas từ registry, không dynamic discovery runtime.
Graph chỉ orchestration; không đưa business service logic vào node.

## 6. Ground and complete

Định nghĩa cách result hỗ trợ answer/task trong `react/outcomes.py` và presenter.
Có DTO hợp lệ chưa đủ: phải đủ requested subjects, current hashes và canonical refs.
Failed/unreadable/unknown result không thành positive fact.

Nếu không có completion validator, tool chưa đủ để gọi feature completed.

## 7. Test and document

Core: args rejection, policy gate, typed result, evidence và final completion.
Native: committed result → explain failure → resume reuse, nếu tool ảnh hưởng recovery.
Provider: matched AI/tool pair và malformed/multi-call rejection.

Cập nhật tool reference, guide/UC và tracker; evidence ở status.
Chạy [testing gates](../testing.md), không claim live integration từ mocked HTTP.

**Next:** [Extend requirements](extend-requirements.md).
