# Implementation Matrix

Bảng này đối chiếu 68 use-case trong `README.md` với source hiện tại. Đây là
audit source-level cập nhật **2026-08-31**; trạng thái hoàn tất chính thức nằm
ở [`USECASE_IMPLEMENTATION.md`](../../../USECASE_IMPLEMENTATION.md).

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
| `F5-ADMIN` | Admin CRUD, order/invoice/payment, supplier và reporting. |
| `F6-AI` | AI API, backend catalog tools, context và graph MVP. |

## Baseline

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| DB-BASELINE-001 | Đồng bộ database với DBML mới | `backend-api/server/src/main/resources/db/migration/V1__init.sql`, `docs/02-architecture/db.dbml`; PostgreSQL/Flyway smoke test and normalized option-type trigger integration test | `VERIFIED` | `F0-DB-CONTRACT` |
| API-CONTRACT-001 | Response/error envelope | `docs/02-architecture/api-contract.md`, backend `ApiResponse`/`ApiError`/`GlobalExceptionHandler`/security handlers/webhook, AI Pydantic `ApiResponse` plus HTTP-error handler; JSON/API contract tests | `VERIFIED` | `F0-DB-CONTRACT` |

## Customer — authentication, profile, catalog, cart, order, review

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-AUTH-001 | Đăng nhập email/phone | `AuthController`, `AuthServiceImpl`, account lookup và status checks | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-002 | Đăng ký tài khoản | OTP registration, account + customer + default address transaction | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-003 | Khôi phục/đặt lại mật khẩu | OTP forgot/reset bằng email hoặc phone, ghi `accounts.password_hash` | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-004 | Đăng xuất | Authenticated JWT blacklist endpoint; optional refresh-token body revokes the full token pair; Redis revocation failures fail closed | `VERIFIED` | `F1-AUTH` |
| UC-AUTH-005 | Đổi mật khẩu | Current password + OTP + hash update | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-AUTH-006 | Cập nhật thông tin cá nhân | Shared profile, account identity, avatar `files`, saved-address CRUD | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-CAT-001 | Xem chi tiết sản phẩm | `ProductController`/`ProductServiceImpl`, active variants, active files/images/options | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-002 | Xem danh sách sản phẩm | Public cursor list with canonical `list_price`/status filters | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-003 | Tìm kiếm sản phẩm | Keyword search through product name/SEO/description query | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CAT-004 | Lọc sản phẩm | Category, brand, price, status and pagination filters | `SOURCE-IMPLEMENTED` | `F2-CATALOG` |
| UC-CART-001 | Thêm sản phẩm vào giỏ | PostgreSQL `carts`/`cart_items`, account or `X-Cart-Session` guest | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-CART-002 | Cập nhật số lượng trong giỏ | Quantity validation and stock check in transaction | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-CART-003 | Xóa sản phẩm khỏi giỏ | Item removal/clear with owner and ACTIVE-cart checks | `SOURCE-IMPLEMENTED` | `F3-CART` |
| UC-ORD-001 | Đặt hàng | Cart checkout, canonical state, discount stacking, money/address snapshots, configured shipping fee snapshot, payment attempt | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-002 | Xem trạng thái đơn hàng | Customer-owned order detail/list returns canonical status | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-003 | Hủy đơn hàng | Pending-state boundary, stock restoration, item history retained | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-004 | Xem lịch sử mua hàng | Cursor order history scoped to account | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-005 | Tìm kiếm đơn hàng | Customer-owned search by UUID/compact UUID or `INV-XXXXXXXX` prefix, with status/cursor boundary | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ORD-006 | Xem chi tiết đơn hàng | Ownership check plus item/payment-attempt history/snapshot mapping | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-REV-001 | Đánh giá sau khi mua | Unique `order_item_id`, COMPLETED and ownership checks | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |

## AI

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-AI-001 | Chatbot AI Agent | `/api/v1/chat`, bounded conversation context, shopping planning graph, `CatalogRetriever` boundary, PydanticAI model adapter/fallback and canonical envelope; runtime model + fallback verified | `VERIFIED` | `F6-AI` |
| UC-AI-002 | Semantic product search | `/api/v1/search`, shopping planning graph, configurable Qdrant/embedding adapter + cursor-aware catalog indexer, active-status gate, backend lexical fallback and product cards; disposable Qdrant runtime verified | `VERIFIED` | `F6-AI` |
| UC-AI-003 | Tư vấn sản phẩm | `/api/v1/consult`, shopping planning graph, `CatalogRetriever`-backed context, catalog-grounded fallback and PydanticAI answer; runtime model + fallback verified | `VERIFIED` | `F6-AI` |
| UC-AI-004 | So sánh sản phẩm | `/api/v1/compare`, pydantic-graph comparison flow, PydanticAI answer and partial errors; runtime model + missing-product branch verified | `VERIFIED` | `F6-AI` |
| UC-AI-005 | Đánh giá/giải thích sản phẩm | `/api/v1/evaluate`, product detail lookup, canonical list-price mapping and PydanticAI answer/fallback; runtime model + not-found branch verified | `VERIFIED` | `F6-AI` |

## Admin — product, customer, employee

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-PROD-001 | Xem danh sách sản phẩm | `AdminProductController` + canonical product queries | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-002 | Tìm kiếm/lọc sản phẩm | Admin keyword/status/category/brand/price filters | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-003 | Thêm sản phẩm | Product + variants + M:N `product_suppliers` + file references | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-004 | Chỉnh sửa sản phẩm | Product update and supplier association replacement | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-005 | Xóa sản phẩm | Soft delete with remaining-stock and order-history safety checks | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-006 | Ẩn/ngừng trưng bày sản phẩm | Status endpoint preserving historical rows | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PROD-007 | Thêm biến thể sản phẩm | List price/stock, positive warranty-month validation, active file images, active option-type/main-image validation | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-001 | Xem danh sách khách hàng | Account/profile query with cursor and address hydration | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-002 | Tìm kiếm/lọc khách hàng | Email/phone/name/status account filters | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-003 | Xem thông tin khách hàng | Shared account identity, profile, addresses and order metrics | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-004 | Xem đơn hàng của khách hàng | `account_id` order relation and snapshot mapping | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CUS-005 | Khóa/chặn tài khoản khách hàng | Writes `accounts.status=LOCKED` and blocked-token key | `SOURCE-IMPLEMENTED` | `F1-AUTH` |
| UC-ADM-EMP-001 | Xem danh sách nhân viên | Employee/account cursor query | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-002 | Tìm kiếm nhân viên | Keyword/role/status filters over profile + account | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-003 | Xem chi tiết nhân viên | Shared account identity/profile response | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-004 | Thêm tài khoản nhân viên | Account + employee shared-PK transaction, salary/joinedAt and file validation | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-005 | Chỉnh sửa tài khoản nhân viên | Profile/account identity/role plus optional salary/joinedAt update | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-EMP-006 | Khóa tài khoản nhân viên | Account status lock + token revocation key | `SOURCE-IMPLEMENTED` | `F1-AUTH` |

## Admin — category and discount

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-CAT-001 | Xem danh mục sản phẩm | Public/admin category tree/detail endpoints | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-002 | Thêm danh mục | Parent/status/name validation | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-003 | Sửa danh mục | Cycle guard, uniqueness and status validation | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-CAT-004 | Xóa danh mục | Safe status/delete rule with product/child checks | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-DIS-001 | Xem danh sách khuyến mãi | Discount list/detail with normalized scope/targets | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-002 | Thêm giảm giá | Value/date/scope target validation and transaction | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-003 | Cập nhật khuyến mãi | Target replacement and canonical checks | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-004 | Xóa giảm giá | Soft/delete status without changing order snapshots | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-DIS-005 | Khóa/ẩn giảm giá | Status endpoint for inactive/disabled promotion | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |

## Admin — order, invoice, payment

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-ORD-001 | Xem danh sách đơn hàng | Admin cursor/status/customer/date query | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-ORD-002 | Xem chi tiết đơn hàng | Items, complete payment-attempt history, shipping and financial snapshots | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-ORD-003 | Cập nhật trạng thái đơn hàng | Canonical transition validator and stock/COD handling | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-ORD-004 | Hủy đơn hàng khi có sự cố | Admin transition to CANCELLED, stock restoration | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-INV-001 | Xem hóa đơn | Completed-order read model from snapshots | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-INV-002 | Tìm kiếm/lọc hóa đơn | `/api/v1/admin/invoices` keyword/date/cursor query; invoice UUID-prefix resolution runs in PostgreSQL | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-PAY-001 | Xem phương thức thanh toán | Public/admin payment-method catalog endpoint | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-PAY-002 | Cập nhật trạng thái thanh toán | Attempt status, amount/paid_at and one-PAID invariant | `SOURCE-IMPLEMENTED` | `F4-ORDER-PAYMENT` |
| UC-ADM-PAY-003 | Tìm kiếm giao dịch thanh toán | Admin customer name/email/phone, method/status/order/provider/date filters | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |

## Admin — supplier, brand, reporting

| ID | Feature | Evidence | Status | Batch |
| --- | --- | --- | --- | --- |
| UC-ADM-SUP-001 | Xem danh sách nhà cung cấp | Supplier CRUD/list and product M:N mapping | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-SUP-002 | Thêm nhà cung cấp | Nullable contact fields and canonical status | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-SUP-003 | Sửa nhà cung cấp | Contact/status update with uniqueness checks | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-SUP-004 | Xóa nhà cung cấp | Delete guard for linked `product_suppliers` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-BRAND-001 | Quản lý thương hiệu | Public/admin CRUD with `image_file_id` | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-DASH-001 | Xem tổng quan quản trị | Analytics overview totals/status counts | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |
| UC-ADM-STAT-001 | Xem thống kê | Revenue/top-selling/order-status endpoints | `SOURCE-IMPLEMENTED` | `F5-ADMIN` |

## Ghi chú audit

- `SOURCE-IMPLEMENTED` không đồng nghĩa `COMPLETED`: tracker chỉ nâng trạng thái
  sau khi flow, authorization, transaction, DB invariant và test phù hợp được
  verify.
- Shipping method tariff is stored in `shipping_methods.fee`; checkout copies it
  to `orders.shipping_fee` and no longer contains a code-to-price switch.
- Production provider/model, secret rotation and index freshness are deferred
  hardening; the configurable model/fallback and local vector runtime are
  verified in F6, see ISSUE-019.
- `recommend-pc-build.md` và clarification flow không nằm trong 68 use-case vì
  README xác định đây là source gap, không phải requirement inventory.
