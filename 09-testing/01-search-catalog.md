# Nhóm A: Search Catalog & Lọc Sản Phẩm (`SC-001` → `SC-020`)

Phạm vi: Kiểm thử tool `search_catalog`, chuẩn hóa query tiếng Việt, lọc khoảng giá/thương hiệu/spec, lọc bỏ sản phẩm `INACTIVE`, parallel search và hiển thị Carousel + inline link trên UI.

---

### SC-001 — Tìm kiếm CPU theo dòng sản phẩm (`AMD Ryzen`)

- **Tiền điều kiện:** Phiên chat mới trên `/assistant`; catalog có các CPU AMD Ryzen `ACTIVE`.
- **Các bước thực hiện:**
  1. Gửi: `Shop đang có những mẫu CPU AMD Ryzen nào? Cho mình xem giá và thông số cơ bản.`
  2. Gửi tiếp: `Mẫu nào trong số đó có đồ họa tích hợp (iGPU) để dùng văn phòng không cần card rời?`
- **Kỳ vọng:**
  - Lượt 1 gọi `search_catalog(query="Ryzen")` (hoặc tương đương), chỉ trả về SKU `ACTIVE` đúng giá từ DB.
  - Tên sản phẩm là inline link mở cùng tab; toàn bộ thẻ sản phẩm nằm trong 1 Carousel ngang ở cuối câu trả lời.
  - Lượt 2 phân biệt đúng CPU có/không có `has_integrated_graphics` theo dữ liệu thật.

### SC-002 — Lọc GPU NVIDIA theo khoảng giá chặt

- **Tiền điều kiện:** Phiên mới; có GPU NVIDIA nằm trong và ngoài khoảng 10–15 triệu.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình card đồ họa NVIDIA giá từ 10 đến 15 triệu đang bán ở shop.`
  2. Gửi tiếp: `Nếu mình nới ngân sách lên tối đa 18 triệu thì có thêm lựa chọn nào mạnh hơn không?`
- **Kỳ vọng:**
  - Gọi `search_catalog` với `brand="NVIDIA"`, `min_price=10000000`, `max_price=15000000`.
  - Không lọt GPU AMD hoặc sản phẩm ngoài khoảng giá ở Lượt 1; Lượt 2 mở rộng đúng tới `18000000`.

### SC-003 — Tìm màn hình theo semantic query + trần giá

- **Tiền điều kiện:** Catalog có danh mục màn hình (`MONITOR`).
- **Các bước thực hiện:**
  1. Gửi: `Shop có màn hình chơi game tần số quét cao từ 144Hz trở lên giá dưới 6 triệu không?`
- **Kỳ vọng:**
  - Dùng `semantic_query` + `max_price=6000000`, liệt kê đúng màn hình đạt điều kiện; không bịa tần số quét nếu DB không ghi.

### SC-004 — Tìm bộ nguồn PSU theo công suất và chuẩn hiệu suất

- **Tiền điều kiện:** Catalog có PSU từ 550W đến 1000W.
- **Các bước thực hiện:**
  1. Gửi: `Cho mình xem các bộ nguồn PSU công suất từ 750W chuẩn 80 Plus Gold trở lên hiện có của shop.`
  2. Gửi tiếp: `Mẫu nào rẻ nhất trong số đó và có đủ ổn cho RTX 4070 Super không?`
- **Kỳ vọng:**
  - Lọc đúng PSU >= 750W chuẩn Gold; Lượt 2 so sánh giá chính xác theo DB.

### SC-005 — Tìm kit RAM DDR5 32GB (phân biệt DDR4 / 16GB)

- **Tiền điều kiện:** Catalog có cả RAM DDR4 và DDR5, dung lượng 16GB và 32GB.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình các kit RAM DDR5 tổng dung lượng 32GB (2x16GB) đang có hàng.`
- **Kỳ vọng:**
  - Kết quả chỉ gồm RAM DDR5 32GB; không trộn DDR4 hoặc kit 16GB vào danh sách đạt yêu cầu.

### SC-006 — Tìm SSD NVMe PCIe Gen 4 dung lượng 1TB–2TB

- **Tiền điều kiện:** Catalog có cả SSD NVMe và SSD SATA 2.5".
- **Các bước thực hiện:**
  1. Gửi: `Shop có ổ cứng SSD NVMe PCIe Gen 4 dung lượng 1TB hoặc 2TB nào đáng mua?`
- **Kỳ vọng:**
  - Chỉ đưa SSD chuẩn M.2 NVMe (loại bỏ ổ SATA 2.5" hoặc dung lượng 256GB/500GB).

### SC-007 — Tìm tản nhiệt nước AIO theo màu sắc & kích thước radiator

- **Tiền điều kiện:** Catalog có tản AIO 240mm/360mm và tản khí.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình tản nhiệt nước AIO kích thước 240mm hoặc 360mm màu đen cho CPU.`
- **Kỳ vọng:**
  - Semantic search lọc đúng tản nước AIO (không lẫn tản khí giá rẻ).

### SC-008 — Tìm vỏ case theo kiểu dáng + form factor mainboard

- **Tiền điều kiện:** Catalog có nhiều mẫu Case (mATX, ATX, bể cá).
- **Các bước thực hiện:**
  1. Gửi: `Shop có vỏ case mặt kính dạng bể cá hỗ trợ mainboard ATX giá tầm 1.5 đến 2.5 triệu không?`
- **Kỳ vọng:**
  - Trả về đúng các mẫu case hỗ trợ `ATX` trong tầm 1.5–2.5 triệu, kèm `max_gpu_length_mm` nếu có.

### SC-009 — Thu hẹp tìm kiếm đa lượt (Multi-turn Narrowing)

- **Tiền điều kiện:** Catalog có nhiều mainboard AM5.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình các mẫu mainboard socket AM5 đang bán ở shop.`
  2. Gửi tiếp: `Trong đống đó lọc lại giúp mình những con có hỗ trợ Wi-Fi và có đủ 4 khe RAM nhé.`
- **Kỳ vọng:**
  - Lượt 2 giữ ngữ cảnh socket `AM5`, gọi lại `search_catalog` / đọc details để lọc đúng mẫu có 4 khe RAM và Wi-Fi.

### SC-010 — Tìm kiếm song song nhiều danh mục phụ kiện (`CallToolsAction`)

- **Tiền điều kiện:** Catalog có chuột và bàn phím cơ.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình chuột gaming không dây siêu nhẹ dưới 2 triệu và bàn phím cơ layout TKL dưới 2.5 triệu trong cùng lần tìm này nhé.`
- **Kỳ vọng:**
  - Agent gọi 2 `search_catalog` song song trong 1 batch; thẻ chuột và bàn phím gom chung vào 1 Carousel cuối câu trả lời.

### SC-011 — Tìm sản phẩm không kinh doanh (Laptop / Apple)

- **Tiền điều kiện:** Shop chỉ bán linh kiện PC/gaming gear, không bán Apple Studio Display hay laptop mẫu lạ.
- **Các bước thực hiện:**
  1. Gửi: `Shop có bán màn hình Apple Studio Display 5K hay laptop ASUS ROG Zephyrus G16 bản mới nhất không?`
- **Kỳ vọng:**
  - Gọi `search_catalog`, xác nhận không có sản phẩm khớp trong shop; không bịa giá hoặc link giả.

### SC-012 — Lọc GPU theo dung lượng VRAM lớn cho AI

- **Tiền điều kiện:** Catalog có GPU 8GB, 12GB, 16GB, 24GB VRAM.
- **Các bước thực hiện:**
  1. Gửi: `Mình cần tìm các mẫu card đồ họa có từ 16GB VRAM trở lên để chạy AI local, shop có những mã nào?`
- **Kỳ vọng:**
  - Chỉ liệt kê card >= 16GB VRAM (không đưa RTX 4060 8GB hay 3060 12GB vào nhóm đạt chuẩn).

### SC-013 — Đảm bảo không trả về sản phẩm `INACTIVE` / ngừng kinh doanh

- **Tiền điều kiện:** Có ít nhất 1 sản phẩm trong DB đặt trạng thái `INACTIVE` (hoặc hết catalog).
- **Các bước thực hiện:**
  1. Gửi: `Tìm tất cả CPU Intel đang mở bán ở shop.`
- **Kỳ vọng:**
  - Sản phẩm `INACTIVE` tuyệt đối không xuất hiện trong câu trả lời hay Carousel.

### SC-014 — Tìm tản nhiệt khí ngân sách thấp dưới 600k

- **Tiền điều kiện:** Catalog có tản khí phổ thông.
- **Các bước thực hiện:**
  1. Gửi: `Tìm tản nhiệt khí cho CPU văn phòng giá dưới 600 nghìn đồng.`
- **Kỳ vọng:**
  - Đúng khoảng giá `<= 600000`, nêu rõ socket hỗ trợ nếu có.

### SC-015 — Tìm song song 2 dòng chipset Mainboard (B650M và B760M)

- **Tiền điều kiện:** Catalog có cả B650M (AM5) và B760M (LGA1700).
- **Các bước thực hiện:**
  1. Gửi: `Liệt kê giúp mình vài mẫu mainboard B650M và B760M phổ biến hiện có ở shop.`
- **Kỳ vọng:**
  - Phân tách rõ 2 nhóm socket AM5 (B650M) và LGA1700 (B760M) để người dùng không mua nhầm.

### SC-016 — Tìm GPU kích thước ngắn lắp Case Mini-ITX

- **Tiền điều kiện:** Catalog có GPU 2 quạt (<250mm) và 3 quạt (>300mm).
- **Các bước thực hiện:**
  1. Gửi: `Case mini của mình chỉ lắp được card dài tối đa 250mm, shop có mẫu card NVIDIA nào ngắn dưới 250mm không?`
- **Kỳ vọng:**
  - Kiểm tra `gpu_length_mm <= 250` từ spec thật; không đề xuất card 3 quạt dài >250mm.

### SC-017 — Hỏi mặt hàng ngoài danh mục (Ghế / Bàn)

- **Tiền điều kiện:** Shop không kinh doanh nội thất bàn/ghế.
- **Các bước thực hiện:**
  1. Gửi: `Shop có bán bàn nâng hạ thông minh và ghế công thái học Herman Miller không?`
- **Kỳ vọng:**
  - Search catalog trả rỗng → AI từ chối lịch sự, nêu đúng phạm vi sản phẩm shop đang bán.

### SC-018 — Xử lý query viết tắt, không dấu, tiếng lóng

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `tim giup minh ssd nvme gen4 2tb gia duoi 5tr`
- **Kỳ vọng:**
  - Agent chuẩn hóa sang query sạch (`SSD NVMe Gen4 2TB`, `max_price=5000000`) và trả về đúng sản phẩm.

### SC-019 — Đổi tiêu chí tìm kiếm hoàn toàn ở lượt kế tiếp

- **Tiền điều kiện:** Đã tìm ở Lượt 1.
- **Các bước thực hiện:**
  1. Gửi: `Tìm RAM 16GB DDR4 giá rẻ.`
  2. Gửi tiếp: `Thôi đổi ý rồi, tìm giúp mình kit RAM 32GB DDR5 bus cao thay thế nhé.`
- **Kỳ vọng:**
  - Lượt 2 không còn dính điều kiện `DDR4` hay `16GB` của Lượt 1.

### SC-020 — Tìm trọn bộ Gaming Gear (Chuột + Phím + Tai nghe)

- **Tiền điều kiện:** Catalog có cả 3 loại phụ kiện.
- **Các bước thực hiện:**
  1. Gửi: `Gợi ý giúp mình 1 chuột gaming, 1 bàn phím cơ và 1 tai nghe chụp tai tầm giá khoảng 1 triệu mỗi món.`
- **Kỳ vọng:**
  - Gọi batch tìm kiếm cho 3 nhóm, tổng hợp đầy đủ 3 nhóm trong câu trả lời và gom tất cả thẻ vào 1 Carousel.
