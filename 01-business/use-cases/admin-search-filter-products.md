# UC-ADM-PROD-002 — Tìm kiếm/lọc sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm/lọc sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách được lọc theo điều kiện.

## Luồng chính

1. Nhập điều kiện tìm kiếm/lọc: từ khóa, danh mục, thương hiệu, trạng thái (`ACTIVE` hoặc `INACTIVE`), khoảng giá.
2. Hệ thống xử lý trong Catalog Service, không qua dịch vụ tìm kiếm. Từ khóa khớp một phần tên, tên SEO hoặc mô tả, không phân biệt hoa thường; danh mục khớp cả danh mục con; khoảng giá khớp khi ít nhất một variant (đang hoạt động hay ẩn) có giá trong khoảng. Không chọn trạng thái thì gồm cả `ACTIVE` và `INACTIVE`.
3. Hiển thị kết quả phân trang như danh sách quản trị.

## Luồng thay thế / ngoại lệ

- Không có kết quả → danh sách rỗng.
- Lọc theo trạng thái `DELETED` → từ chối; khoảng giá sai → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
