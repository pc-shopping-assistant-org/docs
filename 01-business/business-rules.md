# Business Rules

## Account

- Đăng nhập dùng email hoặc phone từ `accounts`; không có username riêng.
- Email và phone là unique ở `accounts`, không lặp lại trong customer/employee profile.
- `customers.account_id` và `employees.account_id` là khóa 1–1 tới account tương ứng.
- MVP chưa có loyalty; customer không có point balance.
- Mật khẩu đăng ký tối thiểu 8 ký tự, gồm chữ thường, chữ hoa và số.
- Email và số điện thoại đăng ký không được trùng theo luồng report.
- Đổi/quên mật khẩu sử dụng OTP.
- Google Login chỉ chấp nhận ID token đã verify (signature, issuer, audience và
  `email_verified`); MVP liên kết Google `sub` với tài khoản local đã tồn tại.
- Google Login không tự tạo customer mới vì luồng đăng ký local vẫn yêu cầu
  phone, password và địa chỉ giao hàng.
- Chức năng quản trị yêu cầu đăng nhập đúng vai trò.
- Tài khoản có thể bị khóa mà dữ liệu hồ sơ vẫn được giữ.
- Khóa customer hoặc employee được thực hiện bằng `accounts.status = LOCKED`; không xóa profile.

## Product

- `Product` là sản phẩm logic; `Product Variant/SKU` là phiên bản bán cụ thể của product.
- Một product có thể có nhiều variant, ví dụ màu sắc hoặc dung lượng khác nhau.
- Mỗi product thuộc đúng một category chính.
- Category là taxonomy phân cấp qua `categories.parent_id`.
- Các nhóm như `Gaming`, `Hot`, `Best Seller` hoặc `Back to School` không phải category; nếu cần sẽ được model bằng collection/tag riêng.
- Mỗi variant chỉ có một `list_price`; không lưu thêm `price_sale`.
- Effective selling price được tính từ `list_price` và discount đang áp dụng.
- `list_price`, tồn kho `quantity` và các giá trị tiền không được âm.
- `options.name` là unique; một variant có tối đa một option chưa bị xóa cho mỗi `options.type`.
- Inventory MVP chỉ dùng stock tổng `product_variants.quantity`; không hỗ trợ `CONTINUE`, `BACKORDER`, reservation hoặc stock movement.
- Khi đặt hàng, quantity yêu cầu không được vượt tồn kho hiện có.
- Sản phẩm có thể ngừng trưng bày.
- Report nói chỉ xóa sản phẩm khi chưa nhập về kho; khả năng chứng minh rule này phải được kiểm tra ở data design.
- Danh mục chỉ được xóa nếu chưa có sản phẩm thuộc danh mục.
- Product và supplier có quan hệ nhiều-nhiều qua `product_suppliers`; nhà cung cấp chỉ được xóa khi không còn liên kết với product.
- File/media dùng `files` làm registry; entity nghiệp vụ chỉ lưu `file_id`, không lưu URL như identity.
- Mỗi variant có tối đa một ảnh main đang `ACTIVE`; gallery ảnh liên kết với variant qua `product_images`.
- Signed URL được resolve khi đọc và không phải source of truth của file.

## Cart & Order

- Giỏ được lưu bền vững trong PostgreSQL.
- Giỏ cho phép thêm, đổi số lượng và xóa mặt hàng.
- Mỗi variant chỉ xuất hiện một lần trong cùng giỏ; thêm lại variant sẽ tăng/cập nhật quantity.
- Giỏ có thể thuộc customer đã đăng nhập hoặc session của khách vãng lai.
- Mỗi cart có chính xác một owner: `customer_id` hoặc `session_token`, không được đồng thời có cả hai hoặc thiếu cả hai.
- Mỗi customer và mỗi guest session có tối đa một cart `ACTIVE`.
- Đơn hàng được tạo từ giỏ.
- Khi đặt hàng, người dùng cung cấp/chọn địa chỉ giao hàng, mã giảm giá nếu có và phương thức thanh toán.
- Phương thức giao hàng được chọn từ danh mục `shipping_methods`; tariff hiện
  hành nằm ở `shipping_methods.fee`.
- Phí giao hàng phải được snapshot vào order tại thời điểm checkout; thay đổi bảng giá giao hàng không làm thay đổi order cũ.
- Customer có thể lưu nhiều địa chỉ giao hàng và chọn một địa chỉ mặc định.
- Khi tạo đơn, thông tin người nhận và địa chỉ phải được snapshot vào order.
- Thay đổi địa chỉ của customer không được làm thay đổi thông tin giao hàng của order cũ.
- Yêu cầu chức năng nói khách chỉ hủy đơn khi đang chờ duyệt/chờ xác nhận.
- Quản lý có thể cập nhật trạng thái và hủy đơn khi có sự cố vận đơn.
- Order status chỉ gồm `PENDING_PAYMENT`, `PENDING_CONFIRMATION`, `CONFIRMED`, `SHIPPING`, `COMPLETED` và `CANCELLED`; order không dùng trạng thái `DELETED`.
- Thanh toán online tạo order ở `PENDING_PAYMENT`; chỉ sau khi payment là `PAID`, order mới chuyển sang `PENDING_CONFIRMATION`.
- COD tạo order ở `PENDING_CONFIRMATION`; payment chỉ chuyển sang `PAID` sau khi giao hàng và thu tiền.
- Không suy luận `Order.status` từ `Payment.status` hoặc ngược lại; hai state machine được cập nhật theo sự kiện nghiệp vụ tương ứng.
- Order item không bị xóa khỏi lịch sử; chỉ có thể ở `ACTIVE` hoặc `CANCELLED` nếu hệ thống hỗ trợ hủy từng item.

## Payment

- Hỗ trợ nhiều hình thức thanh toán theo phạm vi report.
- State diagram gồm chờ thanh toán, đã thanh toán, thất bại.
- `Payment.status` độc lập với `Order.status`: `PENDING`, `PAID`, `FAILED`.
- Phương thức thanh toán được chọn từ `payment_methods`; không lưu method dạng chuỗi tự do trong payment.
- Một order có thể có nhiều payment attempt; các attempt thất bại phải được giữ lại để audit.
- Mỗi payment attempt phải lưu `amount`; không được suy ra amount chỉ từ tổng order.
- `paid_at` chỉ có giá trị khi payment attempt ở trạng thái `PAID`.
- Có tra cứu giao dịch theo mã, khách hàng hoặc thời gian.

## Discount

- Discount phân biệt `discount_type`: `PERCENT` hoặc `FIXED`.
- Discount phân biệt `application_scope`: `ORDER`, `ALL_ITEMS`, `CATEGORY` hoặc `VARIANT`.
- `code` có thể bỏ trống với promotion tự động.
- Scope `CATEGORY` áp dụng qua target category; scope `VARIANT` áp dụng qua target variant.
- `PERCENT` phải có `0 < value <= 100`; `FIXED` phải có `value > 0`.
- Promotion chỉ hợp lệ khi `start_at < end_at`.
- Scope và target phải thỏa invariant sau:
  - `ORDER`: không có category target và không có variant target.
  - `ALL_ITEMS`: không có category target và không có variant target.
  - `CATEGORY`: có ít nhất một category target và không có variant target.
  - `VARIANT`: có ít nhất một variant target và không có category target.
- Invariant scope-target được ghi atomically trong service transaction và được enforce lại bằng deferred database constraint trigger; không được chỉ kiểm tra ở frontend.
- Mỗi `order_item` tối đa một item promotion.
- Mỗi `order` tối đa một order voucher.
- Item promotion và order voucher được cộng dồn theo thứ tự item trước, order sau.
- Không hỗ trợ voucher stacking trong phiên bản đồ án.
- Công thức duy nhất: `item_gross = unit_price × quantity`, `item_net = item_gross - item_discount`, `subtotal = Σ item_net`, `total = subtotal - orders.discount_amount + shipping_fee`.
- `subtotal_amount`, `discount_amount`, `shipping_fee` và `total_amount` là snapshot tài chính tại thời điểm tạo order.
- Item-level discount và order-level discount được lưu riêng, không gộp vào một giá trị mơ hồ.

## Review

- Review gắn với một `order_item` duy nhất để chứng minh customer đã mua variant tương ứng.
- Backend chỉ cho phép tạo review khi order chứa `order_item` đó có trạng thái `COMPLETED`.
- Một `order_item` chỉ được có tối đa một review.
- Customer và product được suy ra qua `order_item -> order -> customer` và `order_item -> variant -> product`; không duplicate hai foreign key này trên review.
- Report chưa đặc tả số lần đánh giá hoặc điều kiện trạng thái đơn chính xác.

## AI

- Cho phép truy vấn tiếng Việt dạng câu hỏi, mô tả hoặc từ khóa.
- Semantic Search truy xuất dữ liệu liên quan theo ngữ nghĩa.
- RAG dùng dữ liệu truy xuất làm ngữ cảnh cho LLM.
- AI hỗ trợ tìm kiếm, tư vấn, đánh giá và so sánh sản phẩm.
- AI có thể trả phản hồi cùng danh sách sản phẩm liên quan.
- Report chưa định nghĩa clarification bắt buộc, scoring/ranking cố định hay số lượng sản phẩm tối đa khi so sánh.
