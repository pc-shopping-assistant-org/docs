# UC-ORD-003 — Hủy đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-003` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Hủy đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Là chủ đơn; đơn đang ở `PENDING_PAYMENT` hoặc `PENDING_CONFIRMATION`.

## Điều kiện sau

Đơn hàng được chuyển sang `CANCELLED`.

## Luồng chính

1. Khách hàng chọn đơn đang chờ.
2. Chọn hủy đơn (có thể nhập lý do).
3. Hệ thống khóa đơn để kết quả thanh toán hay lần hủy thứ hai không chen vào, rồi kiểm tra chủ đơn và trạng thái.
4. Nếu hợp lệ, hệ thống chuyển đơn sang `CANCELLED` và ghi một dòng lịch sử trạng thái (lý do hủy nếu khách nhập) trong cùng transaction.
5. Hệ thống xử lý hệ quả qua saga:
   - Order Service ghi vào outbox, cùng transaction với việc hủy, lệnh trả tồn kho và sự kiện đơn bị hủy.
   - Catalog Service trả lại đúng phần tồn kho đơn đang giữ (đơn chưa giữ được thì không có gì để trả).
   - Payment Service chuyển payment `PENDING` (đơn chờ thanh toán online, hoặc đơn COD chưa thu tiền) sang `CANCELLED`.
   - Đơn đã thanh toán online: payment vẫn `PAID`. Nhân viên liên hệ khách, hoàn tiền ngoài hệ thống rồi đánh dấu `REFUNDED` (UC-ADM-PAY-002). Hệ thống không hoàn tiền qua cổng thanh toán.

## Luồng thay thế / ngoại lệ

- Đơn không còn ở trạng thái cho phép hủy (từ `CONFIRMED` trở đi khách không tự hủy được; liên hệ nhân viên) → từ chối.
- Đơn không thuộc khách đang đăng nhập → xử lý như đơn không tồn tại.
- Đơn đã `CANCELLED` → từ chối (trạng thái cuối).
- Hệ thống cũng tự hủy đơn (không do khách) khi thanh toán online thất bại, hoặc khi Catalog không giữ được tồn kho; trường hợp thanh toán thất bại có trả lại tồn kho. Lý do hủy hiển thị cho khách ở trạng thái và chi tiết đơn.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
