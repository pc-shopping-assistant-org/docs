# Nhóm C: So Sánh Sản Phẩm (`SC-037` → `SC-052`)

Phạm vi: Kiểm thử tool `compare_products`, khả năng đối chiếu nhiều SKU cùng phân khúc, phân tích ưu/nhược điểm dựa trên spec thật và từ chối so sánh sai phạm vi.

---

### SC-037 — So sánh 2 GPU đối đầu (NVIDIA vs AMD)

- **Tiền điều kiện:** Có RTX 4060 và RX 7600 (hoặc 2 GPU ngang tầm) trong catalog.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình card RTX 4060 và RX 7600 đang bán ở shop về giá, hiệu năng, VRAM và mức ăn điện.`
- **Kỳ vọng:**
  - Gọi `search_catalog` lấy ID 2 sản phẩm → gọi `compare_products`, xuất bảng so sánh chuẩn xác từng chỉ số và gợi ý theo nhu cầu (gaming thuần vs AI/CUDA).

### SC-038 — So sánh 2 CPU phổ biến khác nền tảng (AM5 vs LGA1700)

- **Tiền điều kiện:** Có Ryzen 5 7600 và Core i5-14400F (hoặc 12400F) trong catalog.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình AMD Ryzen 5 7600 và Intel Core i5-14400F: con nào chơi game và làm việc đa nhiệm ngon hơn?`
- **Kỳ vọng:**
  - Nêu rõ khác biệt `socket`, `performance_score`, `core_count`, `tdp_watts`, iGPU và hệ sinh thái DDR4/DDR5.

### SC-039 — So sánh 3 Mainboard cùng socket trong 1 tầm giá

- **Tiền điều kiện:** Có >= 3 mainboard B650 hoặc B760.
- **Các bước thực hiện:**
  1. Gửi: `So sánh 3 mẫu mainboard B650 tầm giá 3 đến 5 triệu trong shop xem con nào nhiều khe M.2 và khe RAM hơn.`
- **Kỳ vọng:**
  - Dùng `compare_products` cho cả 3 SKU, chỉ ra đúng mẫu lợi thế về `ram_slots`, `m2_slots`, `form_factor`.

### SC-040 — So sánh 2 PSU cùng công suất khác chuẩn (Bronze vs Gold)

- **Tiền điều kiện:** Có PSU Bronze và Gold cùng mức ~650W hoặc 750W.
- **Các bước thực hiện:**
  1. Gửi: `So sánh 2 bộ nguồn 750W: bản 80 Plus Bronze giá mềm và bản 80 Plus Gold cao cấp hơn của shop.`
- **Kỳ vọng:**
  - So sánh rõ chênh lệch giá, `psu_tier`, `efficiency_rating` và tư vấn khi nào nên nâng lên Gold.

### SC-041 — So sánh 2 kit RAM khác bus / dung lượng

- **Tiền điều kiện:** Có >= 2 kit RAM DDR5.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình kit RAM DDR5 32GB bus 6000 với kit DDR5 32GB bus 5200 (hoặc 16GB) đang có ở shop.`
- **Kỳ vọng:**
  - Nêu đúng dung lượng, số thanh (`kit_modules`), giá trên mỗi GB.

### SC-042 — So sánh 2 Vỏ Case về khả năng tương thích phần cứng

- **Tiền điều kiện:** Có >= 2 mẫu Case.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình 2 mẫu vỏ case tầm 1 đến 2 triệu xem con nào gắn được GPU dài hơn và hỗ trợ tản nước 360mm.`
- **Kỳ vọng:**
  - Đối chiếu trực tiếp `max_gpu_length_mm`, `max_cooler_height_mm`, `max_radiator_mm`.

### SC-043 — So sánh 2 ổ cứng SSD NVMe cùng dung lượng

- **Tiền điều kiện:** Có >= 2 SSD NVMe 1TB.
- **Các bước thực hiện:**
  1. Gửi: `So sánh 2 mẫu SSD NVMe 1TB đang có ở shop xem con nào hiệu năng tốt hơn để làm ổ cài Windows và game.`
- **Kỳ vọng:**
  - So sánh đúng `performance_score`, `price`, chuẩn giao tiếp.

### SC-044 — So sánh 2 Màn hình cho nhu cầu kép (Đồ họa + Gaming)

- **Tiền điều kiện:** Có >= 2 màn hình 27" hoặc 24".
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình 2 mẫu màn hình 2K trong shop xem con nào hợp vừa làm thiết kế vừa chơi game hơn.`
- **Kỳ vọng:**
  - Dựa đúng vào spec màn hình có trong DB, không bịa % sRGB nếu DB không có.

### SC-045 — So sánh tiếp nối từ kết quả tìm kiếm ở lượt trước

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình các mẫu RTX 4070 / 4070 Super đang bán ở shop.`
  2. Gửi tiếp: `So sánh 2 mẫu đầu tiên về kích thước chiều dài và giá tiền nhé.`
- **Kỳ vọng:**
  - Lượt 2 dùng đúng 2 `product_id` từ Lượt 1 đưa vào `compare_products`.

### SC-046 — Yêu cầu so sánh 2 linh kiện khác hẳn loại

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình CPU Core i5-14400F với GPU RTX 4060 xem con nào mạnh hơn.`
- **Kỳ vọng:**
  - Giải thích rõ CPU và GPU đảm nhiệm vai trò khác nhau (xử lý logic vs đồ họa), không ép so điểm 1-1 vô nghĩa.

### SC-047 — Yêu cầu so sánh quá nhiều sản phẩm (> 4 món)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `So sánh chi tiết 6 mẫu card đồ họa tầm trung trong shop giúp mình.`
- **Kỳ vọng:**
  - Tuân thủ giới hạn của `compare_products`, chọn 3–4 mẫu tiêu biểu nhất hoặc chia 2 batch hợp lý mà không văng lỗi schema.

### SC-048 — So sánh 2 Chuột / Bàn phím gaming cùng phân khúc

- **Tiền điều kiện:** Có >= 2 chuột/bàn phím.
- **Các bước thực hiện:**
  1. Gửi: `So sánh 2 mẫu chuột không dây tầm 1.5 đến 2 triệu đang bán ở shop.`
- **Kỳ vọng:**
  - Đọc đúng `extra_specs` (trọng lượng, sensor, pin, kết nối) từ catalog.

### SC-049 — So sánh CPU có iGPU và CPU F-series khi build không card rời

- **Tiền điều kiện:** Có Ryzen 5 8600G/7600 và Core i5-12400F/14400F.
- **Các bước thực hiện:**
  1. Gửi: `So sánh Ryzen 5 8600G và Intel Core i5-12400F nếu mình chỉ mua về làm văn phòng không gắn card rời.`
- **Kỳ vọng:**
  - Chỉ rõ `12400F` không có iGPU nên không xuất hình được nếu thiếu card rời.

### SC-050 — So sánh tổng chi phí nền tảng (AM5 DDR5 vs LGA1700 DDR4)

- **Tiền điều kiện:** Có linh kiện cả 2 nền tảng.
- **Các bước thực hiện:**
  1. Gửi: `So sánh tổng chi phí combo CPU + Main + 16GB RAM giữa nền tảng AM5 DDR5 và LGA1700 DDR4 hiện tại ở shop.`
- **Kỳ vọng:**
  - Cộng đúng tổng giá các SKU thật trong shop, nêu rõ đánh đổi về khả năng nâng cấp.

### SC-051 — So sánh Tản nhiệt khí tháp đôi vs Tản nước AIO 240mm

- **Tiền điều kiện:** Có cả tản khí và AIO 240mm.
- **Các bước thực hiện:**
  1. Gửi: `So sánh 1 mẫu tản nhiệt khí tốt với 1 mẫu tản nước AIO 240mm của shop xem chọn loại nào cho CPU tầm trung.`
- **Kỳ vọng:**
  - So sánh giá, TDP, kích thước lắp case (`cooler_height_mm` vs `radiator_mm`).

### SC-052 — So sánh 1 sản phẩm của shop với 1 sản phẩm ngoài thị trường

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `So sánh mẫu RTX 4060 rẻ nhất của shop với card Intel Arc B580 (nếu shop chưa bán).`
- **Kỳ vọng:**
  - RTX 4060 lấy từ `catalog`; Intel Arc B580 ghi rõ không có trong catalog shop (hoặc tra web research có trích nguồn rõ ràng).
