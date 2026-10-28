# Login Flow

Nguồn: Chương 3.4 — Hình 29, tr. 61.

```mermaid
flowchart TD
    A[Nhập thông tin đăng nhập] --> B{Có tài khoản?}
    B -- Không --> C[Đăng ký]
    B -- Có --> D{Quên mật khẩu?}
    D -- Có --> E[Khôi phục mật khẩu]
    D -- Không --> F[Nhập email/phone và mật khẩu]
    F --> G{Tài khoản ACTIVE?}
    G -- Không --> H[Thông báo tài khoản bị khóa/không hoạt động]
    H --> A
    G -- Có --> J{Mật khẩu khớp?}
    J -- Không --> K[Thông báo sai thông tin đăng nhập]
    K --> A
    J -- Có --> I[Phát hành access token + refresh token]
    A --> L[Tiếp tục với Google]
    L --> M{ID token hợp lệ, email đã verify?}
    M -- Không --> K
    M -- Có --> N[Tìm/liên kết/tạo tài khoản khách hàng theo Google sub]
    N --> G
```

Identity đăng nhập được chốt tại `accounts.email` hoặc `accounts.phone`; không hỗ trợ username riêng.

Trạng thái tài khoản được kiểm tra trước mật khẩu. Email/số điện thoại không tồn tại và mật khẩu sai cho cùng một thông báo. Khi access token hết hạn, client đổi refresh token lấy cặp token mới (`POST /auth/refresh-token`); refresh token bị thu hồi bởi đăng xuất hoặc khóa tài khoản thì không dùng được nữa.
