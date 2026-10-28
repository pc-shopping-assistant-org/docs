# UC-ADM-DASH-001 — Xem tổng quan quản trị

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DASH-001` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **IMPLEMENTATION** |
| Nguồn | Chương 5.2.1, tr. 85 |

> **Mức nguồn:** Có bằng chứng giao diện/triển khai ở Chương 5 nhưng Chương 3 không đặc tả đầy đủ.

## Mục tiêu

Xem tổng quan quản trị theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`).

## Điều kiện sau

Trang tổng quan được hiển thị.

## Luồng chính

1. Mở trang quản trị.
2. Hệ thống hiển thị dashboard gồm: doanh thu hôm nay và tháng này (tổng tiền các đơn `COMPLETED`, tính theo ngày giao), số đơn theo từng trạng thái, số khách hàng mới, số variant sắp hết hàng (đang `ACTIVE`, tồn kho từ 1 đến ngưỡng, mặc định 5) và số variant hết hàng.
3. Mỗi service cung cấp phần số liệu của mình; giao diện ghép lại. "Hôm nay" và "tháng này" tính theo múi giờ cửa hàng (mặc định `Asia/Ho_Chi_Minh`).

## Luồng thay thế / ngoại lệ

- Một service không phản hồi → dashboard vẫn hiển thị các chỉ số còn lại và báo lỗi riêng ở phần bị thiếu, không làm lỗi cả trang.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
