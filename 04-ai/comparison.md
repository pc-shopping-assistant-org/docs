# Product comparison

So sánh dựa trên canonical product evidence, không dựa trên tên/giá do model viết.
Một comparison có 2–5 distinct product IDs.

## Select products

Có hai đường:

- Frontend gửi `selected_product_ids`: một ID tạo ANSWER, 2–5 IDs tạo COMPARE.
- User nói tên: application đăng ký task và canonical-resolve từng subject.

Read/compare dùng product IDs. Variant/SKU IDs thuộc optimizer/purchased parts,
không thay product IDs chỉ vì cùng model name.

## Independent of PC builds

Giải thích và so sánh đọc product catalog, không tải hardware snapshot và không gọi
optimizer. Thiếu benchmark/TDP hoặc một build đang chờ không chặn lượt đọc sản phẩm
đính kèm. Application giữ nguyên requirements, saved build và pending proposal;
lượt đọc chỉ công bố câu trả lời mới. Confirmation sau đó vẫn dùng binding gốc và
conversation revision hiện tại.

## Handle ambiguity

> “So sánh RTX5070Ti ASUS và MSI.”

Mỗi tên có thể match nhiều products. Task giữ original source và offered choices;
agent có thể đọc thêm, nhưng chưa được hoàn thành comparison khi subjects chưa bind đủ.

Typed/free-text selection phải khớp offered options/revision/source và canonical catalog.
Product đã biến mất không tự thay bằng match còn lại.
User sửa một subject giữ original task và các subjects khác.

## Produce the comparison

`compare_products` trả evidence đúng requested subjects. Server validate đủ refs,
visibility và identity rồi render selected facts. Missing specifications/price ghi unknown,
không suy spec từ brand hoặc tên SKU.

Qualitative explanation liên kết selected evidence, không biến thành benchmark guarantee.
Web quote bổ sung tham khảo nhưng không thay canonical comparison evidence.
Model có thể chọn canonical tool call hoặc refs, kể cả `explanation_refs`.
Application resolve chúng về cùng ledger trước khi kiểm tra completion; không yêu cầu
model lặp lại cùng reference trong nhiều fields. Ref không tồn tại vẫn bị từ chối.

## Continue the conversation

Sau comparison, ordinary chat dùng cùng conversation/history window.
Original task không bị downgraded bởi câu “chọn cái thứ hai”.
Nếu pending task chưa hoàn tất, user có thể dùng bound REPLACE/DISCARD; không đổi
topic và xóa pending artifact bằng inference ngầm.

**Next:** [HTTP V2 attachments/commands](../05-api/stateful-chat-v2.md) · [Agent completion](agent-tools.md#grounding-and-completion).
