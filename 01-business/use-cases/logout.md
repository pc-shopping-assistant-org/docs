# UC-AUTH-004 — Đăng xuất

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-004` |
| Tác nhân | Khách hàng, Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 39–41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đăng xuất theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng đang đăng nhập.

## Điều kiện sau

Phiên đăng nhập kết thúc.

## Luồng chính

1. Người dùng chọn đăng xuất.
2. Hệ thống kết thúc phiên/xóa trạng thái xác thực.
3. Hệ thống đưa người dùng về trạng thái chưa đăng nhập.

## Luồng thay thế / ngoại lệ

- Không được report đặc tả thêm.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

## Ghi chú triển khai

API yêu cầu Bearer access token ở `POST /api/v1/auth/logout`. Logout tạo marker
`tokens-revoked-before` theo account trong Redis trong suốt thời gian sống của
refresh token, nên mọi access/refresh token phát hành trước cutoff-second của
logout đều bị từ chối (JWT NumericDate có độ chính xác theo giây). Client có thể
gửi thêm `refreshToken` trong body để lưu blacklist riêng cho token đó; body
không bắt buộc. Redis local dùng AOF + named volume.
Nếu production làm mất dữ liệu Redis không thể khôi phục, rotate
`JWT_SECRET_KEY` rồi restart backend trước khi nhận traffic để vô hiệu hóa toàn
bộ JWT đang tồn tại. Khi Redis không khả dụng, backend fail-closed ở logout,
refresh và access-token authentication, không báo logout thành công giả.
