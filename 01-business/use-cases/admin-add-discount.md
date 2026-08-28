# UC-ADM-DIS-002 — Thêm giảm giá

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-002` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 54 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm giảm giá theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Quản lý đã đăng nhập. Category hoặc variant được chọn làm target phải tồn tại và đang có thể sử dụng.

## Điều kiện sau

Chương trình/mã giảm giá được tạo.

## Luồng chính

1. Chọn thêm giảm giá.
2. Hệ thống hiển thị form.
3. Nhập title, code nếu là voucher, loại giảm (`PERCENT` hoặc `FIXED`), giá trị, thời gian hiệu lực, giá trị đơn tối thiểu và phạm vi áp dụng.
4. Nếu phạm vi là `CATEGORY` hoặc `VARIANT`, chọn ít nhất một target tương ứng.
5. Hệ thống kiểm tra giá trị, thời gian và tính nhất quán giữa scope với target.
6. Hệ thống lưu discount cùng toàn bộ target trong một transaction và cập nhật danh sách.

## Luồng thay thế / ngoại lệ

- `PERCENT` không nằm trong khoảng `(0, 100]`, hoặc `FIXED` không lớn hơn `0`.
- Thời điểm bắt đầu không trước thời điểm kết thúc.
- `ORDER` hoặc `ALL_ITEMS` có target: hệ thống từ chối.
- `CATEGORY` không có category target hoặc có variant target: hệ thống từ chối.
- `VARIANT` không có variant target hoặc có category target: hệ thống từ chối.
- Code đã tồn tại: hệ thống từ chối và yêu cầu dùng code khác.

## Quy tắc nghiệp vụ

- `code` là optional; promotion tự động có thể không cần mã nhập tay.
- Mỗi discount chỉ có một `application_scope`: `ORDER`, `ALL_ITEMS`, `CATEGORY` hoặc `VARIANT`.
- Target phải đúng với scope tại thời điểm transaction commit.
