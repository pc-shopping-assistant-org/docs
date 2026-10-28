# UC-ADM-CUS-003 — Xem thông tin khách hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CUS-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Hình 19, tr. 51; Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem thông tin khách hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Khách hàng tồn tại.

## Điều kiện sau

Thông tin khách hàng được hiển thị.

## Luồng chính

1. Chọn khách hàng.
2. Hệ thống hiển thị hồ sơ khách: email, số điện thoại, trạng thái tài khoản, họ tên, giới tính, ngày sinh, ảnh đại diện, ngày đăng ký, kèm danh sách địa chỉ (địa chỉ mặc định trước).

## Luồng thay thế / ngoại lệ

- Mã không phải của khách hàng → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
