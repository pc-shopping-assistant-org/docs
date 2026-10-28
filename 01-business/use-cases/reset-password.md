# UC-AUTH-003 — Khôi phục/đặt lại mật khẩu

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-003` |
| Tác nhân | Khách hàng, Nhân viên, Quản trị viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 48 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Khôi phục/đặt lại mật khẩu theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tài khoản đã tồn tại.

## Điều kiện sau

Mật khẩu mới được thiết lập thành công.

## Luồng chính

1. Chọn quên mật khẩu.
2. Nhập email của tài khoản.
3. Hệ thống gửi OTP 6 số (hiệu lực 5 phút) đến email nếu có tài khoản đang hoạt động khớp. Thông báo luôn như nhau dù email có tồn tại hay không, nên không lộ thông tin tài khoản.
4. Người dùng nhập OTP và mật khẩu mới.
5. Hệ thống kiểm tra tài khoản và OTP, hủy OTP sau khi dùng (dùng một lần), lưu mật khẩu mới.

Hệ thống chỉ hỗ trợ khôi phục bằng email (kênh OTP duy nhất là email); không nhận số điện thoại. Mật khẩu mới phải có 8–100 ký tự gồm chữ hoa, chữ thường và số. Đặt lại mật khẩu không thu hồi các token đã phát hành.

## Luồng thay thế / ngoại lệ

- Email không có tài khoản hoặc tài khoản không hoạt động → không gửi OTP; thông báo vẫn như thành công, đến bước xác nhận thì báo OTP không hợp lệ.
- OTP không hợp lệ hoặc hết hạn.
- Người dùng hủy thao tác.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
