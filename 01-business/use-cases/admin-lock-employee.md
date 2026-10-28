# UC-ADM-EMP-006 — Khóa tài khoản nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-006` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 53 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Khóa tài khoản nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`). Tài khoản nhân viên tồn tại.

## Điều kiện sau

Tài khoản nhân viên bị khóa.

## Luồng chính

1. Chọn tài khoản nhân viên.
2. Chọn khóa.
3. Hệ thống yêu cầu xác nhận.
4. Xác nhận.
5. Hệ thống đặt trạng thái `LOCKED` và ghi mốc thu hồi token (cùng cơ chế đăng xuất) trong một transaction; không khóa được nếu hệ thống thu hồi token không khả dụng. Nhân viên bị chặn đăng nhập và mọi token đang dùng mất hiệu lực. Hệ thống không có chức năng mở khóa.
6. Ngoài khóa, quản trị viên còn vô hiệu hóa (`ACTIVE` → `INACTIVE`, thu hồi token), kích hoạt lại (`INACTIVE` → `ACTIVE`, không mở khóa được tài khoản `LOCKED`) và xóa mềm (→ `DELETED`, thu hồi token, không khôi phục được; email và số điện thoại vẫn bị chiếm). Tài khoản `DELETED` không sửa, không khóa được và không hiện trong danh sách trừ khi lọc theo trạng thái này. Nhân viên `INACTIVE`/`DELETED` bị từ chối đăng nhập.

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Tài khoản đã bị khóa, hoặc trạng thái hiện tại không cho phép thao tác → từ chối.
- Không phải tài khoản nhân viên → xử lý như không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
