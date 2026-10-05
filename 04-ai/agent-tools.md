# Agent tools

Các tool được tổ chức theo chuẩn Clean Architecture (Ports & Adapters) tại các vertical slices trong `capabilities/`:

### 1. PC Builder Tools (`capabilities.pc_builder.PCBuilderTools`)
- `check_pc_compatibility`: Kiểm tra tương thích vật lý và điện năng giữa các linh kiện (CPU Socket vs Mainboard, RAM DDR4/DDR5, Mainboard Form Factor vs Vỏ Case, Chiều dài VGA, Chiều cao tản nhiệt khí).
- `calculate_psu_wattage`: Tính toán tổng TDP tiêu thụ tối đa ước tính và gợi ý công suất nguồn (PSU) khuyên dùng kèm biên an toàn.
- `recommend_pc_build`: Đề xuất trọn bộ cấu hình PC cân bằng tối ưu theo mức ngân sách và mục đích sử dụng (Gaming Esport, Gaming AAA, Đồ họa, Văn phòng).
- `find_compatible_alternatives`: Tìm linh kiện thay thế tương thích cùng socket / chuẩn RAM khi linh kiện ban đầu hết hàng hoặc vượt ngân sách.

### 2. Shopping Assistant Tools (`capabilities.shopping_assistant.ShoppingAssistantTools`)
- `search_catalog_with_filters`: Tìm kiếm sản phẩm đa tiêu chí (keyword, category, min/max price, in_stock).
- `check_promotions_and_vouchers`: Tra cứu mã giảm giá, voucher khuyến mãi tối ưu theo giá trị đơn hàng hoặc danh mục linh kiện.
- `manage_cart`: Xem tóm tắt giỏ hàng (`VIEW`) hoặc thêm sản phẩm vào giỏ hàng (`ADD_ITEM`).
- `track_order_status`: Tra cứu trạng thái vận chuyển và giao nhận của đơn hàng theo mã đơn.
- `export_build_to_cart`: Đẩy toàn bộ dàn PC đã cấu hình vào giỏ hàng chỉ trong một thao tác.

### 3. Web Search Tools (`capabilities.web_search.WebSearchTools`)
Cung cấp khả năng tra cứu dữ liệu thời gian thực trên Internet không phụ thuộc vào hardcode trong code:
- `search_hardware_compatibility`: Tra cứu thực tế về tương thích vật lý/kích thước, cấn tản nhiệt, phiên bản BIOS cần nâng cấp (từ Reddit, Tom's Hardware, TechPowerUp).
- `search_product_reviews`: Tra cứu review chuyên sâu, điểm benchmark, FPS chơi game thực tế, nhiệt độ và độ ồn hoạt động.
- `search_build_guides`: Tìm kiếm các cấu hình PC mẫu và hướng dẫn build tối ưu từ cộng đồng theo ngân sách và tựa game/phần mềm.
- `search_game_requirements`: Tra cứu cấu hình phần cứng yêu cầu chính thức của Game hoặc Phần mềm đồ họa (Tối thiểu, Đề nghị, 2K/4K).
- `search_hardware_issues`: Kiểm tra các lỗi kỹ thuật nổi cộm, sự cố mất ổn định (Vmin Shift, crash, nóng chảy cáp, firmware bug) hoặc cảnh báo thu hồi.
- `search_psu_tier`: Tra cứu bảng xếp hạng an toàn chuẩn thế giới của bộ nguồn (PSU Cultists Tier List: Tier A, Tier B, Tier C...).

Tool results tuân thủ chặt chẽ domain invariants: không tự tạo giá ảo, không tự phán đoán tương thích sai lệch mà dựa trên `HardwareRuleEngine`, `WebSearchClient` thời gian thực và backend commerce APIs.


