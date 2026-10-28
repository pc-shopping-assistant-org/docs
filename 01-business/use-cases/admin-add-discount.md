# UC-ADM-DIS-002 — Thêm giảm giá

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 54 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm giảm giá theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Category được chọn làm target phải tồn tại và đang có thể sử dụng.

## Điều kiện sau

Chương trình/mã giảm giá được tạo.

## Luồng chính

1. Chọn thêm giảm giá.
2. Hệ thống hiển thị form.
3. Nhập tiêu đề, mã nếu là voucher, loại giảm (`PERCENT` hoặc `FIXED`), giá trị, thời gian hiệu lực, giá trị đơn tối thiểu và phạm vi áp dụng (`ORDER`, `ALL_ITEMS` hoặc `CATEGORY`).
4. Nếu phạm vi là `CATEGORY`, chọn ít nhất một danh mục áp dụng; `ORDER` và `ALL_ITEMS` không có danh mục áp dụng.
5. Hệ thống kiểm tra giá trị, thời gian và tính nhất quán giữa phạm vi với danh mục áp dụng.
6. Hệ thống lưu discount cùng toàn bộ danh mục áp dụng trong một transaction, ghi nhân viên thực hiện, và cập nhật danh sách. Discount mới có trạng thái lưu `ACTIVE`; có đang chạy hay không tùy thời gian hiệu lực. Mã được chuẩn hóa thành chữ hoa.
7. Mã là tùy chọn và chỉ dùng với phạm vi `ORDER` (voucher khách nhập, hoặc để trống cho khuyến mãi tự động); `ALL_ITEMS` và `CATEGORY` không có mã. Khi đặt hàng, mỗi dòng hàng được áp một discount `ALL_ITEMS`/`CATEGORY` đang hiệu lực cho mức giảm lớn nhất, rồi trừ một discount cấp đơn lên phần còn lại (xem UC-ORD-001). Giảm `PERCENT` làm tròn xuống, `FIXED` không vượt quá số tiền được giảm.

## Luồng thay thế / ngoại lệ

- `PERCENT` không nằm trong khoảng `(0, 100]`, hoặc `FIXED` không lớn hơn 0; thời điểm bắt đầu không trước thời điểm kết thúc; giá trị đơn tối thiểu âm → từ chối.
- `ORDER` hoặc `ALL_ITEMS` có danh mục áp dụng; `CATEGORY` không có danh mục áp dụng → từ chối.
- Danh mục áp dụng không tồn tại hoặc không còn dùng (hỏi Catalog Service) → từ chối.
- Mã đã tồn tại (không phân biệt hoa thường, bỏ qua discount đã xóa) → yêu cầu dùng mã khác.
- Có mã nhưng phạm vi không phải `ORDER` → từ chối.
- Catalog Service không trả lời khi kiểm tra danh mục → báo lỗi, không lưu.

