# UC-AUTH-005 — Đổi mật khẩu

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-005` |
| Tác nhân | Khách hàng, Nhân viên, Quản trị viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 39–41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đổi mật khẩu theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập (khách hàng, nhân viên hoặc quản trị viên) với tài khoản hợp lệ.

## Điều kiện sau

Mật khẩu được đổi sau khi xác minh OTP.

## Luồng chính

1. Người dùng nhập mật khẩu cũ và mật khẩu mới.
2. Hệ thống kiểm tra tài khoản đang hoạt động và mật khẩu cũ, lưu tạm mật khẩu mới (10 phút) rồi gửi OTP 6 số (hiệu lực 5 phút) đến email đăng ký. Mật khẩu chưa đổi ở bước này.
3. Người dùng nhập OTP.
4. Hệ thống xác minh và hủy OTP, lưu mật khẩu mới, xóa mật khẩu tạm.

Tài khoản tạo từ Google chưa có mật khẩu: bỏ qua bước nhập mật khẩu cũ, OTP gửi email là bằng chứng duy nhất, nên chính luồng này dùng để đặt mật khẩu lần đầu. Đổi mật khẩu không thu hồi các token đã phát hành.

## Luồng thay thế / ngoại lệ

- Mật khẩu cũ sai.
- OTP sai/hết hiệu lực.
- Phiên đổi mật khẩu hết hạn (quá 10 phút kể từ bước 1) → phải làm lại từ đầu.
- Mật khẩu mới không thỏa ràng buộc (8–100 ký tự gồm chữ hoa, chữ thường và số).

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
