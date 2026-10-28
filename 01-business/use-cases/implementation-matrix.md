# Implementation Matrix

Bảng này đối chiếu 64 use-case trong `README.md` với source hiện tại của các
microservice (identity, catalog, order, payment, promotion, search, sync,
media, gateway). Đây là audit source-level cập nhật **2026-10-28**. Các dòng
AI (`UC-AI-*`) chưa được audit lại trong lần cập nhật này.

## Trạng thái

| Trạng thái | Ý nghĩa |
| --- | --- |
| `VERIFIED` | Schema/contract hoặc graph đã được chạy kiểm tra trực tiếp. |
| `SOURCE-IMPLEMENTED` | Có controller/service/persistence flow tương ứng; chưa claim E2E use-case. |
| `MVP-SOURCE-IMPLEMENTED` | Có API/flow deterministic để tích hợp; provider thật còn deferred. |
| `NOT-STARTED` | Chưa có implementation tương ứng. |

## Batch

| Batch | Phạm vi |
| --- | --- |
| `F0-DB-CONTRACT` | Flyway schema, constraints, JPA mapping và response/error envelope. |
| `F1-AUTH` | Account identity, auth, profile, addresses và account locking. |
| `F2-CATALOG` | Product/variant/image/options/category/brand/list price. |
| `F3-CART` | PostgreSQL cart, account/guest owner và active-cart invariant. |
| `F4-ORDER-PAYMENT` | Checkout, order state, snapshots, payment, shipping, discount, review. |
| `F5-ADMIN` | Admin CRUD, order/invoice/payment và reporting. |
| `F6-AI` | AI API, backend catalog tools, context và graph MVP. |

## Baseline

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| DB-BASELINE-001 | Đồng bộ database với DBML mới | Mỗi service có DB và Flyway riêng (`*-service/src/main/resources/db/migration`), đối chiếu `docs/02-architecture/db.dbml`; catalog đến V14, payment đến V6 | `SOURCE-IMPLEMENTED` | `F0-DB-CONTRACT` |
| API-CONTRACT-001 | Response/error envelope | `docs/02-architecture/api-contract.md`, `common-lib` (`ApiResponse`, `PageResponse`, `GlobalExceptionHandler`, các exception chung), security handler ở gateway và từng service | `SOURCE-IMPLEMENTED` | `F0-DB-CONTRACT` |

## Customer — authentication, profile, catalog, cart, order, review

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-AUTH-001 | Đăng nhập email/phone/Google | `AuthController` (`/auth/login`, `/auth/google`, `/auth/refresh-token`), `AuthService`, `GoogleIdentityVerifier`; kiểm tra trạng thái tài khoản trước mật khẩu, lỗi chung cho sai tài khoản/mật khẩu, tự tạo hoặc liên kết khách hàng khi đăng nhập Google lần đầu | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-002 | Đăng ký tài khoản | `AuthService.register/resendOtp/verifyRegistrationOtp`, `OtpService` (Redis: OTP 5 phút, dữ liệu đăng ký 10 phút); tạo account + customer + địa chỉ mặc định trong một transaction rồi cấp token luôn | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-003 | Khôi phục/đặt lại mật khẩu | `AuthService.forgotPassword/resetPassword`: chỉ email, OTP dùng một lần, phản hồi không lộ tài khoản có tồn tại | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-004 | Đăng xuất | `AuthService.logout`, `TokenRevocationService` (marker `revoked-before` theo account trong Redis), `RevokedTokenFilter` ở gateway; Redis lỗi thì fail-closed; `TokenRevocationServiceTest` | `VERIFIED` | `F1-AUTH` |
| UC-AUTH-005 | Đổi mật khẩu | `AuthService.changePassword/verifyPasswordChangeOtp`: mật khẩu cũ + OTP email, tài khoản Google chưa có mật khẩu chỉ cần OTP | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-006 | Cập nhật thông tin cá nhân | `ProfileController/ProfileService` (họ tên, giới tính, ngày sinh, số điện thoại, `avatarFileId` kiểm tra với Media Service), `AddressController/AddressService` (CRUD địa chỉ, một địa chỉ mặc định); email không đổi được | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-CAT-001 | Xem chi tiết sản phẩm | `ProductController` (`GET /products/{id}`, `/products/slug/{seoName}`), `ProductQueryService`, `ProductAssembler`; chỉ sản phẩm và variant `ACTIVE` | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-002 | Xem danh sách sản phẩm | `GET /products`: trang số (`page`, kèm tổng) hoặc cursor, `ProductRepository.SEARCH_PRODUCTS`; chỉ sản phẩm `ACTIVE` có variant `ACTIVE`; cây danh mục có `productCount` | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-003 | Tìm kiếm sản phẩm | search-service `ProductSearchController/ProductSearchService` (Elasticsearch: tên, thương hiệu, danh mục, mô tả; bỏ dấu, chịu gõ sai); sync-service dựng chỉ mục từ CDC `catalog.changed` | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-004 | Lọc sản phẩm | Danh mục (gồm danh mục con), thương hiệu, khoảng giá theo variant: `ProductQueryService` khi không có từ khóa, `ProductSearchService` khi có từ khóa | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CART-001 | Thêm sản phẩm vào giỏ | `CartController/CartService.addItem` (`/cart/items`): chỉ khách đăng nhập, khóa cart, cộng dồn số lượng, kiểm tra bán được và tồn kho qua Catalog; không có guest cart | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-CART-002 | Cập nhật số lượng trong giỏ | `CartService.updateItem`: thay số lượng 1–9999, kiểm tra tồn kho, `CART_ITEM_NOT_FOUND` nếu dòng không thuộc cart của khách | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-CART-003 | Xóa sản phẩm khỏi giỏ | `CartService.removeItem/clearCart`: xóa một dòng hoặc toàn bộ giỏ | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-ORD-001 | Đặt hàng | `CheckoutService.placeOrder` (idempotency key, snapshot người nhận/giá/phí giao, `OrderDiscountService` gọi Promotion, `OrderOutbox.reserveStock`); saga `StockEventConsumer` → Payment Service tạo payment; `PaymentEventConsumer` cập nhật đơn | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-002 | Xem trạng thái đơn hàng | `OrderQueryService.getStatus` (`GET /orders/{id}/status`): chỉ đơn của chính khách, kèm lý do hủy | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-003 | Hủy đơn hàng | `OrderService.cancelByCustomer`: chỉ `PENDING_PAYMENT`/`PENDING_CONFIRMATION`; outbox trả tồn kho + sự kiện `order.cancelled`, Payment Service hủy payment `PENDING`, payment `PAID` giữ nguyên | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-004 | Xem lịch sử mua hàng | `OrderQueryService.getOrders/getOrdersPage` (`GET /orders`): trang số hoặc cursor, lọc `status` | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-005 | Tìm kiếm đơn hàng | `keyword` khớp chính xác id đơn (có/không dấu gạch) hoặc `invoice_number` (không phân biệt hoa thường), trong đơn của khách | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-006 | Xem chi tiết đơn hàng | `OrderQueryService.getDetail` + `PaymentLookup` (payment attempts của khách từ Payment Service), snapshot tài chính của đơn | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-REV-001 | Đánh giá sau khi mua | `ProductReviewController/ProductReviewService`: một đánh giá cho mỗi order item, đơn phải `COMPLETED` (hỏi Order Service), sửa một lần trong 30 ngày; danh sách công khai kèm tên người đánh giá | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |

## AI

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-AI-001 | Chatbot AI Agent | `/api/v1/chat` and `/api/v1/chat/stream` (SSE), bounded conversation context, shopping planning graph, `CatalogRetriever` boundary, streaming/text direct model adapters for OpenAI/Gemini, deterministic fallback and canonical envelope; runtime fallback verified, live provider E2E pending | `VERIFIED` | `F6-AI` |
| UC-AI-002 | Semantic product search | `/api/v1/search`, shopping planning graph, configurable Qdrant/embedding adapter + cursor-aware catalog indexer, active-status gate, backend lexical fallback and product cards; disposable Qdrant runtime verified | `VERIFIED` | `F6-AI` |
| UC-AI-003 | Tư vấn sản phẩm | `/api/v1/consult`, shopping planning graph, `CatalogRetriever`-backed context, catalog-grounded fallback and direct model answer; runtime model + fallback verified | `VERIFIED` | `F6-AI` |
| UC-AI-004 | So sánh sản phẩm | `/api/v1/compare`, request-scoped LangGraph comparison flow, direct model answer and partial errors; runtime model + missing-product branch verified | `VERIFIED` | `F6-AI` |
| UC-AI-005 | Đánh giá/giải thích sản phẩm | `/api/v1/evaluate`, product detail lookup, canonical list-price mapping and direct model answer/fallback; runtime model + not-found branch verified | `VERIFIED` | `F6-AI` |

## Admin — product, customer, employee

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-PROD-001 | Xem danh sách sản phẩm | `ProductController` `GET /products/admin`, `/products/admin/{id}`: gồm `ACTIVE` + `INACTIVE`, sản phẩm chưa có variant; chỉ `ROLE_EMPLOYEE` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-002 | Tìm kiếm/lọc sản phẩm | Cùng API admin: từ khóa, danh mục, thương hiệu, trạng thái, khoảng giá (Catalog, không qua search-service) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-003 | Thêm sản phẩm | `ProductService.createProduct`: kiểm tra category/brand `ACTIVE`, `seo_name` duy nhất, specifications theo mẫu thuộc tính của category (`ProductSpecificationValidator`), gallery ảnh; variant thêm riêng | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-004 | Chỉnh sửa sản phẩm | `ProductService.updateProduct`: ghi đè thông tin, kiểm tra lại specifications, gallery `null` giữ nguyên / có giá trị thì thay thế | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-005 | Xóa sản phẩm | `ProductService.deleteProduct`: xóa mềm sản phẩm và variant, chỉ khi tồn kho 0 và chưa từng được đặt (`OrderServiceClient.hasOrderHistory`), nếu không `PRODUCT_IN_USE` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-006 | Ẩn/ngừng trưng bày sản phẩm | `ProductService.updateProductStatus` (`PATCH /products/{id}/status`, `ACTIVE`/`INACTIVE`) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-007 | Thêm biến thể sản phẩm | `ProductVariantService.createVariant/updateVariant/updateVariantStatus/deleteVariant`: SKU/barcode duy nhất giữa variant chưa xóa, option không trùng tên, ảnh riêng kiểm tra với Media Service | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-001 | Xem danh sách khách hàng | `CustomerController/CustomerService.search` (`GET /customers`): trang số, mới đăng ký trước, avatar URL một lần gọi Media; chỉ `ROLE_EMPLOYEE` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-002 | Tìm kiếm/lọc khách hàng | Từ khóa (tên cả hai thứ tự, email, số điện thoại), `status`, khoảng ngày đăng ký | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-003 | Xem thông tin khách hàng | `CustomerService.getById`: hồ sơ + địa chỉ (mặc định trước) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-004 | Xem đơn hàng của khách hàng | Order Service `GET /orders/admin?customerId=` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-005 | Khóa/chặn tài khoản khách hàng | `CustomerService.lock` → `AccountLocker`: `LOCKED` + marker thu hồi token trong một transaction; không có mở khóa | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-ADM-EMP-001 | Xem danh sách nhân viên | `EmployeeController/EmployeeService.search` (`GET /employees`): trang số, chỉ `ROLE_ADMIN` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-002 | Tìm kiếm nhân viên | Từ khóa (tên, email, số điện thoại) và `status`; không có `status` thì ẩn nhân viên `DELETED` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-003 | Xem chi tiết nhân viên | `EmployeeService.getById` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-004 | Thêm tài khoản nhân viên | `EmployeeService.create`: role cố định `ROLE_EMPLOYEE`, email/số điện thoại duy nhất, kiểm tra avatar với Media | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-005 | Chỉnh sửa tài khoản nhân viên | `EmployeeService.update` (`PATCH`): trường bỏ trống giữ nguyên, không đổi role | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-006 | Khóa tài khoản nhân viên | `EmployeeService.lock` → `AccountLocker`; thêm `deactivate`/`activate`/`delete` qua `AccountStateChanger` | `SOURCE-IMPLEMENTED` | `F1-AUTH` |

## Admin — category and discount

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-CAT-001 | Xem danh mục sản phẩm | `CategoryController`: `GET /categories/admin` (employee), `/categories/tree` và `/categories` (công khai, kèm `productCount`), `/hardware-types` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-002 | Thêm danh mục | `CategoryService.create`: tên/`seo_name` duy nhất, danh mục cha `ACTIVE`, loại phần cứng từ master data | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-003 | Sửa danh mục | `CategoryService.update/reorder`, `CategoryAttributeService` (mẫu thuộc tính kế thừa): chống vòng lặp danh mục cha, ẩn/hiện, sắp xếp lại | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-004 | Xóa danh mục | `CategoryService.delete`: xóa mềm, chặn khi còn danh mục con hoặc sản phẩm (`CATEGORY_IN_USE`) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-DIS-001 | Xem danh sách khuyến mãi | `DiscountController/DiscountService.list` (`GET /discounts`): trang số, lọc state `SCHEDULED`/`RUNNING`/`EXPIRED`/`LOCKED` tính từ thời gian; chỉ `ROLE_EMPLOYEE` | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-002 | Thêm giảm giá | `DiscountService.create`: giá trị/thời gian/scope-target, code chỉ cho scope `ORDER`, category target kiểm tra với Catalog | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-003 | Cập nhật khuyến mãi | `DiscountService.update`: thay discount và target trong một transaction, `code` bỏ trống giữ nguyên | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-004 | Xóa giảm giá | `DiscountService.delete`: xóa mềm, chặn khi đang `RUNNING` (`DISCOUNT_RUNNING`) | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-005 | Khóa/ẩn giảm giá | `DiscountService.updateStatus` (`PATCH /discounts/{id}/status`, `ACTIVE`/`INACTIVE`) | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |

## Admin — order, invoice, payment

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-ORD-001 | Xem danh sách đơn hàng | `OrderController` `GET /orders/admin`: trang số, lọc trạng thái/khách/ngày/từ khóa (id, hóa đơn, tên, số điện thoại) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-ORD-002 | Xem chi tiết đơn hàng | `OrderQueryService.getOrderDetail`: snapshot, payment attempts, lịch sử trạng thái | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-ORD-003 | Cập nhật trạng thái đơn hàng | `OrderService.updateStatus`: chỉ bước kế tiếp `PENDING_CONFIRMATION`→`CONFIRMED`→`SHIPPING`→`COMPLETED`, đặt `delivered_at`, ghi `order_status_history` | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-ORD-004 | Hủy đơn hàng khi có sự cố | `OrderService.cancelByEmployee`: hủy được đến `SHIPPING`, bắt buộc lý do, outbox trả tồn kho; không có thông báo riêng cho khách | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-INV-001 | Xem hóa đơn | `OrderQueryService.getInvoice/searchInvoices`: đơn `COMPLETED`, không có bảng hóa đơn riêng | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-INV-002 | Tìm kiếm/lọc hóa đơn | `GET /orders/admin/invoices`: từ khóa chứa một phần số hóa đơn hoặc tên người nhận, khoảng ngày `delivered_at`, trang số | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PAY-001 | Xem phương thức thanh toán | `PaymentMethodController` (`/payment-methods` công khai bản `ACTIVE`, `/payment-methods/admin` đủ cả `INACTIVE`); hiện có `COD`, `VNPAY`; chỉ xem | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-PAY-002 | Cập nhật trạng thái thanh toán | `PaymentService.updateStatus`: chỉ COD `PENDING`→`PAID` và `PAID`→`REFUNDED` bằng tay; online do `VnpayService` (callback có chữ ký) hoặc webhook tay của nhân viên; tối đa một payment `PAID` mỗi đơn | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-PAY-003 | Tìm kiếm giao dịch thanh toán | `PaymentService.searchPayments` (`GET /payments/admin`): mã giao dịch, đơn, khách (id hoặc tên qua Identity), trạng thái, khoảng ngày | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |

## Admin — brand, reporting

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-BRAND-001 | Quản lý thương hiệu | `BrandController/BrandService`: CRUD, `PATCH /brands/{id}/status`, `image_file_id`, xóa mềm chặn khi còn sản phẩm (`BRAND_IN_USE`) | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-DASH-001 | Xem tổng quan quản trị | Order `GET /orders/admin/dashboard`, Identity `GET /customers/summary`, Catalog `GET /product-variants/stock-summary`; chỉ `ROLE_ADMIN` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-STAT-001 | Xem thống kê | `OrderStatisticsController`: `/orders/admin/statistics/revenue`, `/top-variants`, `/order-status`; chỉ `ROLE_ADMIN` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |

## Ghi chú audit

- `SOURCE-IMPLEMENTED` không đồng nghĩa `COMPLETED`: tracker chỉ nâng trạng thái
  sau khi flow, authorization, transaction, DB invariant và test phù hợp được
  verify.
- Shipping method tariff is stored in `shipping_methods.fee`; checkout copies it
  to `orders.shipping_fee` and no longer contains a code-to-price switch.
- Production provider/model, secret rotation and index freshness are deferred
  hardening; the configurable model/fallback and local vector runtime are
  verified in F6, see ISSUE-019.
- `recommend-pc-build.md` và clarification flow không nằm trong 64 use-case vì
  README xác định đây là source gap, không phải requirement inventory.

AI rows track the request-scoped baseline, not completed stateful ReAct. Framework
naming is synchronized with canonical architecture; dated fixture evidence is not
live provider verification. Stateful extension gates: [status](../../04-ai/stateful-implementation-status.md).
