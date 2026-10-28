# UC-REV-001 — Đánh giá sản phẩm sau khi mua

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-REV-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.1, tr. 39 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đánh giá sản phẩm sau khi mua theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Order item thuộc khách hàng đó tồn tại và order tương ứng có trạng thái `COMPLETED`.

## Điều kiện sau

Đánh giá sản phẩm được ghi nhận và gắn duy nhất với order item.

## Luồng chính

1. Khách hàng mở sản phẩm/đơn đã mua. Trang đơn hàng thay nút "Viết đánh giá" bằng liên kết tới đánh giá của khách nếu order item đó đã được đánh giá.
2. Chọn chức năng đánh giá.
3. Nhập mức đánh giá (1–5 sao) và nội dung nhận xét (tối đa 2000 ký tự).
4. Hệ thống kiểm tra sản phẩm tồn tại và chưa bị xóa, order item thuộc khách (hỏi Order Service), đơn đã `COMPLETED`, order item thuộc đúng sản phẩm và chưa có đánh giá.
5. Hệ thống lưu đánh giá `ACTIVE`, gắn duy nhất với order item (mỗi order item chỉ đánh giá một lần).
6. Đánh giá hiển thị công khai ở trang sản phẩm, mới nhất trước, kèm tên người đánh giá (tên hiện tại của khách, lấy từ Identity Service). Đánh giá của chính khách được ghim lên đầu danh sách để khách sửa tại đó.
7. Sửa đánh giá: khách mở đánh giá của mình, đổi mức đánh giá và/hoặc nội dung (ít nhất một trường). Chỉ sửa được **một lần duy nhất**, trong vòng **30 ngày** kể từ lần gửi đầu tiên và khi sản phẩm vẫn còn đăng bán (`ACTIVE`). Bản sửa ghi đè nội dung cũ, hệ thống không giữ lịch sử các bản sửa; hai yêu cầu sửa đồng thời không cùng thành công.

## Luồng thay thế / ngoại lệ

- Sản phẩm không tồn tại hoặc đã xóa; order item không tồn tại hoặc không thuộc khách → không tìm thấy.
- Đơn chưa `COMPLETED` (kể cả đã hủy) → từ chối.
- Order item thuộc sản phẩm khác, hoặc đã có đánh giá → từ chối.
- Mức đánh giá ngoài 1–5, thiếu order item, nội dung quá 2000 ký tự → từ chối.
- Identity Service không trả lời khi hiển thị danh sách đánh giá → báo lỗi, không trả danh sách thiếu tên.
- Khi sửa: đánh giá không tồn tại hoặc không thuộc khách → không tìm thấy; đã sửa một lần, quá 30 ngày kể từ khi tạo hoặc sản phẩm không còn đăng bán → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
