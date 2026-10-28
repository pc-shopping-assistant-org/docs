# System Architecture — Microservices

```mermaid
%%{init: {'theme': 'base', 'look': 'handDrawn'}}%%
graph TD
    Client["Web/Admin Frontend"] --> GW["API Gateway"]

    GW --> IS["Identity Service"]
    GW --> CatS["Catalog Service"]
    GW --> PrS["Promotion Service"]
    GW --> OS["Order Service"]
    GW --> Pay["Payment Service"]
    GW --> MS["Media Service"]
    GW --> SS["Search Service"]
    GW --> Sync["Sync Service"]

    %% Database-per-Microservice
    IS --> DB_Id[("Identity DB")]
    CatS --> DB_Cat[("Catalog DB")]
    PrS --> DB_Pr[("Promotion DB")]
    OS --> DB_Order[("Order DB")]
    Pay --> DB_Pay[("Payment DB")]
    MS --> DB_Media[("Media DB / Object Storage")]
    SS --> ES[("Elasticsearch")]
    Sync --> ES

    %% Async Data Flows - CDC to Search
    DB_Cat -.->|Debezium CDC: catalog.changed| Kafka{{"Kafka"}}
    Kafka -.-> Sync
    Sync -.->|HTTP: dựng document| CatS

    %% Checkout Saga (Order Service điều phối)
    OS -.->|RabbitMQ: giữ / trả tồn kho| CatS
    CatS -.->|Kafka: stock.reserved / reserve-failed| OS
    OS -->|HTTP: tạo payment| Pay
    Pay -.->|Kafka: payment.completed / failed| OS
    OS -.->|Kafka: order.cancelled| Pay
```

Chi tiết từng luồng nằm ở [service-communication.md](service-communication.md).

## Service và phạm vi (scope)

| Service | Scope |
|---|---|
| **Identity Service** | Xác thực (mật khẩu, Google), tài khoản, vai trò, hồ sơ quản trị viên/nhân viên/khách hàng, địa chỉ giao hàng |
| **Catalog Service** | Loại phần cứng, thương hiệu, danh mục, thuộc tính, sản phẩm, biến thể, tồn kho, ảnh, option, đánh giá sản phẩm; phát lệnh/sự kiện kho qua outbox |
| **Promotion Service** | Khuyến mãi theo đơn, mọi dòng hàng hoặc danh mục (voucher có mã hoặc tự động) |
| **Order Service** | Giỏ hàng (mỗi khách một giỏ), đơn hàng, dòng đơn hàng, lịch sử trạng thái, phương thức vận chuyển; điều phối saga đặt hàng |
| **Payment Service** | Phương thức thanh toán (COD, VNPAY), giao dịch thanh toán, callback VNPAY |
| **Media Service** | Lưu trữ và phục vụ file (ảnh sản phẩm, avatar, logo...) |
| **Search Service** | Tìm kiếm/lọc sản phẩm trên Elasticsearch |
| **Sync Service** | Đọc `catalog.changed` (CDC của Catalog DB) và dựng lại document trong Elasticsearch; không có bảng riêng |

Mỗi service có database riêng; khóa ngoại giữa các service chỉ là tham chiếu logic, không có FK ở DB. Bảng `outbox_events` và `inbox_events` có ở Catalog, Order và Payment (xem service-communication.md).
