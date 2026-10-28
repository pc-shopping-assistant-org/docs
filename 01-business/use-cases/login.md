# UC-AUTH-001 — Đăng nhập

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-001` |
| Tác nhân | Khách hàng, Nhân viên, Quản trị viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 46 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đăng nhập theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng đã có tài khoản.

## Điều kiện sau

Người dùng đăng nhập thành công và có thể truy cập chức năng phù hợp vai trò.

## Luồng chính

1. Người dùng mở trang đăng nhập.
2. Nhập email hoặc số điện thoại và mật khẩu.
3. Hệ thống tìm tài khoản theo email hoặc số điện thoại, kiểm tra trạng thái tài khoản rồi mới so khớp mật khẩu.
4. Nếu hợp lệ, hệ thống phát hành cặp token (access token và refresh token) kèm thông tin tóm tắt người dùng và vai trò, rồi chuyển vào hệ thống.
5. Khi access token hết hạn, hệ thống dùng refresh token để cấp cặp token mới. Refresh bị từ chối nếu token đã bị thu hồi (đăng xuất, khóa tài khoản) hoặc tài khoản không còn hoạt động.

### Luồng thay thế: Google Login

1. Người dùng chọn tiếp tục với Google.
2. Google Identity Services trả về ID token cho browser.
3. Backend verify chữ ký, issuer, audience và `email_verified` của token.
4. Backend tìm account đã liên kết theo Google `sub`. Lần đầu: nếu email đã
   verify trùng một account local thì liên kết vào account đó; nếu chưa có
   account nào thì tự tạo tài khoản khách hàng (`ROLE_CUSTOMER`, `ACTIVE`) với
   tên lấy từ Google, chưa có mật khẩu và số điện thoại.
5. Nếu account hợp lệ, hệ thống phát hành cùng cặp token như đăng nhập mật khẩu.
6. Với tài khoản mới, ảnh đại diện Google được sao chép sang Media Service ở
   nền; lỗi bước này không làm hỏng đăng nhập.

Tài khoản tạo từ Google chưa có mật khẩu nên chưa đăng nhập bằng mật khẩu được;
khách hàng đặt mật khẩu trong trang tài khoản (chỉ cần mã OTP gửi email) và có
thể bổ sung số điện thoại sau. Google Login không bao giờ tạo hay nâng quyền
tài khoản nhân viên/quản trị.

## Luồng thay thế / ngoại lệ

- Thông tin đăng nhập không hợp lệ → yêu cầu nhập lại. Email/số điện thoại không tồn tại và mật khẩu sai cho cùng một thông báo để không lộ tài khoản có tồn tại hay không.
- Tài khoản bị khóa (`LOCKED`) hoặc không hoạt động (`INACTIVE`, `DELETED`) → từ chối trước khi so mật khẩu.
- Tài khoản tạo từ Google chưa đặt mật khẩu → không đăng nhập bằng mật khẩu được.
- Người dùng chọn quên mật khẩu.
- Người dùng hủy đăng nhập.
- ID token Google không hợp lệ, chưa verify email hoặc chưa cấu hình client ID;
  tài khoản đã bị khóa hoặc vô hiệu.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
