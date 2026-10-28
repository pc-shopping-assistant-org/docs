# Payment Flow

Nguồn: Chương 3.4 — Hình 31, tr. 62; state diagram thanh toán tr. 60.

Checkout có hai nhánh chính: COD và thanh toán online. Hai nhánh chỉ khác thời điểm ghi nhận `Payment.PAID` và order status.

```mermaid
flowchart TD
    A[Checkout] --> B{Phương thức}
    B -- Online --> C[Tạo order: PENDING_PAYMENT]
    C --> D[Xử lý payment: VNPAY trả kết quả qua callback IPN/return có chữ ký]
    D --> E{Payment PAID?}
    E -- Không --> F[Payment FAILED; order CANCELLED, trả tồn kho]
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

Thứ tự trong thực tế hơi khác sơ đồ ở một điểm: đơn chuyển `COMPLETED` do nhân viên đẩy trạng thái và không kiểm tra payment; với COD nhân viên đánh dấu payment `PAID` bằng thao tác riêng (UC-ADM-PAY-002), có thể trước hoặc sau khi hoàn tất đơn.
