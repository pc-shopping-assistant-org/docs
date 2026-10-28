# Database Design

Mỗi service có database PostgreSQL riêng và tự quản lý schema bằng Flyway (`src/main/resources/db/migration` của từng service). Migration là nguồn sự thật; tài liệu này giải thích các quyết định thiết kế, còn danh sách bảng/cột nằm ở [db.dbml](../02-architecture/db.dbml). Khóa ngoại giữa các service chỉ là tham chiếu logic, không có FK ở database.

## Database checks

`note` trong DBML chỉ dùng để mô tả. Các điều kiện chính được triển khai thành `CHECK` constraint trong migration:

```sql
CHECK (rating BETWEEN 1 AND 5)
CHECK (product_variants.quantity >= 0)
CHECK (product_variants.price >= 0)
CHECK (product_variants.warranty_months > 0)
CHECK (cart_items.quantity > 0)
CHECK (order_items.quantity > 0)
CHECK (order_items.unit_price >= 0)
CHECK (order_items.discount_amount >= 0)
CHECK (order_items.discount_amount <= quantity * unit_price)
CHECK (orders.shipping_fee >= 0)
CHECK (orders.discount_amount >= 0 AND orders.discount_amount <= orders.subtotal_amount)
CHECK (orders.total_amount = subtotal_amount - discount_amount + shipping_fee)
CHECK (orders.status <> 'COMPLETED' OR delivered_at IS NOT NULL)
CHECK (shipping_methods.fee >= 0)
CHECK (payments.amount >= 0)
CHECK (payments.status NOT IN ('PAID', 'REFUNDED') OR paid_at IS NOT NULL)
CHECK (discounts.start_at < end_at)
CHECK (discounts.min_order_amount >= 0)
CHECK (discounts.application_scope IN ('ORDER', 'ALL_ITEMS', 'CATEGORY'))
CHECK (product_reviews.edited_at IS NULL
       OR edited_at BETWEEN created_at AND created_at + interval '30 days')
```

Giá trị giảm phụ thuộc loại giảm:

```sql
CHECK (
  (discount_type = 'PERCENT' AND value BETWEEN 1 AND 100)
  OR (discount_type = 'FIXED' AND value > 0)
)
```

## Account and profile ownership

`accounts` là source of truth cho đăng nhập và identity:

- `email` unique; `phone` unique nhưng nullable (tài khoản tạo từ Google chưa có số điện thoại);
- `password_hash` lưu credential đã hash, nullable với tài khoản chỉ dùng Google;
- `google_subject` là mã `sub` nullable, unique khi có giá trị; chỉ lưu sau khi backend verify ID token, và tài khoản tạo từ Google luôn có kèm profile `customers`;
- `role_id` xác định vai trò (`ROLE_CUSTOMER`, `ROLE_EMPLOYEE`, `ROLE_ADMIN`);
- `status` (`ACTIVE`, `INACTIVE`, `LOCKED`, `DELETED`) điều khiển quyền đăng nhập.

`customers`, `employees` và `admins` là profile 1–1, dùng `account_id` vừa là primary key vừa là foreign key tới `accounts.id`. Các bảng profile không duplicate email/phone. Khi account bị khóa hoặc xóa mềm, profile vẫn được giữ nguyên.

Customer không có `point` vì chưa có loyalty domain hoặc rule tích điểm. Bảng `employees` hiện không lưu lương hay ngày vào làm.

## File and media ownership

`files` (Media Service) là registry chung cho metadata của file; entity khác chỉ giữ `file_id` (tham chiếu logic). Storage identity duy nhất là `(storage_provider, storage_key)`.

`public_url` là optional cache/public address, không phải identity của file. Với signed URL có thời hạn, application phải sinh lại từ `storage_key` thay vì lưu làm source of truth.

Các quan hệ media chính:

- `employees.avatar_file_id`, `customers.avatar_file_id` và `admins.avatar_file_id`;
- `brands.image_file_id`;
- `product_images.image_file_id` cho gallery của product;
- `product_variants.image_file_id` cho ảnh riêng của variant (tùy chọn).

## Product image invariant

Gallery thuộc cấp product (`product_images.product_id`). Mỗi product có tối đa một ảnh chính, enforce bằng partial unique index:

```sql
CREATE UNIQUE INDEX uk_product_images_main
ON product_images (product_id)
WHERE is_main = true;
```

Variant có thể có thêm một ảnh riêng ở `product_variants.image_file_id`; variant không có ảnh riêng thì hiển thị ảnh chính của product.

## Customer addresses

Một customer có thể lưu nhiều địa chỉ giao hàng trong `customer_addresses`, ví dụ nhà riêng hoặc công ty. `customers` không lưu một cột `address` duy nhất; `is_default` chọn địa chỉ mặc định. Mỗi customer chỉ có một địa chỉ mặc định:

```sql
CREATE UNIQUE INDEX uk_customer_addresses_default
ON customer_addresses (customer_id)
WHERE is_default = true;
```

## Order delivery snapshot

Khi tạo order, hệ thống copy thông tin giao hàng vào `orders.recipient_name`, `recipient_phone` và `delivery_address`. Các cột này `NOT NULL` vì một order hợp lệ phải có thông tin giao hàng tại thời điểm đặt. Order không giữ FK tới `customer_addresses`, nên sửa hoặc xóa địa chỉ sau này không đổi order cũ. Đây là duplication có chủ đích để bảo toàn lịch sử, không vi phạm normalization.

## Cart

Cart nằm trong PostgreSQL để giữ giỏ hàng ổn định giữa các request và thiết bị.

- Chỉ khách đã đăng nhập mới có cart; không có giỏ cho khách vãng lai.
- Mỗi customer có đúng một cart (`carts.customer_id` unique). Cart không có trạng thái; đặt hàng xong thì xóa các `cart_items`, dòng cart giữ lại để dùng cho lần sau.
- `cart_items` dùng primary key kép `(cart_id, variant_id)` vì một variant chỉ xuất hiện một lần trong cart.
- Thêm cùng variant là cộng dồn vào dòng hiện có; sửa quantity là update dòng đó, không tạo dòng trùng.

## Order and payment state separation

`orders.status` dùng state machine của đơn hàng (xem [order-lifecycle](../01-business/workflows/order-lifecycle.md)):

```text
PENDING_PAYMENT -> PENDING_CONFIRMATION -> CONFIRMED -> SHIPPING -> COMPLETED
Các trạng thái chưa COMPLETED có thể sang CANCELLED theo quyền của từng tác nhân
```

COD bắt đầu ở `PENDING_CONFIRMATION`; online bắt đầu ở `PENDING_PAYMENT`. Vì database default không biết phương thức thanh toán, application đặt `PENDING_PAYMENT` tường minh cho đơn online. Mọi lần đổi trạng thái ghi một dòng vào `order_status_history` (trạng thái trước/sau, người đổi, lý do) trong cùng transaction.

`payments.status` gồm `PENDING`, `PAID`, `FAILED`, `CANCELLED` và `REFUNDED`. Không dùng payment status để thay thế order status.

## Payment methods and attempts

Phương thức thanh toán là dữ liệu danh mục trong `payment_methods`, không lưu dạng chuỗi tự do trên payment. Hiện có `COD` và `VNPAY` đang dùng; `ONLINE_CARD` cũ đã `INACTIVE`. `orders.payment_method_id` lưu phương thức khách đã chọn.

Mỗi dòng `payments` là một payment attempt của order:

- `payment_method_id` bắt buộc trỏ tới một payment method;
- `amount` bắt buộc lưu số tiền của attempt, không suy ra từ order lúc đọc, và không âm;
- `provider_transaction_code` (unique) lưu mã giao dịch từ cổng thanh toán nếu có;
- `idempotency_key` chống tạo trùng payment cho cùng một đơn;
- `customer_id` là bản sao khách của đơn để lọc, không phải gọi sang Order Service;
- `paid_at` bắt buộc có khi `PAID` hoặc `REFUNDED`;
- một order có thể có nhiều attempt `FAILED` hoặc `CANCELLED` trước khi có một attempt `PAID`.

PostgreSQL enforce tối đa một attempt `PAID` cho mỗi order:

```sql
CREATE UNIQUE INDEX uk_payments_order_paid
ON payments (order_id)
WHERE status = 'PAID';
```

## Discount scope and targets

Discount có `discount_type` (`PERCENT`, `FIXED`) và `application_scope` (`ORDER`, `ALL_ITEMS`, `CATEGORY`). Trạng thái lưu chỉ gồm `ACTIVE`, `INACTIVE` (bị khóa) và `DELETED`; chưa bắt đầu, đang chạy hay hết hạn được tính từ `start_at`/`end_at` lúc đọc.

Target chỉ có một bảng: `discount_categories(discount_id, category_id)` với primary key kép (`category_id` là tham chiếu logic sang Catalog Service).

`code` có thể `NULL` cho promotion tự động. Mã duy nhất không phân biệt hoa thường trong các discount chưa xóa (`upper(code)`), nên mã của discount đã xóa dùng lại được; mã chỉ hợp lệ với scope `ORDER` (service kiểm tra, không có ràng buộc ở DB).

Scope-target là cross-table invariant, không thể enforce bằng một `CHECK`:

| `application_scope` | Category targets |
|---|---:|
| `ORDER` | 0 |
| `ALL_ITEMS` | 0 |
| `CATEGORY` | >= 1 |

Service ghi discount cùng target trong một transaction. Database enforce bằng deferred constraint trigger trên `discounts` và `discount_categories`; trạng thái trung gian được phép trong transaction nhưng phải hợp lệ khi commit.

## Product pricing

`product_variants.price` là giá bán hiện hành duy nhất của variant. Không lưu `price_sale` vì đó là giá dẫn xuất từ promotion. Giá hiệu lực được tính lúc áp dụng discount:

```text
price     = 20.000.000
discount  = 10%
effective = 18.000.000
```

Khi checkout, giá và số tiền giảm của từng dòng được snapshot vào `order_items` (`unit_price`, `discount_amount`); đổi giá hay promotion về sau không làm đổi order cũ.

## Inventory scope

Tồn kho chỉ có một số tổng ở `product_variants.quantity`; không có backorder hay stock movement. Tồn kho bị trừ khi Catalog Service nhận lệnh giữ kho của đơn (đủ tất cả dòng hoặc không dòng nào) và được cộng lại khi đơn bị hủy hoặc thanh toán thất bại. Đặt hàng chỉ được khi số lượng không vượt tồn kho hiện có.

## Transaction money snapshot

Công thức tiền được định nghĩa duy nhất:

```text
item_gross = unit_price * quantity
item_net   = item_gross - item_discount
subtotal   = sum(item_net)
total      = subtotal - order_discount + shipping_fee
```

Ánh xạ cột: `item_discount` là `order_items.discount_amount` (cả dòng, không vượt `item_gross`); `subtotal` là `orders.subtotal_amount` (đã trừ giảm theo dòng); `order_discount` là `orders.discount_amount`; `total` là `orders.total_amount`. Database có CHECK bảo đảm `total_amount = subtotal_amount - discount_amount + shipping_fee`.

Các giá trị này được ghi lúc tạo order và không tính lại từ catalog hay discount hiện tại. `order_items` còn snapshot `product_name`, `sku` và `variant_label` của variant. Lưu snapshot là yêu cầu bảo toàn lịch sử giao dịch, không phải vi phạm 3NF.

## Order item history

`order_items` không bị hard-delete khỏi order history và không có cột trạng thái; hủy là hủy cả đơn. Mỗi variant chỉ xuất hiện một lần trong cùng order (`UNIQUE (order_id, product_variant_id)`).

## Shipping method and fee snapshot

Phương thức giao hàng nằm trong `shipping_methods` với `code`, `name`, `fee` và `status`. `fee` là tariff hiện hành (VND). Khi tạo order, application lưu `orders.shipping_method_id` và `orders.shipping_fee` (copy từ `shipping_methods.fee` lúc checkout). `shipping_fee` là snapshot, không tính lại; đổi phí giao nhanh từ 30.000 lên 40.000 chỉ cần sửa `shipping_methods.fee`, order cũ vẫn giữ 30.000.

## Invoice

Hóa đơn không có bảng riêng: hóa đơn là một order `COMPLETED`. `orders.invoice_number` (unique, dạng `INV-` + 10 ký tự) được sinh lúc tạo order; ngày hóa đơn là `orders.delivered_at`.

## Product review ownership

`product_reviews.order_item_id` là tham chiếu `UNIQUE` tới `order_items.id` (Order Service), nên mỗi dòng đơn chỉ có một đánh giá. Review lưu thêm `product_id` (FK cùng database) và `customer_id` để liệt kê đánh giá theo sản phẩm và hiển thị tên người đánh giá mà không phải gọi Order Service; hai giá trị này được ghi lúc tạo và khớp với order item đã được kiểm tra. Review chỉ được tạo khi order tương ứng `COMPLETED`.

Mỗi review sửa được một lần duy nhất trong 30 ngày (`edited_at`, NULL là chưa sửa).

## Variant options

`options` lưu cặp `(name, value)` duy nhất (ví dụ "Màu sắc" = "Xanh"); `variant_options` có primary key kép `(product_variant_id, option_id)`.

Một variant chỉ được có tối đa một option cho mỗi `name` (so sánh sau khi trim và không phân biệt hoa thường). Vì `name` nằm ở bảng `options`, invariant này được enforce bằng deferred constraint trigger trên `variant_options` và khi đổi tên option.

## Discount application layers

Chỉ cho phép đúng hai tầng giảm giá:

- `order_items.discount_id`: tối đa một item promotion cho mỗi dòng;
- `orders.order_discount_id`: tối đa một order voucher cho mỗi order.

Hai tầng cộng dồn. Không cho nhiều voucher trên cùng order hoặc nhiều promotion trên cùng dòng. Invariant được biểu diễn bằng một cột đơn ở mỗi entity và kiểm tra trong application transaction. Giá trị order tính theo thứ tự:

```text
item net   = unit_price * quantity - item promotion
subtotal   = sum(item net)
total      = subtotal - order voucher + shipping_fee
```

## Messaging tables

Catalog, Order và Payment có bảng `outbox_events` (sự kiện/lệnh chờ gửi, ghi cùng transaction nghiệp vụ) và `inbox_events` (id sự kiện đã xử lý, khử trùng lặp). Xem [service-communication](../02-architecture/service-communication.md).

## Invariants

- `customer_addresses.customer_id` phải trỏ tới customer tồn tại.
- Một customer có tối đa một địa chỉ mặc định, bảo đảm bằng partial unique index và xử lý transaction khi đổi địa chỉ mặc định.
- `orders.delivery_address`, `recipient_name` và `recipient_phone` là snapshot bất biến sau khi order được tạo.
- Mỗi order có tối đa một payment `PAID`.
