# UC-ADM-CAT-003 — Sửa danh mục

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CAT-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Sửa danh mục theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Danh mục tồn tại.

## Điều kiện sau

Tên/mô tả danh mục được cập nhật.

## Luồng chính

1. Chọn danh mục.
2. Chỉnh sửa tên, tên SEO, mô tả, danh mục cha, thứ tự hiển thị hoặc loại phần cứng. Có thể đặt trạng thái `ACTIVE`/`INACTIVE` để hiện hoặc ẩn danh mục.
3. Lưu thay đổi. Tên và tên SEO chỉ được trùng với chính danh mục này; danh mục cha không được là chính nó hay một danh mục con cháu của nó (tránh vòng lặp).
4. Có thể sắp xếp lại thứ tự các danh mục cùng cấp: mọi danh mục gửi lên phải còn tồn tại và có cùng danh mục cha.
5. Có thể chỉnh mẫu thuộc tính của danh mục: danh sách thuộc tính mô tả sản phẩm trong danh mục (chọn từ danh mục thuộc tính có sẵn, đánh dấu bắt buộc hay không, có thứ tự). Danh mục con kế thừa thuộc tính của danh mục cha; lưu mẫu sẽ thay toàn bộ phần thuộc tính riêng của danh mục, không được lặp một thuộc tính, không được thêm thuộc tính mà danh mục cha đã có hoặc danh mục con đang dùng. Mẫu này là cơ sở kiểm tra specifications khi thêm/sửa sản phẩm.

## Luồng thay thế / ngoại lệ

- Danh mục không tồn tại hoặc đã xóa → từ chối.
- Tên hoặc tên SEO trùng danh mục khác → từ chối.
- Danh mục cha không `ACTIVE`, là chính nó hoặc con cháu của nó → từ chối.
- Đặt trạng thái `DELETED` ở đây → từ chối, phải dùng thao tác xóa (UC-ADM-CAT-004).
- Ẩn danh mục (`INACTIVE`) không ẩn hay chuyển sản phẩm đang thuộc nó; nhưng không gán được sản phẩm mới vào danh mục không `ACTIVE`.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
