# UC-AUTH-004 — Đăng xuất

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-004` |
| Tác nhân | Khách hàng, Nhân viên, Quản trị viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 39–41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đăng xuất theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đang đăng nhập (khách hàng, nhân viên hoặc quản trị viên).

## Điều kiện sau

Phiên đăng nhập kết thúc.

## Luồng chính

1. Người dùng chọn đăng xuất.
2. Hệ thống kết thúc phiên/xóa trạng thái xác thực: mọi access token và refresh token của tài khoản phát hành trước thời điểm đăng xuất bị thu hồi (đăng xuất khỏi mọi thiết bị, không chỉ thiết bị hiện tại).
3. Hệ thống đưa người dùng về trạng thái chưa đăng nhập.

## Luồng thay thế / ngoại lệ

- Token gửi lên không hợp lệ, đã hết hạn hoặc là refresh token → từ chối.
- Hệ thống lưu thông tin thu hồi token không khả dụng → báo lỗi thay vì báo đăng xuất thành công giả.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

## Ghi chú triển khai

Đăng xuất yêu cầu access token của chính tài khoản; không cần gửi thêm gì khác. Hệ thống ghi mốc thu hồi theo tài khoản vào Redis trong suốt thời gian sống của refresh token, nên mọi token phát hành trước mốc (tính theo giây) đều bị từ chối, kể cả ở gateway nên các service khác cũng từ chối. Khóa, vô hiệu hóa hoặc xóa tài khoản cũng ghi mốc tương tự. Redis local dùng AOF và named volume.

Nếu production làm mất dữ liệu Redis không thể khôi phục, rotate `JWT_SECRET_KEY` rồi restart backend trước khi nhận traffic để vô hiệu hóa toàn bộ JWT đang tồn tại. Khi Redis không khả dụng, backend từ chối thay vì bỏ qua (fail-closed).
