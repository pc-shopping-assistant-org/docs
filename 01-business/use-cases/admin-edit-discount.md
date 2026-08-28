# UC-ADM-DIS-003 — Cập nhật khuyến mãi

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-003` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 21 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật khuyến mãi theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khuyến mãi tồn tại. Category hoặc variant được chọn làm target phải tồn tại và đang có thể sử dụng.

## Điều kiện sau

Thông tin khuyến mãi được cập nhật.

## Luồng chính

1. Chọn khuyến mãi.
2. Chỉnh sửa thông tin, phạm vi áp dụng và danh sách target.
3. Hệ thống kiểm tra giá trị, thời gian và tính nhất quán giữa scope với target.
4. Hệ thống thay thế thông tin discount cùng target trong một transaction.

## Luồng thay thế / ngoại lệ

- Giá trị hoặc khoảng thời gian không hợp lệ: hệ thống từ chối.
- Scope và target không khớp: hệ thống từ chối toàn bộ thay đổi.
- Code mới trùng với discount khác: hệ thống từ chối.

## Quy tắc nghiệp vụ

- `ORDER` và `ALL_ITEMS` không có target.
- `CATEGORY` phải có ít nhất một category target và không có variant target.
- `VARIANT` phải có ít nhất một variant target và không có category target.
- Việc đổi scope và thay target là atomic; không lưu trạng thái dở dang.
