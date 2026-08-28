# UC-CAT-001 — Xem chi tiết sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CAT-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 58 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Xem chi tiết sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng đã truy cập hệ thống.

## Điều kiện sau

Thông tin chi tiết sản phẩm được hiển thị.

## Luồng chính

1. Khách hàng mở trang sản phẩm.
2. Hệ thống hiển thị danh sách sản phẩm.
3. Khách hàng chọn một sản phẩm.
4. Hệ thống hiển thị chi tiết product và các variant đang bán.
5. Khi khách hàng chọn variant, hệ thống tải gallery `product_images` đang active của variant đó.
6. Ảnh main của variant được ưu tiên hiển thị; URL được resolve từ file storage metadata.

## Luồng thay thế / ngoại lệ

- Không được report đặc tả thêm.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
