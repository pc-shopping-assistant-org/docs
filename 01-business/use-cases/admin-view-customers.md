# UC-ADM-CUS-001 — Xem danh sách khách hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CUS-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 19 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh sách khách hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách khách hàng được hiển thị.

## Luồng chính

1. Mở quản lý khách hàng.
2. Hệ thống tải và hiển thị danh sách khách, đăng ký mới nhất trước, phân trang (mỗi trang tối đa 100). Mỗi dòng có ảnh đại diện.

## Luồng thay thế / ngoại lệ

- Chưa có khách nào → danh sách rỗng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
