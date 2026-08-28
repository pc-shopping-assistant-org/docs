# UC-ADM-PROD-007 — Thêm biến thể sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-007` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **IMPLEMENTATION** |
| Nguồn | Chương 5.2.4, tr. 87 |

> **Mức nguồn:** Có bằng chứng giao diện/triển khai ở Chương 5 nhưng Chương 3 không đặc tả đầy đủ.

## Mục tiêu

Thêm biến thể sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Sản phẩm đã tồn tại.

## Điều kiện sau

Biến thể mới được tạo.

## Luồng chính

1. Mở giao diện thêm biến thể.
2. Nhập SKU, `list_price`, tồn kho, số tháng bảo hành và các tùy chọn của variant.
3. Có thể tải nhiều ảnh cho variant; hệ thống lưu metadata vào `files` và tạo `product_images` bằng `file_id`.
4. Chọn tối đa một ảnh đang active làm ảnh chính của variant.
5. Hệ thống kiểm tra mỗi variant không có nhiều option cùng type.
6. Xác nhận.
7. Hệ thống lưu variant, option và gallery ảnh trong một transaction.

## Luồng thay thế / ngoại lệ

- Chương 3 không có formal use case riêng; chi tiết rule chưa được đặc tả.
- SKU hoặc barcode bị trùng.
- `list_price` hoặc tồn kho âm; số tháng bảo hành không dương.
- File ảnh không hợp lệ hoặc upload thất bại.
- Có nhiều ảnh active cùng được đánh dấu main.
- Tên option bị trùng.
- Variant có nhiều option cùng type.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
