# Use Case Inventory

> Implementation tracking: [USECASE_IMPLEMENTATION.md](../../../USECASE_IMPLEMENTATION.md)
>
> API/schema audit: [implementation-matrix.md](./implementation-matrix.md)

Bộ này được trích và tái cấu trúc từ report. Có 4 mức nguồn:

- **FORMAL** — có bảng/biểu đồ đặc tả use case trực tiếp trong Chương 3.2.2.
- **REQUIREMENT** — có yêu cầu chức năng hoặc xuất hiện trong use-case diagram, nhưng không có bảng đặc tả riêng.
- **AI-SOURCE** — có mô tả nghiệp vụ AI trong mục tiêu, AI Agent/RAG hoặc chatbot triển khai.
- **IMPLEMENTATION** — chỉ thấy rõ ở phần triển khai Chương 5, nên chưa được coi là requirement chính thức nếu Chương 3 không có.

| ID               | Use case                                                                 | Actor                          | Mức nguồn      | Nguồn                                                    |
| ---------------- | ------------------------------------------------------------------------ | ------------------------------ | -------------- | -------------------------------------------------------- |
| UC-AUTH-001      | [Đăng nhập](./login.md)                                                  | Khách hàng, Quản lý cửa hàng   | FORMAL         | Chương 3.2.2, tr. 46                                     |
| UC-AUTH-002      | [Đăng ký tài khoản](./register.md)                                       | Khách hàng                     | FORMAL         | Chương 3.2.2, tr. 47–48                                  |
| UC-AUTH-003      | [Khôi phục/đặt lại mật khẩu](./reset-password.md)                        | Khách hàng, Quản lý cửa hàng   | FORMAL         | Chương 3.2.2, tr. 48                                     |
| UC-AUTH-004      | [Đăng xuất](./logout.md)                                                 | Khách hàng, Quản lý cửa hàng   | REQUIREMENT    | Chương 3.1.2, tr. 39–41                                  |
| UC-AUTH-005      | [Đổi mật khẩu](./change-password.md)                                     | Khách hàng, Quản lý cửa hàng   | REQUIREMENT    | Chương 3.1.2, tr. 39–41                                  |
| UC-AUTH-006      | [Cập nhật thông tin cá nhân](./update-profile.md)                        | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-CAT-001       | [Xem chi tiết sản phẩm](./view-product-detail.md)                        | Khách hàng                     | FORMAL         | Chương 3.2.2, tr. 58                                     |
| UC-CAT-002       | [Xem danh sách sản phẩm](./browse-products.md)                           | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-CAT-003       | [Tìm kiếm sản phẩm](./search-products.md)                                | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-CAT-004       | [Lọc sản phẩm](./filter-products.md)                                     | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40; Chương 5.1.3–5.1.4                 |
| UC-CART-001      | [Thêm sản phẩm vào giỏ hàng](./add-to-cart.md)                           | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-CART-002      | [Cập nhật số lượng trong giỏ](./update-cart-item.md)                     | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-CART-003      | [Xóa sản phẩm khỏi giỏ](./remove-cart-item.md)                           | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-ORD-001       | [Đặt hàng](./place-order.md)                                             | Khách hàng                     | FORMAL         | Chương 3.2.2, tr. 57                                     |
| UC-ORD-002       | [Xem trạng thái đơn hàng](./view-order-status.md)                        | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-ORD-003       | [Hủy đơn hàng](./cancel-order.md)                                        | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-ORD-004       | [Xem lịch sử mua hàng](./view-order-history.md)                          | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-ORD-005       | [Tìm kiếm đơn hàng](./search-orders.md)                                  | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-ORD-006       | [Xem chi tiết đơn hàng](./view-order-detail.md)                          | Khách hàng                     | REQUIREMENT    | Chương 3.1.2, tr. 40                                     |
| UC-REV-001       | [Đánh giá sản phẩm sau khi mua](./review-purchased-product.md)           | Khách hàng                     | REQUIREMENT    | Chương 3.1.1, tr. 39                                     |
| UC-AI-001        | [Tương tác với chatbot AI Agent](./interact-chatbot.md)                  | Khách hàng                     | AI-SOURCE      | Chương 1; Chương 2.2.6–2.2.7; Chương 3.1.1; Chương 5.1.8 |
| UC-AI-002        | [Tìm kiếm sản phẩm bằng ngôn ngữ tự nhiên](./semantic-product-search.md) | Khách hàng                     | AI-SOURCE      | Chương 1.2; Chương 2.2.1; Chương 2.2.7; Chương 3.1.2     |
| UC-AI-003        | [Tư vấn lựa chọn sản phẩm](./consult-products.md)                        | Khách hàng                     | AI-SOURCE      | Chương 1; Chương 2.1.3; Chương 2.2.6                     |
| UC-AI-004        | [So sánh sản phẩm bằng AI](./compare-products.md)                        | Khách hàng                     | AI-SOURCE      | Chương 1.1–1.2; Chương 2.2.6; Chương 5.1.8               |
| UC-AI-005        | [Đánh giá/giải thích sản phẩm bằng AI](./evaluate-product.md)            | Khách hàng                     | AI-SOURCE      | Tên đề tài; Chương 1; Chương 2.2.6                       |
| UC-ADM-PROD-001  | [Xem danh sách sản phẩm](./admin-view-products.md)                       | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41                                     |
| UC-ADM-PROD-002  | [Tìm kiếm/lọc sản phẩm](./admin-search-filter-products.md)               | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41                                     |
| UC-ADM-PROD-003  | [Thêm sản phẩm](./admin-add-product.md)                                  | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 49                                     |
| UC-ADM-PROD-004  | [Chỉnh sửa sản phẩm](./admin-edit-product.md)                            | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 50                                     |
| UC-ADM-PROD-005  | [Xóa sản phẩm](./admin-delete-product.md)                                | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 50; rule ở Chương 3.1.2                |
| UC-ADM-PROD-006  | [Ẩn/ngừng trưng bày sản phẩm](./admin-hide-product.md)                   | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 51                                     |
| UC-ADM-PROD-007  | [Thêm biến thể sản phẩm](./admin-create-variant.md)                      | Quản lý cửa hàng               | IMPLEMENTATION | Chương 5.2.4, tr. 87                                     |
| UC-ADM-CUS-001   | [Xem danh sách khách hàng](./admin-view-customers.md)                    | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 19                            |
| UC-ADM-CUS-002   | [Tìm kiếm/lọc khách hàng](./admin-search-customers.md)                   | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 19                            |
| UC-ADM-CUS-003   | [Xem thông tin khách hàng](./admin-view-customer-detail.md)              | Quản lý cửa hàng               | REQUIREMENT    | Hình 19, tr. 51; Chương 3.1.2, tr. 42                    |
| UC-ADM-CUS-004   | [Xem đơn hàng của khách hàng](./admin-view-customer-orders.md)           | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 19                            |
| UC-ADM-CUS-005   | [Khóa/chặn tài khoản khách hàng](./admin-block-customer.md)              | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 19                            |
| UC-ADM-EMP-001   | [Xem danh sách nhân viên](./admin-view-employees.md)                     | Quản lý cửa hàng               | REQUIREMENT    | Hình 20, tr. 52                                          |
| UC-ADM-EMP-002   | [Tìm kiếm nhân viên](./admin-search-employees.md)                        | Quản lý cửa hàng               | REQUIREMENT    | Hình 20, tr. 52                                          |
| UC-ADM-EMP-003   | [Xem thông tin chi tiết nhân viên](./admin-view-employee-detail.md)      | Quản lý cửa hàng               | REQUIREMENT    | Hình 20, tr. 52                                          |
| UC-ADM-EMP-004   | [Thêm tài khoản nhân viên](./admin-add-employee.md)                      | Quản trị viên/Quản lý cửa hàng | FORMAL         | Chương 3.2.2, tr. 52                                     |
| UC-ADM-EMP-005   | [Chỉnh sửa tài khoản nhân viên](./admin-edit-employee.md)                | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 53                                     |
| UC-ADM-EMP-006   | [Khóa tài khoản nhân viên](./admin-lock-employee.md)                     | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 53                                     |
| UC-ADM-CAT-001   | [Xem danh mục sản phẩm](./admin-view-categories.md)                      | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-CAT-002   | [Thêm danh mục](./admin-add-category.md)                                 | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-CAT-003   | [Sửa danh mục](./admin-edit-category.md)                                 | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-CAT-004   | [Xóa danh mục](./admin-delete-category.md)                               | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-DIS-001   | [Xem danh sách khuyến mãi](./admin-view-discounts.md)                    | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 21                            |
| UC-ADM-DIS-002   | [Thêm giảm giá](./admin-add-discount.md)                                 | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 54                                     |
| UC-ADM-DIS-003   | [Cập nhật khuyến mãi](./admin-edit-discount.md)                          | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42; Hình 21                            |
| UC-ADM-DIS-004   | [Xóa giảm giá](./admin-delete-discount.md)                               | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 55                                     |
| UC-ADM-DIS-005   | [Khóa/ẩn giảm giá](./admin-lock-discount.md)                             | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 55                                     |
| UC-ADM-ORD-001   | [Xem danh sách đơn hàng](./admin-view-orders.md)                         | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 56                                     |
| UC-ADM-ORD-002   | [Xem chi tiết đơn hàng](./admin-view-order-detail.md)                    | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41; Hình 22                            |
| UC-ADM-ORD-003   | [Cập nhật trạng thái đơn hàng](./admin-update-order-status.md)           | Quản lý cửa hàng               | FORMAL         | Chương 3.2.2, tr. 56                                     |
| UC-ADM-ORD-004   | [Hủy đơn hàng khi có sự cố](./admin-cancel-order.md)                     | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41; Hình 22                            |
| UC-ADM-INV-001   | [Xem hóa đơn](./admin-view-invoices.md)                                  | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41–42                                  |
| UC-ADM-INV-002   | [Tìm kiếm/lọc hóa đơn](./admin-search-invoices.md)                       | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 41–42                                  |
| UC-ADM-PAY-001   | [Xem phương thức thanh toán](./admin-view-payment-methods.md)            | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-PAY-002   | [Cập nhật trạng thái thanh toán](./admin-update-payment-status.md)       | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-PAY-003   | [Tìm kiếm giao dịch thanh toán](./admin-search-transactions.md)          | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42                                     |
| UC-ADM-SUP-001   | [Xem danh sách nhà cung cấp](./admin-view-suppliers.md)                  | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 42–43                                  |
| UC-ADM-SUP-002   | [Thêm nhà cung cấp](./admin-add-supplier.md)                             | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 43                                     |
| UC-ADM-SUP-003   | [Sửa nhà cung cấp](./admin-edit-supplier.md)                             | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 43                                     |
| UC-ADM-SUP-004   | [Xóa nhà cung cấp](./admin-delete-supplier.md)                           | Quản lý cửa hàng               | REQUIREMENT    | Chương 3.1.2, tr. 43                                     |
| UC-ADM-BRAND-001 | [Quản lý thương hiệu](./admin-manage-brands.md)                          | Quản lý cửa hàng               | IMPLEMENTATION | Chương 5.2.11, tr. 91                                    |
| UC-ADM-DASH-001  | [Xem tổng quan quản trị](./admin-view-dashboard.md)                      | Quản lý cửa hàng               | IMPLEMENTATION | Chương 5.2.1, tr. 85                                     |
| UC-ADM-STAT-001  | [Xem thống kê](./admin-view-statistics.md)                               | Quản lý cửa hàng               | IMPLEMENTATION | Chương 5.2.7, tr. 89                                     |

## Source gap

- `recommend-pc-build.md`: không có trong report.
- `clarification-flow.md`: report không quy định AI bắt buộc hỏi lại.
- Invoice: có yêu cầu chức năng nhưng mô hình dữ liệu/triển khai không thể hiện rõ entity/module độc lập.
