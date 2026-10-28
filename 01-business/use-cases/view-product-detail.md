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

Khách hàng đã truy cập hệ thống (không cần đăng nhập).

## Điều kiện sau

Thông tin chi tiết sản phẩm được hiển thị.

## Luồng chính

1. Khách hàng mở trang sản phẩm.
2. Hệ thống hiển thị danh sách sản phẩm.
3. Khách hàng chọn một sản phẩm.
4. Hệ thống hiển thị chi tiết product (tên, thương hiệu, danh mục, loại phần cứng, mô tả, thông số kỹ thuật) và các variant đang bán (`ACTIVE`) với giá, số lượng tồn, SKU, model, bảo hành và các option. Chi tiết mở được theo id hoặc theo `seoName` (dùng cho URL trang sản phẩm).
5. Hệ thống tải gallery `product_images` của product; ảnh `is_main` là thumbnail/ảnh chính được hiển thị đầu tiên.
6. Khi khách hàng chọn variant có `image_file_id`, hệ thống hiển thị ảnh riêng của variant đó; variant không có ảnh riêng thì dùng ảnh của product.
7. URL ảnh được resolve từ file storage metadata (`files.public_url` ở Media Service) theo `image_file_id`.
8. Đánh giá của khách hàng đã mua hiển thị ở cuối trang (xem UC-REV-001).

## Luồng thay thế / ngoại lệ

- Sản phẩm không tồn tại hoặc không còn `ACTIVE` (đã ẩn, đã xóa) → thông báo không tìm thấy, không phân biệt hai trường hợp.
- Variant không `ACTIVE` không có trong danh sách variant; variant hết hàng (`quantity = 0`) vẫn được hiển thị để khách thấy sản phẩm, việc chặn mua nằm ở giỏ hàng/đặt hàng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
