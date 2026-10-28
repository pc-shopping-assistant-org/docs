# UC-ADM-EMP-001 — Xem danh sách nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-001` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Hình 20, tr. 52 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh sách nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`).

## Điều kiện sau

Danh sách nhân viên được hiển thị.

## Luồng chính

1. Mở quản lý nhân viên.
2. Hệ thống tải danh sách nhân viên, mới tạo trước, phân trang (mỗi trang tối đa 100). Mỗi dòng có ảnh đại diện. Nhân viên đã xóa không hiện trừ khi lọc theo trạng thái `DELETED`.

## Luồng thay thế / ngoại lệ

- Chưa có nhân viên nào → danh sách rỗng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
