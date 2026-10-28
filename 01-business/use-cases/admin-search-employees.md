# UC-ADM-EMP-002 — Tìm kiếm nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-002` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Hình 20, tr. 52 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`).

## Điều kiện sau

Nhân viên phù hợp được hiển thị.

## Luồng chính

1. Nhập điều kiện tìm kiếm: từ khóa và/hoặc trạng thái tài khoản (`ACTIVE`, `INACTIVE`, `LOCKED`, `DELETED`).
2. Hệ thống tìm: từ khóa khớp một phần họ tên (cả hai thứ tự), email hoặc số điện thoại; bỏ trống điều kiện nào thì không lọc theo điều kiện đó.
3. Hiển thị kết quả.

## Luồng thay thế / ngoại lệ

- Không có kết quả → danh sách rỗng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
