# UC-ADM-CUS-002 — Tìm kiếm/lọc khách hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CUS-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 19 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm/lọc khách hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Khách hàng phù hợp được hiển thị.

## Luồng chính

1. Nhập tên, số điện thoại hoặc email và/hoặc điều kiện lọc: trạng thái tài khoản (`ACTIVE`, `INACTIVE`, `LOCKED`, `DELETED`) và khoảng ngày đăng ký (từ ngày gồm, đến ngày không gồm; ngày bắt đầu phải trước ngày kết thúc).
2. Hệ thống tìm kiếm: từ khóa khớp một phần họ tên (cả hai thứ tự), email hoặc số điện thoại; mọi điều kiện đều tùy chọn và kết hợp bằng AND.
3. Hiển thị kết quả.

## Luồng thay thế / ngoại lệ

- Không có kết quả → danh sách rỗng.
- Khoảng ngày đăng ký sai → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
