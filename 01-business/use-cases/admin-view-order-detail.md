# UC-ADM-ORD-002 — Xem chi tiết đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-ORD-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41; Hình 22 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem chi tiết đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Đơn hàng tồn tại.

## Điều kiện sau

Địa chỉ, số điện thoại và danh sách sản phẩm trong đơn được hiển thị.

## Luồng chính

1. Chọn một đơn hàng.
2. Hệ thống tải snapshot người nhận, địa chỉ, ghi chú, phương thức và phí giao hàng, các dòng hàng, tiền giảm, mọi lần thanh toán (lấy từ Payment Service) và lịch sử trạng thái đầy đủ, mỗi dòng gồm trạng thái cũ, mới, người đổi, lý do và thời điểm.
3. Hiển thị dữ liệu tài chính từ snapshot của order, không tính lại bằng giá catalog hoặc bảng phí hiện tại.

## Luồng thay thế / ngoại lệ

- Order không tồn tại → thông báo không tìm thấy.
- Payment Service không trả lời → báo lỗi, không hiển thị thiếu thông tin thanh toán.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
