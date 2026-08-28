# Product Creation Flow

Nguồn: Chương 3.4 — Hình 32, tr. 62.

```mermaid
flowchart TD
    A[Truy cập trang quản trị] --> B[Nhập thông tin sản phẩm]
    B --> C{Kiểm tra ràng buộc}
    C -- Sai --> D[Thông báo lỗi]
    C -- Đúng --> E[Lưu sản phẩm]
```
