# UC-ADM-PROD-003 — Thêm sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-003` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 49 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Quản lý đã đăng nhập.

## Điều kiện sau

Sản phẩm mới được lưu.

## Luồng chính

1. Chọn thêm sản phẩm.
2. Hệ thống hiển thị form.
3. Nhập thông tin product và chọn đúng một category chính.
4. Chọn không, một hoặc nhiều supplier đang active nếu có.
5. Nhập specifications và mô tả nếu có.
6. Xác nhận.
7. Hệ thống lưu product cùng các liên kết `product_suppliers` trong một transaction và thông báo thành công.

## Luồng thay thế / ngoại lệ

- Thông tin không hợp lệ → yêu cầu chỉnh sửa.
- Category không tồn tại hoặc không thể sử dụng → từ chối lưu.
- Supplier được chọn không tồn tại hoặc không active → từ chối lưu.

Ảnh được quản lý theo variant trong use case thêm biến thể; product không giữ URL hoặc file ảnh trực tiếp.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
