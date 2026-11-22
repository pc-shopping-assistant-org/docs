# Nhóm B: Chi Tiết Sản Phẩm & Thông Số Kỹ Thuật (`SC-021` → `SC-036`)

Phạm vi: Kiểm thử tool `get_product_details`, truy xuất chính xác các trường `specifications` / `extra_specs`, bảo toàn sự thật khi thiếu dữ liệu spec và kiểm tra giá live.

---

### SC-021 — Xem thông số đầy đủ của CPU

- **Tiền điều kiện:** Có CPU `AMD Ryzen 5 7600` (hoặc mã tương đương) trong catalog.
- **Các bước thực hiện:**
  1. Gửi: `Xem chi tiết thông số kỹ thuật của AMD Ryzen 5 7600 đang bán trong shop giúp mình.`
- **Kỳ vọng:**
  - Gọi `search_catalog` → `get_product_details`, nêu chính xác socket (`AM5`), `tdp_watts`, `core_count`, `has_integrated_graphics`, giá bán và link sản phẩm.

### SC-022 — Kiểm tra kích thước vật lý & yêu cầu nguồn của GPU

- **Tiền điều kiện:** Có GPU RTX 4070 Super (hoặc RTX 4060 Ti) trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Con card RTX 4070 Super của shop dài chính xác bao nhiêu mm và mức TDP của nó là bao nhiêu W?`
- **Kỳ vọng:**
  - Trả lời đúng `gpu_length_mm` và `tdp_watts` từ `get_product_details`, không đoán kích thước theo trí nhớ chung.

### SC-023 — Kiểm tra số khe RAM, khe M.2 và Form Factor của Mainboard

- **Tiền điều kiện:** Có Mainboard B650M / B760M trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Mainboard MSI B650M Gaming Plus ở shop dùng chuẩn RAM gì, có mấy khe RAM, mấy khe M.2 và kích thước chuẩn nào?`
- **Kỳ vọng:**
  - Đọc đúng `ram_type`, `ram_slots`, `m2_slots`, `form_factor` từ spec thật.

### SC-024 — Kiểm tra giới hạn lắp đặt của Vỏ Case

- **Tiền điều kiện:** Có vỏ case Montech Air 100 (hoặc vỏ case bất kỳ) trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Vỏ case Montech Air 100 hỗ trợ những cỡ mainboard nào, gắn được card dài tối đa bao nhiêu mm và tản nhiệt khí cao bao nhiêu mm?`
- **Kỳ vọng:**
  - Trả lời đúng `supported_form_factors`, `max_gpu_length_mm`, `max_cooler_height_mm`, `max_radiator_mm`.

### SC-025 — Kiểm tra CPU có kèm Stock Cooler & iGPU hay không

- **Tiền điều kiện:** Có CPU `Core i5-12400F` (hoặc F-series không iGPU) trong DB.
- **Các bước thực hiện:**
  1. Gửi: `CPU Intel Core i5-12400F trong shop có sẵn quạt tản nhiệt đi kèm trong hộp không và có GPU tích hợp để xuất hình không?`
- **Kỳ vọng:**
  - Nêu chính xác `includes_stock_cooler` và `has_integrated_graphics=False` (nhấn mạnh bắt buộc phải có card rời mới xuất hình).

### SC-026 — Kiểm tra thông số Nguồn (PSU Tier & Chuẩn 80 Plus)

- **Tiền điều kiện:** Có PSU MSI MAG A550BN hoặc nguồn Gold trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Cho mình xem chi tiết bộ nguồn MSI MAG A550BN: công suất thực, chuẩn hiệu suất 80 Plus và đánh giá tier.`
- **Kỳ vọng:**
  - Đọc đúng `wattage`, `efficiency_rating`, `psu_tier` từ catalog.

### SC-027 — Theo dõi chi tiết theo tham chiếu từ lượt tìm kiếm trước

- **Tiền điều kiện:** Phiên chat mới.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình các mẫu card RTX 4060 đang có ở shop.`
  2. Gửi tiếp: `Xem chi tiết thông số kỹ thuật của mẫu rẻ nhất trong danh sách vừa rồi nhé.`
- **Kỳ vọng:**
  - Lượt 2 xác định đúng SKU rẻ nhất từ kết quả Lượt 1 và gọi `get_product_details(product_id=...)`.

### SC-028 — Kiểm tra chuẩn giao tiếp & tốc độ SSD

- **Tiền điều kiện:** Có SSD NVMe (vd Samsung 990 Pro / Kingston NV2).
- **Các bước thực hiện:**
  1. Gửi: `Ổ cứng SSD NVMe 1TB của shop dùng chuẩn giao tiếp gì, kích thước M.2 hay 2.5 inch?`
- **Kỳ vọng:**
  - Trả lời đúng `interface`, `form_factor`, `capacity_gb`; chỉ nêu tốc độ đọc/ghi MB/s nếu field đó thực sự có trong DB.

### SC-029 — Kiểm tra danh sách Socket hỗ trợ của Tản nhiệt

- **Tiền điều kiện:** Có tản khí / tản AIO trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Mẫu tản nhiệt khí tầm trung của shop có lắp vừa socket AM5 và LGA1700 không? Xem giúp mình 1 mẫu cụ thể.`
- **Kỳ vọng:**
  - Gọi `get_product_details` và kiểm tra trực tiếp trường `supported_sockets`.

### SC-030 — Xem chi tiết phụ kiện ngoại vi (Chuột / Bàn phím)

- **Tiền điều kiện:** Có chuột hoặc bàn phím cơ trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Xem chi tiết thông số của một mẫu chuột gaming không dây bán chạy ở shop (kết nối, cảm biến, trọng lượng).`
- **Kỳ vọng:**
  - Trích đúng các thuộc tính ngoại vi có trong `specifications`.

### SC-031 — Kiểm tra giá live khi giá DB vừa thay đổi

- **Tiền điều kiện:** Thực hiện ở 2 phiên/run khác nhau hoặc sau khi cập nhật giá sản phẩm trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Giá bán hiện tại của AMD Ryzen 5 7600 tại shop là bao nhiêu?`
- **Kỳ vọng:**
  - Gọi tool lấy giá mới nhất từ `catalog-service`, không dùng giá cũ từ trí nhớ LLM.

### SC-032 — Xem chi tiết Màn hình (Tấm nền, Độ phân giải, Tần số quét)

- **Tiền điều kiện:** Có màn hình trong DB.
- **Các bước thực hiện:**
  1. Gửi: `Xem chi tiết 1 mẫu màn hình 27 inch 2K của shop: dùng tấm nền gì, tần số quét bao nhiêu Hz?`
- **Kỳ vọng:**
  - Đọc đúng spec màn hình và gắn link sản phẩm hợp lệ.

### SC-033 — Hỏi thông số không tồn tại trong Database (Anti-Hallucination)

- **Tiền điều kiện:** DB không lưu độ ồn dBA hoặc RPM quạt của PSU/Case.
- **Các bước thực hiện:**
  1. Gửi: `Quạt của bộ nguồn 750W đang bán ở shop quay tối đa bao nhiêu RPM và độ ồn bao nhiêu dBA ở tải 50%?`
- **Kỳ vọng:**
  - AI nói rõ thông số RPM/dBA hiện chưa có trong dữ liệu sản phẩm của shop, không tự bịa số liệu.

### SC-034 — Tìm và xem chi tiết bằng mã SKU / tên đầy đủ dài

- **Tiền điều kiện:** Lấy chính xác 1 tên sản phẩm dài từ catalog.
- **Các bước thực hiện:**
  1. Gửi: `Cho mình xem thông số chi tiết và giá của "<Tên sản phẩm đầy đủ copy từ DB>".`
- **Kỳ vọng:**
  - Khớp chính xác đúng biến thể đó, không nhầm sang phiên bản khác dung lượng/hãng.

### SC-035 — Phân tách dữ liệu Shop vs Kiến thức tham khảo

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `CPU Ryzen 5 7600 của shop có hỗ trợ chuẩn PCIe 5.0 không và giá tại shop đang là bao nhiêu?`
- **Kỳ vọng:**
  - Giá lấy từ `get_product_details`; nếu DB không có trường PCIe 5.0 thì tách bạch rõ thông tin spec hãng tham khảo với dữ liệu catalog.

### SC-036 — Hỏi thông tin tồn kho / tình trạng mở bán

- **Tiền điều kiện:** Sản phẩm đang `ACTIVE`.
- **Các bước thực hiện:**
  1. Gửi: `Mẫu RTX 4060 rẻ nhất của shop hiện còn hàng để đặt không và giá là bao nhiêu?`
- **Kỳ vọng:**
  - Kiểm tra từ `catalog-service`, báo đúng trạng thái tồn kho/mở bán thực tế.
