# UC-ADM-PROD-006 — Ẩn/ngừng trưng bày sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-006` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 51 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Ẩn/ngừng trưng bày sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Sản phẩm tồn tại.

## Điều kiện sau

Sản phẩm được ngừng trưng bày.

## Luồng chính

1. Chọn ẩn sản phẩm.
2. Hệ thống yêu cầu xác nhận.
3. Nhân viên xác nhận.
4. Hệ thống đặt trạng thái `INACTIVE` và ghi người thực hiện. Đặt lại `ACTIVE` để hiện lại; đặt `DELETED` bị từ chối vì xóa có quy tắc riêng.
5. Sản phẩm `INACTIVE` biến mất khỏi danh sách, tìm kiếm và trang chi tiết công khai, không thêm được vào giỏ và không đặt hàng được; các dòng đã có trong giỏ hiển thị là không khả dụng. Đơn đã đặt không bị ảnh hưởng. Nhân viên vẫn thấy và sửa được sản phẩm, vẫn thêm variant cho nó, và đánh giá cũ vẫn xem được nhưng khách không sửa được đánh giá của sản phẩm đang ẩn.

## Luồng thay thế / ngoại lệ

- Người dùng hủy thao tác → không đổi gì.
- Sản phẩm không tồn tại hoặc đã xóa → từ chối.
- Trạng thái gửi lên là `DELETED` → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
