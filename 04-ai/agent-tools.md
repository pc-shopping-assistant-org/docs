# Danh Sách Agent Tools (Quick Reference)

Hệ thống cung cấp **23 công cụ chuyên sâu** cho AI Agent, được tổ chức theo chuẩn **Clean Architecture (Ports & Adapters)** tại các vertical slices trong `capabilities/`.

---

## Bảng tra cứu nhanh các Tool

|  STT   | Tên Tool                            | Nhóm Capability        | Mục đích chính                                                                                                                          |
| :----: | :---------------------------------- | :--------------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| **1**  | `check_pc_compatibility`            | **PC Builder**         | Kiểm tra tương thích phần cứng đa chiều (Socket CPU vs Mainboard, RAM DDR4/DDR5, Form Factor vs Case, cấn tản khí, chiều dài VGA).      |
| **2**  | `calculate_psu_wattage`             | **PC Builder**         | Tính toán tổng TDP tiêu thụ ước tính và gợi ý công suất nguồn (PSU) chuẩn kèm biên an toàn dự phòng (headroom).                         |
| **3**  | `recommend_pc_build`                | **PC Builder**         | Đề xuất trọn bộ cấu hình PC tối ưu cân bằng theo mức ngân sách (VND) và mục đích (Gaming Esport/AAA, Đồ họa, Văn phòng, AI).            |
| **4**  | `find_compatible_alternatives`      | **PC Builder**         | Tìm linh kiện thay thế tương thích cùng chuẩn socket / chuẩn RAM khi linh kiện ban đầu hết hàng hoặc vượt ngân sách.                    |
| **5**  | `analyze_bottleneck_balance`        | **PC Builder**         | Đo lường tỉ lệ nghẽn cổ chai (%) giữa CPU và GPU theo từng độ phân giải (`1080P`, `1440P`, `4K`) và hướng dẫn cân bằng cấu hình.        |
| **6**  | `assess_upgrade_path`               | **PC Builder**         | Đánh giá tiềm năng nâng cấp dài hạn (vòng đời nền tảng socket AM5/LGA1700/AM4, công suất nguồn dư dả, chuẩn RAM DDR4/DDR5).             |
| **7**  | `recommend_monitor_and_peripherals` | **PC Builder**         | Gợi ý màn hình (kích thước, tấm nền IPS/OLED, tần số quét Hz tương xứng GPU) và combo bàn phím/chuột/tai nghe đồng bộ.                  |
| **8**  | `search_catalog_with_filters`       | **Shopping Assistant** | Tìm kiếm sản phẩm thông minh đa tiêu chí (từ khóa, danh mục linh kiện, khoảng giá min-max, lọc chỉ lấy hàng còn trong kho).             |
| **9**  | `check_promotions_and_vouchers`     | **Shopping Assistant** | Tự động tìm voucher, mã giảm giá tốt nhất cho đơn hàng hoặc bộ PC để tư vấn khách mua hàng tiết kiệm nhất.                              |
| **10** | `manage_cart`                       | **Shopping Assistant** | Thao tác giỏ hàng trực tiếp qua chat: xem tóm tắt giỏ (`VIEW`) hoặc thêm sản phẩm vào giỏ (`ADD_ITEM`).                                 |
| **11** | `track_order_status`                | **Shopping Assistant** | Tra cứu trạng thái vận chuyển đơn hàng, mã vận đơn bưu cục và ngày giao dự kiến theo mã đơn (order code).                               |
| **12** | `export_build_to_cart`              | **Shopping Assistant** | Đẩy toàn bộ dàn PC đã cấu hình (6–8 linh kiện) vào giỏ hàng chỉ trong 1 thao tác để sẵn sàng thanh toán.                                |
| **13** | `compare_products`                  | **Shopping Assistant** | So sánh đối đầu trực tiếp 2–4 linh kiện từ kho (bảng specs, xung nhịp, VRAM, TDP, bảo hành, chênh lệch giá và phân khúc).               |
| **14** | `get_product_detail_specs`          | **Shopping Assistant** | Lấy toàn bộ thông số kỹ thuật chi tiết của 1 linh kiện trong kho (số khe M.2 NVMe, VRM, cổng kết nối, công suất tản...).                |
| **15** | `query_store_policies`              | **Shopping Assistant** | Tra cứu chính sách dịch vụ chính thức của shop (miễn phí lắp ráp/cài win, lỗi 1 đổi 1 trong 15 ngày, bảo hành 24–36 tháng, trả góp 0%). |
| **16** | `search_hardware_compatibility`     | **Web Search (Live)**  | Tra cứu thực tế từ cộng đồng về tương thích linh kiện, cấn tản, cấn RAM, phiên bản BIOS cần nâng cấp (Reddit, TechPowerUp...).          |
| **17** | `search_product_reviews`            | **Web Search (Live)**  | Tra cứu review chuyên sâu, điểm benchmark, FPS chơi game thực tế, nhiệt độ hoạt động và độ ồn của linh kiện.                            |
| **18** | `search_build_guides`               | **Web Search (Live)**  | Tìm kiếm các cấu hình PC mẫu và hướng dẫn build tối ưu từ cộng đồng theo ngân sách và tựa game/phần mềm.                                |
| **19** | `search_game_requirements`          | **Web Search (Live)**  | Tra cứu cấu hình yêu cầu phần cứng chính thức của Game hoặc Phần mềm (Tối thiểu, Đề nghị, 2K/4K).                                       |
| **20** | `search_hardware_issues`            | **Web Search (Live)**  | Tra cứu các lỗi kỹ thuật nổi cộm, sự cố mất ổn định (Vmin Shift, crash, nóng chảy cáp 12VHPWR) hoặc cảnh báo thu hồi.                   |
| **21** | `search_psu_tier`                   | **Web Search (Live)**  | Tra cứu bảng xếp hạng an toàn chuẩn thế giới của bộ nguồn (PSU Cultists Tier List: Tier A, Tier B, Tier C...).                          |
| **22** | `search_driver_and_software`        | **Web Search (Live)**  | Tra cứu link tải Driver chính thức (VGA Game Ready Driver), bản cập nhật BIOS fix lỗi hoặc phần mềm điều khiển LED/quạt.                |
| **23** | `search_tech_specs_from_vendor`     | **Web Search (Live)**  | Tra cứu thông số kỹ thuật chuẩn từ trang chủ hãng sản xuất khi kho nội bộ thiếu dữ liệu (kích thước dài x rộng mm, chiều cao tản).      |

---

## Kiến trúc phân tầng (Clean Architecture)

```
[Agent Flow / Chatbot Orchestration]
                │
                ▼
     ┌───────────────────────┐
     │ capabilities/         │  -> Định nghĩa Pydantic Schemas & Tools
     │  ├─ pc_builder        │
     │  ├─ shopping_assistant│
     │  └─ web_search        │
     └──────────┬────────────┘
                │ phụ thuộc thông qua Ports (Dependency Inversion)
                ▼
     ┌───────────────────────┐
     │ application/ports/    │  -> Protocol & Domain Models
     │  ├─ hardware.py       │     (HardwareRuleEngine, ComponentSpec...)
     │  ├─ commerce.py       │     (CommerceClient, CatalogFilter...)
     │  └─ web_search.py     │     (WebSearchClient, WebSearchQuery...)
     └──────────▲────────────┘
                │ triển khai (Implements)
     ┌──────────┴────────────┐
     │ infrastructure/       │  -> Concrete Adapters
     │  ├─ hardware/         │     (LocalHardwareRuleEngine)
     │  ├─ commerce/         │     (BackendCommerceClient)
     │  └─ search/           │     (DuckDuckGoSearchAdapter)
     └───────────────────────┘
```

---

## Nguyên tắc cốt lõi (Domain Invariants)

1. **Grounded Catalog Data:** AI Agent không tự bịa đặt giá cả, số lượng tồn kho hay chính sách bán hàng. Dữ liệu thương mại luôn được lấy từ backend hoặc chính sách công bố chính thức.
2. **Khách quan & Đa nguồn:** Khi kho dữ liệu nội bộ thiếu thông tin hoặc khách hỏi về đánh giá thực tế/lỗi phần cứng, Agent kích hoạt `WebSearchTools` để tìm dữ liệu thời gian thực có dẫn chứng nguồn URL rõ ràng.
3. **An toàn công suất & Tương thích:** `calculate_psu_wattage` luôn tính biên an toàn tối thiểu 35% đối với tải thực tế của CPU và GPU nhằm bảo vệ linh kiện khỏi sụt áp (transient power spikes).
