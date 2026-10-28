# Product Creation Flow

Nguồn: Chương 3.4 — Hình 32, tr. 62.

```mermaid
flowchart TD
    A[Truy cập trang quản trị] --> B[Nhập thông tin sản phẩm]
    B --> C{Kiểm tra product/category}
    C -- Sai --> D[Thông báo lỗi]
    C -- Đúng --> L{Specifications khớp mẫu thuộc tính của category?}
    L -- Không --> D
    L -- Có --> E[Lưu product ACTIVE + gallery product_images]
    E --> F[Thêm variant/SKU]
    F --> G[Tải ảnh riêng của variant nếu có]
    G --> H[Lưu metadata vào files]
    H --> I{Kiểm tra giá, stock, option, SKU/barcode}
    I -- Sai --> J[Báo lỗi, variant không được lưu]
    I -- Đúng --> K[Lưu variant và options]
```

Tạo sản phẩm và thêm variant là hai thao tác riêng, mỗi thao tác một transaction. Variant lỗi không làm mất sản phẩm đã lưu ở bước trước, mà sản phẩm giữ nguyên chưa có variant. Sản phẩm không có variant `ACTIVE` chưa hiện ở trang công khai nên nhân viên cần thêm ít nhất một variant. Gallery (ảnh chính, tối đa một) thuộc cấp product, được lưu cùng lúc với product; ảnh riêng của variant lưu cùng variant. Ảnh được tải lên Media Service trước và product/variant chỉ giữ `fileId`.

Sau khi lưu, Debezium đọc thay đổi và sync-service dựng lại document tìm kiếm của sản phẩm (xem UC-CAT-003), nên sản phẩm mới tìm được sau vài giây.
