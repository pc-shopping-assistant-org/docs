# Database Design

## Database checks

`note` trong DBML chỉ dùng cho mô tả. Các điều kiện dưới đây phải được triển khai thành PostgreSQL `CHECK` constraint trong migration:

```sql
CHECK (rating BETWEEN 1 AND 5)
CHECK (product_variants.quantity >= 0)
CHECK (employees.salary >= 0)
CHECK (cart_items.quantity > 0)
CHECK (order_items.quantity > 0)
CHECK (list_price >= 0)
CHECK (unit_price >= 0)
CHECK (amount >= 0)
CHECK (
  (status = 'PAID' AND paid_at IS NOT NULL)
  OR (status IN ('PENDING', 'FAILED') AND paid_at IS NULL)
)
CHECK (shipping_fee >= 0)
CHECK (discount_amount >= 0)
CHECK (item_discount >= 0)
CHECK (start_at < end_at)
CHECK (min_order_amount >= 0)
CHECK (application_scope IN ('ORDER', 'ALL_ITEMS', 'CATEGORY', 'VARIANT'))
```

Discount value phải phụ thuộc type:

```sql
CHECK (
  (discount_type = 'PERCENT' AND value > 0 AND value <= 100)
  OR (discount_type = 'FIXED' AND value > 0)
)
```

## Account and profile ownership

`accounts` là source of truth cho đăng nhập và identity:

- `email` và `phone` là unique tại `accounts`;
- `password_hash` lưu credential đã hash;
- `role_id` xác định role;
- `status` (`ACTIVE`, `LOCKED`, ...) điều khiển quyền đăng nhập.

`customers` và `employees` là profile 1–1, dùng `account_id` vừa là primary key vừa là foreign key tới `accounts.id`. Hai bảng profile không duplicate email/phone. Khi account bị `LOCKED`, profile vẫn được giữ nguyên.

Thông tin việc làm như `salary` và `joined_at` thuộc `employees`; credential và trạng thái khóa vẫn thuộc `accounts`.

Customer không có `point` vì MVP chưa có loyalty domain hoặc rule tích điểm.

## File and media ownership

`files` là registry chung cho metadata của file; entity khác chỉ giữ foreign key tới `files.id`. Storage identity duy nhất là `(storage_provider, storage_key)`.

`public_url` là optional cache/public address, không phải identity của file. Với signed URL có thời hạn, application phải sinh lại từ `storage_key` thay vì lưu làm source of truth.

Các quan hệ media chính:

- `employees.avatar_file_id` và `customers.avatar_file_id`;
- `brands.image_file_id`;
- `product_images.file_id` cho gallery của từng product variant.

## Product image invariant

Mỗi product variant có tối đa một ảnh chính đang active. `product_variants` không giữ thêm một cột ảnh riêng để tránh hai nguồn cùng mô tả ảnh đại diện. Invariant được enforce bằng partial unique index:

```sql
CREATE UNIQUE INDEX ux_variant_main_image
ON product_images (product_variant_id)
WHERE is_main = true AND status = 'ACTIVE';
```

## Customer addresses

Một customer có thể lưu nhiều địa chỉ giao hàng trong `customer_addresses`, ví dụ nhà riêng, công ty hoặc nhà bố mẹ.

`customers` không lưu một cột `address` duy nhất. Địa chỉ được quản lý như một collection riêng, với `is_default` để chọn địa chỉ mặc định cho lần đặt hàng tiếp theo.

Ở database triển khai bằng PostgreSQL, nên dùng partial unique index để bảo đảm mỗi customer chỉ có một địa chỉ mặc định:

```sql
CREATE UNIQUE INDEX ux_customer_default_address
ON customer_addresses (customer_id)
WHERE is_default = true;
```

## Order delivery snapshot

Khi tạo order, hệ thống copy thông tin giao hàng vào:

- `orders.recipient_name`
- `orders.recipient_phone`
- `orders.delivery_address`

Các cột snapshot này là `NOT NULL` vì một order hợp lệ phải có thông tin giao hàng tại thời điểm đặt hàng. Order không giữ FK bắt buộc tới `customer_addresses` để hiển thị địa chỉ hiện tại.

Nếu customer sửa hoặc xóa địa chỉ sau này, dữ liệu giao hàng của order cũ vẫn không thay đổi.

Đây là duplication có chủ đích để bảo toàn lịch sử nghiệp vụ, không phải vi phạm normalization.

## Cart

Cart được lưu trong PostgreSQL để giữ trạng thái giỏ hàng ổn định giữa các request và thiết bị.

- Cart đã đăng nhập liên kết với `customer_id`.
- Cart khách vãng lai dùng `session_token`.
- Cart phải có chính xác một owner: `customer_id` cho customer đã đăng nhập hoặc `session_token` cho guest.
- Chỉ cho phép một cart `ACTIVE` trên mỗi customer và một cart `ACTIVE` trên mỗi session:

```sql
CREATE UNIQUE INDEX ux_carts_active_customer
ON carts (customer_id)
WHERE status = 'ACTIVE' AND customer_id IS NOT NULL;

CREATE UNIQUE INDEX ux_carts_active_session
ON carts (session_token)
WHERE status = 'ACTIVE' AND session_token IS NOT NULL;
```
- `cart_items` dùng primary key kép `(cart_id, variant_id)`, vì một variant chỉ xuất hiện một lần trong cùng cart.
- Thay đổi quantity là update item hiện tại, không tạo thêm dòng trùng variant.
- Khi tạo order thành công, cart chuyển sang `CONVERTED` và không được dùng lại như cart active.

## Order and payment state separation

`orders.status` dùng state machine của đơn hàng:

```text
PENDING_PAYMENT -> PENDING_CONFIRMATION -> CONFIRMED -> SHIPPING -> COMPLETED
                                          \-> CANCELLED
```

COD bắt đầu ở `PENDING_CONFIRMATION`; online bắt đầu ở `PENDING_PAYMENT`. Vì database default không biết phương thức thanh toán, application phải set `PENDING_PAYMENT` tường minh cho checkout online.

`payments.status` chỉ dùng `PENDING`, `PAID` và `FAILED`. Không dùng payment status để thay thế order status.

## Payment methods and attempts

Phương thức thanh toán là dữ liệu danh mục trong `payment_methods`, không lưu dạng chuỗi tự do trên payment. Các code mẫu gồm `COD`, `STRIPE_CARD` và `BANK_TRANSFER`.

Mỗi dòng `payments` là một payment attempt của order:

- `payment_method_id` bắt buộc trỏ tới một payment method đang dùng được.
- `amount` bắt buộc lưu số tiền của attempt; không suy ra từ order tại thời điểm đọc.
- `provider_transaction_code` lưu mã giao dịch từ provider nếu có.
- Một order có thể có nhiều attempt `FAILED` trước khi có một attempt `PAID`.
- `amount` không được âm và không được thay đổi sau khi attempt đã được ghi nhận.
- `paid_at` chỉ được set khi attempt chuyển sang `PAID`.
- Với cùng một order, chỉ một attempt được xem là thanh toán thành công; việc bảo đảm invariant này nằm ở application transaction hoặc database constraint.

PostgreSQL enforce tối đa một attempt `PAID` cho mỗi order bằng partial unique index:

```sql
CREATE UNIQUE INDEX ux_payments_one_paid_per_order
ON payments (order_id)
WHERE status = 'PAID';
```

## Discount scope and targets

Discount định nghĩa rõ `discount_type` (`PERCENT`, `FIXED`) và `application_scope` (`ORDER`, `ALL_ITEMS`, `CATEGORY`, `VARIANT`). Không dùng cột `scope` dạng chuỗi mơ hồ.

Target được normalize theo scope:

- `discount_categories(discount_id, category_id)` với primary key kép;
- `discount_variants(discount_id, variant_id)` với primary key kép.

`code` có thể `NULL` cho promotion tự động không cần coupon code. Khi `application_scope` là `CATEGORY` hoặc `VARIANT`, application phải ghi target tương ứng; không dùng bảng target variant để giả lập category.

Scope-target là cross-table invariant, không thể enforce bằng một `CHECK` trên `discounts`:

| `application_scope` | Category targets | Variant targets |
|---|---:|---:|
| `ORDER` | 0 | 0 |
| `ALL_ITEMS` | 0 | 0 |
| `CATEGORY` | >= 1 | 0 |
| `VARIANT` | 0 | >= 1 |

Khi tạo hoặc cập nhật discount, service phải ghi discount cùng target trong một transaction. Database enforce invariant bằng deferred constraint trigger trên `discounts`, `discount_categories` và `discount_variants`; trạng thái trung gian được phép tồn tại trong transaction nhưng phải hợp lệ tại thời điểm commit.

## Product pricing

`product_variants.list_price` là giá niêm yết duy nhất của variant. Không lưu `price_sale` vì đó là giá dẫn xuất từ promotion.

Effective selling price được tính tại thời điểm áp dụng discount:

```text
list_price = 20.000.000
discount   = 10%
effective  = 18.000.000
```

Khi checkout, giá thực tế dùng cho từng dòng phải được snapshot vào `order_items.unit_price`; thay đổi list price hoặc promotion về sau không làm thay đổi order cũ.

## Product suppliers

Supplier là master data độc lập. Quan hệ với product được normalize qua `product_suppliers(product_id, supplier_id)` thay vì đặt `supplier_id` trực tiếp trên `products`, vì một product có thể được nhập từ nhiều supplier và một supplier có thể cung cấp nhiều product.

Không được hard-delete hoặc chuyển supplier sang `DELETED` khi vẫn còn dòng liên kết trong `product_suppliers`. Application phải kiểm tra invariant này trong cùng transaction; foreign key chặn hard-delete khi quan hệ vẫn tồn tại.

## Inventory scope

Inventory của MVP chỉ lưu một stock tổng trên `product_variants.quantity`. Không có `inventory_policy`, reservation, backorder hay stock movement.

Khi đặt hàng, hệ thống chỉ cho phép quantity mua không vượt stock hiện có. Các flow `CONTINUE` và `BACKORDER` không thuộc phạm vi vì chưa có model fulfillment tương ứng.

## Transaction money snapshot

Công thức tiền được định nghĩa duy nhất:

```text
item_gross = unit_price * quantity
item_net   = item_gross - item_discount
subtotal   = sum(item_net)
total      = subtotal - order_discount + shipping_fee
```

Trong schema, `order_discount` chính là `orders.discount_amount`.

Snapshot tương ứng:

- `order_items.unit_price` và `item_discount` là input đã snapshot cho từng dòng;
- `orders.subtotal_amount`, `discount_amount`, `shipping_fee`, `total_amount`.

`orders.discount_amount` là phần giảm ở order voucher, còn `order_items.item_discount` là phần giảm ở item promotion. Các giá trị tài chính này được ghi nhận tại thời điểm tạo order và không bị tính lại từ catalog hoặc discount hiện tại. Việc lưu snapshot là yêu cầu bảo toàn lịch sử giao dịch, không phải vi phạm 3NF.

## Order item history

`order_items` không có trạng thái `DELETED` và không được hard-delete khỏi order history. MVP giữ `ACTIVE` và `CANCELLED` để biểu diễn khả năng hủy một phần item; nếu không triển khai partial-item cancellation, có thể bỏ luôn cột status ở migration sau.

## Shipping method and fee snapshot

Phương thức giao hàng được normalize vào `shipping_methods` với `code`, `name` và `status`.

Khi tạo order, application lưu:

- `orders.shipping_method_id`: phương thức đã chọn;
- `orders.shipping_fee`: phí giao hàng tại thời điểm checkout.

`shipping_fee` là snapshot, không được tính lại từ giá hiện tại của `shipping_methods`. Vì vậy nếu phí giao nhanh thay đổi từ 30.000 lên 40.000, order cũ vẫn giữ đúng 30.000.

## Product review ownership

`product_reviews.order_item_id` là FK `UNIQUE` tới `order_items.id`. Từ đó có thể suy ra:

```text
review -> order_item -> order -> customer
review -> order_item -> product_variant -> product
```

Review chỉ được tạo khi order tương ứng đã `COMPLETED`. Không lưu thêm `customer_id` hoặc `product_id` trên review vì hai giá trị này đã xác định qua quan hệ hiện có và sẽ tạo redundancy.

## Variant options

`options.name` là unique toàn cục để mỗi option có một tên định danh duy nhất.

Một variant chỉ được gắn tối đa một option chưa bị xóa cho mỗi type. Vì `type` nằm ở bảng `options`, invariant này được enforce bằng deferred constraint trigger PostgreSQL trên cả `variant_options` và thay đổi của `options`, ngoài unique key `(product_variant_id, option_id)`.

## Discount application layers

Phiên bản đồ án chỉ cho phép đúng hai tầng giảm giá:

- `order_items.item_discount_id`: tối đa một item promotion cho mỗi order item;
- `orders.order_discount_id`: tối đa một order voucher cho mỗi order.

Hai tầng có thể cộng dồn. Không cho phép nhiều voucher trên cùng order hoặc nhiều promotion trên cùng order item. Các invariant này được biểu diễn bằng một FK đơn ở mỗi entity và phải được kiểm tra trong application transaction.

Giá trị order được tính theo thứ tự:

```text
item effective price = list_price - item promotion
order subtotal       = sum(item effective price * quantity)
total                = order subtotal - order voucher + shipping_fee
```

## Invariants

- `customer_addresses.customer_id` phải trỏ tới customer tồn tại.
- Một customer có tối đa một địa chỉ mặc định, được bảo đảm bằng partial unique index và xử lý transaction khi đổi địa chỉ mặc định.
- `orders.delivery_address`, `orders.recipient_name` và `orders.recipient_phone` là snapshot immutable sau khi order được tạo, ngoại trừ flow điều chỉnh đơn được phân quyền rõ ràng.
