# UC-AUTH-002 — Đăng ký tài khoản

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-002` |
| Tác nhân | Khách hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 47–48 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đăng ký tài khoản theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng chưa có tài khoản.

## Điều kiện sau

Tài khoản khách hàng mới được tạo thành công.

## Luồng chính

1. Mở trang đăng ký.
2. Nhập email, số điện thoại, mật khẩu, họ, tên, giới tính, ngày sinh và địa chỉ.
3. Hệ thống chuẩn hóa email/số điện thoại, kiểm tra trùng email và số điện thoại, lưu tạm dữ liệu đăng ký (10 phút) rồi gửi OTP 6 số đến email (hiệu lực 5 phút). Chưa có tài khoản nào được tạo ở bước này.
4. Khách hàng nhập OTP (có thể yêu cầu gửi lại OTP khi phiên đăng ký còn hiệu lực).
5. Hệ thống đối chiếu OTP với giá trị đã gửi.
6. Hệ thống tạo trong một transaction: tài khoản (`ROLE_CUSTOMER`, `ACTIVE`, mật khẩu băm), hồ sơ khách hàng và địa chỉ mặc định (người nhận = họ + tên, số điện thoại và địa chỉ vừa nhập), rồi xóa OTP và dữ liệu đăng ký tạm.
7. Hệ thống đăng nhập luôn cho khách hàng (cấp token như đăng nhập) nên khách vào hệ thống ngay, không phải đăng nhập lại.

## Luồng thay thế / ngoại lệ

- Email đã tồn tại.
- Số điện thoại đã tồn tại.
- OTP không hợp lệ.
- Phiên đăng ký đã hết hạn (quá 10 phút) → phải đăng ký lại; không gửi lại OTP được.
- Dữ liệu không thỏa ràng buộc: số điện thoại Việt Nam (`0` hoặc `+84` rồi 9–10 số), mật khẩu 8–100 ký tự gồm chữ hoa, chữ thường và số, địa chỉ tối đa 500 ký tự.
- Người dùng hủy đăng ký.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
