# Order Flow

Nguồn: Chương 3.4 — Hình 30, tr. 61 và UC đặt hàng tr. 57.

```mermaid
flowchart TD
    A[Đăng nhập/đăng ký hoặc xác thực] --> B[Chọn sản phẩm]
    B --> C[Thêm vào giỏ]
    C --> D[Xem giỏ hàng]
    D --> E{Mua thêm?}
    E -- Có --> B
    E -- Không --> F[Nhập/chọn thông tin giao hàng]
    F --> G[Chọn phương thức thanh toán]
    G --> H[Nhập mã giảm giá nếu có]
    H --> I[Xác nhận]
    I --> J[Tạo đơn hàng]
```

Giỏ hàng chỉ có cho khách đã đăng nhập, nên bước đầu của luồng bắt buộc là đăng nhập. Khi bấm xác nhận, hệ thống gộp bước "Tạo đơn hàng" thành một transaction ở Order Service (kiểm tra giỏ, snapshot giá/địa chỉ/phí giao, áp discount, lưu đơn, xóa các dòng giỏ, ghi lệnh giữ tồn kho vào outbox); client gửi kèm `idempotencyKey` nên gửi lại không tạo đơn thứ hai.

Sau bước tạo đơn, việc còn lại chạy bất đồng bộ qua saga:

```mermaid
sequenceDiagram
    participant C as Khách hàng
    participant O as Order Service
    participant K as Catalog Service
    participant P as Payment Service
    C->>O: POST /orders (idempotencyKey)
    O-->>C: 201, đơn PENDING_PAYMENT (online) / PENDING_CONFIRMATION (COD)
    O->>K: ReserveStockCommand (RabbitMQ, outbox)
    alt giữ được tồn kho
        K-->>O: stock.reserved (Kafka)
        O->>P: tạo payment PENDING (khóa = id đơn)
        opt thanh toán online
            C->>P: lấy URL VNPAY, thanh toán
            P-->>O: payment.completed -> PENDING_CONFIRMATION
            P-->>O: payment.failed -> CANCELLED + trả tồn kho
        end
    else không giữ được
        K-->>O: stock.reserve-failed -> đơn CANCELLED
    end
```

- Online: order `PENDING_PAYMENT` → payment `PAID` → order `PENDING_CONFIRMATION`. Payment thất bại thì đơn bị hủy và trả tồn kho, không ở lại `PENDING_PAYMENT`.
- COD: order `PENDING_CONFIRMATION` → nhân viên xác nhận → `CONFIRMED`.
- Cả hai nhánh tiếp tục `SHIPPING` → giao thành công → `COMPLETED`.
- Khách hủy được khi đơn còn `PENDING_PAYMENT`/`PENDING_CONFIRMATION`.
