# UC-ADM-ORD-004 — Hủy đơn hàng khi có sự cố

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-ORD-004` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41; Hình 22 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Hủy đơn hàng khi có sự cố theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Có sự cố trong quá trình vận đơn theo mô tả report.

## Điều kiện sau

Đơn bị hủy và khách hàng được thông báo.

## Luồng chính

1. Chọn đơn hàng.
2. Chọn hủy đơn và nhập lý do (bắt buộc, tối đa 500 ký tự).
3. Hệ thống khóa đơn và kiểm tra điều kiện: nhân viên hủy được đơn ở `PENDING_PAYMENT`, `PENDING_CONFIRMATION`, `CONFIRMED` hoặc `SHIPPING`.
4. Hệ thống chuyển đơn sang `CANCELLED`, ghi lý do và người thực hiện vào lịch sử trạng thái; cùng transaction ghi vào outbox lệnh trả tồn kho và sự kiện đơn bị hủy (xem UC-ORD-003 về hệ quả với tồn kho và payment).
5. Khách hàng thấy đơn `CANCELLED` kèm lý do ở trạng thái và chi tiết đơn của mình. Hệ thống chưa gửi thông báo đẩy hay email riêng.

## Luồng thay thế / ngoại lệ

- Đơn ở trạng thái không hủy được (đã `COMPLETED` hoặc `CANCELLED`) → từ chối.
- Thiếu lý do hủy → từ chối.
- Đơn không tồn tại → thông báo không tìm thấy.
- Payment đã `PAID` không tự hoàn: nhân viên liên hệ khách, hoàn tiền ngoài hệ thống rồi đánh dấu `REFUNDED` (UC-ADM-PAY-002).

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
