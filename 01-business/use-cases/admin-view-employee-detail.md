# UC-ADM-EMP-003 — Xem thông tin chi tiết nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-003` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Hình 20, tr. 52 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem thông tin chi tiết nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`). Nhân viên tồn tại.

## Điều kiện sau

Thông tin chi tiết nhân viên được hiển thị.

## Luồng chính

1. Chọn nhân viên.
2. Hệ thống hiển thị thông tin chi tiết của nhân viên.

## Luồng thay thế / ngoại lệ

- Mã không phải của nhân viên (kể cả khách hàng, quản trị viên) → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
