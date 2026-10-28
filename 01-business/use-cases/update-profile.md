# UC-AUTH-006 — Cập nhật thông tin cá nhân

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-006` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật thông tin cá nhân theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`).

## Điều kiện sau

Thông tin cá nhân được cập nhật.

## Luồng chính

1. Mở thông tin cá nhân.
2. Chỉnh sửa thông tin profile như họ, tên (bắt buộc, tối đa 50 ký tự), giới tính và ngày sinh (phải là ngày trong quá khứ).
3. Người dùng có thể tải ảnh đại diện mới lên Media Service trước; ảnh nhận được một `fileId`.
4. Khi lưu, hệ thống kiểm tra file ảnh có tồn tại ở Media Service rồi gán `customers.avatar_file_id`. Không chọn ảnh mới thì giữ ảnh hiện tại.
5. Nếu đổi số điện thoại, hệ thống kiểm tra không trùng với tài khoản khác rồi cập nhật `accounts.phone`; hiện chưa yêu cầu OTP xác minh. Email là định danh đăng nhập nên không đổi được ở đây.
6. Địa chỉ giao hàng được quản lý riêng qua `customer_addresses`, không lưu trực tiếp trên customer profile: khách xem danh sách địa chỉ (địa chỉ mặc định đứng đầu), thêm (địa chỉ đầu tiên tự thành mặc định), sửa tên người nhận, số điện thoại, địa chỉ, chọn địa chỉ mặc định hoặc xóa địa chỉ của mình. Xóa địa chỉ mặc định không tự chọn địa chỉ khác thay thế. Mỗi khách chỉ có một địa chỉ mặc định.
7. Khi đặt hàng, khách có thể chọn một địa chỉ đã lưu; đơn vẫn snapshot thông tin người nhận nên sửa địa chỉ về sau không đổi lịch sử đơn.
8. Hệ thống lưu thay đổi.

## Luồng thay thế / ngoại lệ

- Số điện thoại trùng tài khoản khác hoặc dữ liệu không hợp lệ.
- Tài khoản không phải khách hàng (không có hồ sơ customer) → từ chối.
- File ảnh không đúng loại hoặc upload thất bại → không có `fileId`, avatar hiện tại giữ nguyên.
- Ảnh đại diện không tồn tại ở Media Service → từ chối cả lần lưu.
- Địa chỉ không thuộc khách hàng hiện tại → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
