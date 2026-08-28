# Domain Overview

## 1. Domain

Hệ thống thuộc miền **thương mại điện tử thiết bị điện tử/công nghệ**, kết hợp một phân hệ **AI-assisted shopping** nhằm hỗ trợ người dùng tìm kiếm và ra quyết định mua sắm.

Hai mảng nghiệp vụ chính:

```text
E-commerce Core
├── Identity & Account
├── Catalog
├── Search & Filtering
├── Cart
├── Ordering
├── Payment
├── Review
└── Back-office Management

AI-assisted Shopping
├── Natural-language Query
├── Semantic Search
├── Retrieval / RAG
├── Product Consultation
├── Product Comparison
└── Product Evaluation
```

## 2. Actors

### Khách hàng

Mục tiêu: tìm được sản phẩm phù hợp và hoàn tất quá trình mua hàng.

Tương tác chính:

```text
Browse/Search
    ↓
View Product
    ↓
Consult / Compare with AI
    ↓
Add to Cart
    ↓
Order
    ↓
Payment
    ↓
Track Order
    ↓
Review after purchase
```

### Quản lý cửa hàng

Mục tiêu: vận hành dữ liệu và các quy trình bán hàng cơ bản.

```text
Products / Categories / Suppliers
              ↓
           Catalog
              ↓
Orders ← Customers → Payments
   ↓
Promotions
```

## 3. Core business concepts

### Product & Variant

`Product` là thực thể sản phẩm logic, còn `Product Variant/SKU` là đơn vị bán cụ thể. Một product có thể có nhiều variant, ví dụ iPhone 16 Pro Black/256GB, Black/512GB và White/256GB.

Một product thuộc đúng một category chính. Category hỗ trợ cây phân cấp qua `categories.parent_id`, ví dụ `Điện thoại -> iPhone -> iPhone 16 Pro`.

Các nhóm merchandising hoặc campaign như `Gaming`, `Hot`, `Best Seller`, `Back to School` không được nhét vào category; nếu cần sẽ là collection/tag riêng.

### Search

Có hai hướng:

1. Tìm kiếm/lọc truyền thống theo tên, phân loại, nhãn hiệu, giá.
2. Tìm kiếm theo nhu cầu/ngữ nghĩa qua Semantic Search và AI Agent.

### AI Consultation

AI Agent tiếp nhận truy vấn tiếng Việt tự nhiên, truy xuất thông tin liên quan, tạo ngữ cảnh và sinh phản hồi. Kết quả có thể kèm danh sách sản phẩm liên quan để người dùng tiếp tục xem và so sánh.

### Cart & Order

Giỏ hàng chứa các sản phẩm chuẩn bị mua. Đơn hàng được tạo từ giỏ, sau đó người dùng cung cấp/chọn thông tin giao hàng, phương thức vận chuyển và phương thức thanh toán. Phí vận chuyển được ghi nhận theo giá tại thời điểm checkout.

### Payment

Payment method được quản lý riêng (ví dụ COD, Stripe card, bank transfer). Mỗi order có thể có nhiều payment attempt; mỗi attempt có amount và trạng thái `PENDING`, `PAID` hoặc `FAILED` để giữ lịch sử retry và đối soát provider.

### Review

Khách hàng được mô tả là đánh giá sản phẩm sau khi mua.

## 4. AI domain flow theo report

```text
User Query
    ↓
Query Embedding
    ↓
Semantic / Vector Retrieval
    ↓
Relevant Product / Context Data
    ↓
Prompt + Context
    ↓
LLM / AI Agent
    ↓
Response + Related Products
```

Report mô tả AI Agent theo hướng Orchestrator-Workers kết hợp RAG; chi tiết orchestration có thay đổi trong quá trình phát triển multi-LLM nhưng business outcome vẫn là hỗ trợ tư vấn/so sánh/đánh giá.

## 5. Domain boundaries

### Thuộc domain chính

- Thiết bị điện tử/công nghệ.
- Dữ liệu sản phẩm của cửa hàng.
- Nhu cầu mua sắm diễn đạt bằng tiếng Việt.
- So sánh/đánh giá/tư vấn dựa trên dữ liệu sản phẩm và nguồn dữ liệu liên quan.

### Không được report định nghĩa như một domain riêng

- PC-part compatibility engine.
- BOM/build PC optimization.
- Logistics/warehouse management chuyên sâu.
- Procurement chuyên sâu.

## Nguồn report

- Chương 1, trang 2–4.
- Chương 2.1, trang 5–7.
- Chương 2.2.6–2.2.7, trang 25–29.
- Chương 3.1, trang 39–43.
- Chương 4.2.3, trang 66–67.
