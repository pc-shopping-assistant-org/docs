# Payment Flow

Nguồn: Chương 3.4 — Hình 31, tr. 62; state diagram thanh toán tr. 60.

Checkout có hai nhánh chính: COD và thanh toán online. Hai nhánh chỉ khác thời điểm ghi nhận `Payment.PAID` và order status.

```mermaid
flowchart TD
    A[Checkout] --> B{Phương thức}
    B -- Online --> C[Tạo order: PENDING_PAYMENT]
    C --> D[Xử lý payment]
    D --> E{Payment PAID?}
    E -- Không --> F[Payment FAILED; order vẫn PENDING_PAYMENT theo policy]
    E -- Có --> G[Order: PENDING_CONFIRMATION]
    G --> H[Admin confirm]
    H --> I[Order: CONFIRMED]

    B -- COD --> J[Tạo order: PENDING_CONFIRMATION]
    J --> H
    I --> K[Order: SHIPPING]
    K --> L[Delivered]
    L --> M{COD?}
    M -- Có --> N[Thu tiền, Payment: PAID]
    M -- Không --> O[Payment đã PAID]
    N --> P[Order: COMPLETED]
    O --> P
```
