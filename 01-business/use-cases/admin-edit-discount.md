# UC-ADM-DIS-003 — Cập nhật khuyến mãi

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 21 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật khuyến mãi theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Khuyến mãi tồn tại. Category được chọn làm target phải tồn tại và đang có thể sử dụng.

## Điều kiện sau

Thông tin khuyến mãi được cập nhật.

## Luồng chính

1. Chọn khuyến mãi.
2. Chỉnh sửa thông tin, mã (nếu cần), phạm vi áp dụng và danh sách danh mục áp dụng. Không gửi mã thì giữ mã hiện tại; mã rỗng thì xóa mã. Mã phải duy nhất và chỉ hợp lệ với phạm vi `ORDER`.
3. Hệ thống kiểm tra giá trị, thời gian và tính nhất quán giữa phạm vi với danh mục áp dụng (`ORDER` và `ALL_ITEMS` không có danh mục; `CATEGORY` phải có ít nhất một).
4. Hệ thống khóa dòng discount rồi thay thế thông tin cùng danh mục áp dụng trong một transaction (đổi phạm vi và thay danh mục là nguyên tử, không lưu trạng thái dở dang), ghi người thực hiện. Trạng thái khóa/mở không đổi ở đây (xem UC-ADM-DIS-005). Sửa có hiệu lực ngay cho các lần tính giá sau; đơn đã đặt giữ nguyên số tiền giảm đã snapshot.

## Luồng thay thế / ngoại lệ

- Giá trị hoặc khoảng thời gian không hợp lệ → từ chối.
- Phạm vi và danh mục áp dụng không khớp → từ chối toàn bộ thay đổi; danh mục không còn dùng cũng bị từ chối.
- Mã mới trùng với discount khác → từ chối; có mã mà phạm vi không phải `ORDER` → từ chối.
- Discount không tồn tại hoặc đã xóa → từ chối.

