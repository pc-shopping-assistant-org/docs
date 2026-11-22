# Nhóm F: Optimizer Constraints — Objectives, Soft/Hard Prefs, Owned & Pinned (`SC-097` → `SC-116`)

Phạm vi: Kiểm thử `BuildObjective`, `apply_soft_preferences` (`locked=False`), hard locks (`locked=True`), `owned_parts`, `pinned_parts`, tính đơn điệu ngân sách và hiệu năng trên catalog lớn.

---

### SC-097 — Objective `PERFORMANCE` (Tối đa hiệu năng)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 1440p tầm 30 triệu, mình muốn dồn tối đa tiền vào hiệu năng CPU/GPU mạnh nhất có thể.`
- **Kỳ vọng:**
  - Chọn `BuildObjective.PERFORMANCE`, điểm benchmark GPU/CPU cao nhất trong tầm 30 triệu.

### SC-098 — Objective `BALANCED` (Cân bằng & bền bỉ)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 1440p tầm 30 triệu theo hướng cân bằng, nguồn tốt và ổn định lâu dài.`
- **Kỳ vọng:**
  - Chọn `BuildObjective.BALANCED`, cân đối `psu_quality` + `platform_longevity` + `gpu_perf`.

### SC-099 — Objective `UPGRADE_FRIENDLY` (Dễ nâng cấp về sau)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build PC 30 triệu ưu tiên nền tảng dễ nâng cấp CPU, RAM và card đồ họa trong 3-4 năm tới.`
- **Kỳ vọng:**
  - Chọn `BuildObjective.UPGRADE_FRIENDLY`: ưu tiên socket mới (`AM5`/`LGA1851`), mainboard 4 khe RAM, PSU headroom lớn.

### SC-100 — Soft Preference GPU NVIDIA (`locked=False`)

- **Tiền điều kiện:** Catalog có cả GPU AMD và NVIDIA ngang tầm giá.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 25 triệu, mình hơi ưu tiên card NVIDIA một chút nhưng nếu AMD hợp lý hơn hẳn thì vẫn ok.`
- **Kỳ vọng:**
  - Cộng `+3.0` (`soft_pref_gpu_brand`) cho build có card NVIDIA khi điểm gốc xấp xỉ nhau.

### SC-101 — Hard Lock GPU NVIDIA (`locked=True`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 25 triệu, bắt buộc phải dùng card đồ họa NVIDIA GeForce, tuyệt đối không lấy AMD.`
- **Kỳ vọng:**
  - Lọc cứng ở tầng candidate (`preferred_gpu_brand.locked=True`), 100% build đề xuất dùng NVIDIA.

### SC-102 — Soft Preference hãng không có hàng (Graceful Fallback)

- **Tiền điều kiện:** Ngân sách thấp mà phân khúc đó chỉ có CPU Intel (không có AMD).
- **Các bước thực hiện:**
  1. Gửi: `Build PC văn phòng 9 triệu, ưu tiên chip AMD nếu có, không có thì lấy Intel cũng được.`
- **Kỳ vọng:**
  - Không bị lỗi `NoFeasibleBuildError`; tự động fallback sang Intel và giải thích rõ.

### SC-103 — Hard Lock xung đột (CPU Intel + Mainboard AM5)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build giúp mình dàn PC bắt buộc dùng chip Intel Core i5 nhưng phải gắn trên mainboard B650M AM5.`
- **Kỳ vọng:**
  - Từ chối vì mâu thuẫn vật lý giữa 2 ràng buộc khóa cứng, gợi ý hướng tháo gỡ cho người dùng.

### SC-104 — Soft Preference Form Factor Micro-ATX

- **Tiền điều kiện:** Catalog có cả ATX và Micro-ATX.
- **Các bước thực hiện:**
  1. Gửi: `Mình thích dàn máy gọn gàng chuẩn Micro-ATX để trên bàn, ngân sách 24 triệu chơi game 1080p.`
- **Kỳ vọng:**
  - Cộng `soft_pref_form_factor` cho main Micro-ATX + case hỗ trợ mATX.

### SC-105 — Hard Lock Form Factor ATX

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Bắt buộc phải dùng mainboard chuẩn ATX đầy đủ và vỏ case ATX cho rộng rãi, ngân sách 32 triệu.`
- **Kỳ vọng:**
  - Không chọn main Micro-ATX / Mini-ITX.

### SC-106 — Owned Part: Đã có sẵn GPU (`exclude_from_budget=True`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình có sẵn ở nhà con card RTX 3070 rồi, giờ còn 18 triệu mua 7 món còn lại (CPU, Main, RAM, SSD, Nguồn, Case, Tản) để lắp chung.`
- **Kỳ vọng:**
  - Tổng giá 7 món mới `<= 18.000.000 VND`; nguồn PSU và kích thước Case vẫn tính đúng theo TDP/chiều dài của RTX 3070.

### SC-107 — Owned Part: Đã có sẵn CPU + RAM

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình đã có sẵn CPU Ryzen 5 7600 và 16GB RAM DDR5, giờ cần 15 triệu để mua nốt Main, GPU, SSD, PSU, Case.`
- **Kỳ vọng:**
  - Khóa cứng CPU + RAM cũ, chỉ chọn Mainboard socket AM5 hỗ trợ DDR5.

### SC-108 — Owned Part: Đã có sẵn PSU 500W (Giới hạn công suất)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình tận dụng lại nguồn 500W đang có ở nhà, build giúp mình dàn PC 22 triệu vừa với nguồn này.`
- **Kỳ vọng:**
  - Không chọn combo CPU + GPU có `minimum_capacity_watts > 500W`.

### SC-109 — Pin cứng 1 linh kiện cụ thể từ catalog

- **Tiền điều kiện:** Dùng `/build-pc` hoặc chat chỉ định đích danh 1 mã SKU.
- **Các bước thực hiện:**
  1. Gửi: `Build giúp mình bộ PC 28 triệu chơi game, giữ cố định CPU AMD Ryzen 5 7600 của shop.`
- **Kỳ vọng:**
  - `pinned_parts[CPU]` giữ đúng biến thể đó (bỏ qua Pareto pruning cho slot CPU), 7 slot còn lại tối ưu theo 28tr.

### SC-110 — Pin cứng 2 linh kiện (CPU + GPU) trên ngân sách khít

- **Tiền điều kiện:** Tổng tiền CPU + GPU chiếm ~65% ngân sách.
- **Các bước thực hiện:**
  1. Pin 1 CPU + 1 GPU trên `/build-pc`, đặt ngân sách vừa đủ cho 6 món còn lại và chạy **AI tự tối ưu**.
- **Kỳ vọng:**
  - Giữ nguyên 2 món đã pin, tìm đúng 6 món còn lại tương thích và tổng `<= budget`.

### SC-111 — Pin cứng linh kiện đắt hơn ngân sách tổng

- **Tiền điều kiện:** `/build-pc` hoặc API `/compatibility/optimize`.
- **Các bước thực hiện:**
  1. Pin 1 GPU giá ~30–50 triệu, nhập ngân sách tối đa `20.000.000 VND`, bấm **Tối ưu ngay**.
- **Kỳ vọng:**
  - Trả về lỗi `NO_FEASIBLE_BUILD` rõ ràng, không tự ý gỡ bỏ linh kiện người dùng đã pin.

### SC-112 — Tính đơn điệu khi tăng ngân sách (20M → 35M)

- **Tiền điều kiện:** Cùng profile `GAMING_1440P` và objective `PERFORMANCE`.
- **Các bước thực hiện:**
  1. Chạy tối ưu ở mức `20.000.000`, ghi nhận `objective_score`.
  2. Chạy lại ở mức `35.000.000`, ghi nhận `objective_score`.
- **Kỳ vọng:**
  - Điểm cấu hình 35M `>=` điểm cấu hình 20M (không bị tụt điểm vô lý).

### SC-113 — Ngân sách cao 50M với `BALANCED` (`cost_efficiency` sqrt scaling)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build cho mình dàn PC chơi game 4K cân bằng và bền bỉ, ngân sách 50 triệu.`
- **Kỳ vọng:**
  - Không bị `cost_efficiency` kéo về cấu hình 20–25 triệu; tận dụng hợp lý ngân sách 50 triệu cho GPU/CPU/PSU tốt.

### SC-114 — Tối ưu trên toàn bộ Catalog lớn (~2.355 SKU) ở ngân sách 45M

- **Tiền điều kiện:** Hệ thống kết nối `catalog-service` đầy đủ 2.355 sản phẩm.
- **Các bước thực hiện:**
  1. Bấm **AI tự tối ưu** trên `/build-pc` với ngân sách `45.000.000`, profile `CONTENT_CREATION_3D`.
- **Kỳ vọng:**
  - Hoàn tất nhanh (không bị timeout 504 hay treo worker) nhờ algebraic `(CASE, COOLER)` decomposition + 2-pass envelope.

### SC-115 — Tận dụng Stock Cooler `0đ` khi CPU có sẵn và đủ TDP

- **Tiền điều kiện:** Ngân sách thấp (9–11tr) với CPU non-F/non-K kèm stock cooler 65W.
- **Các bước thực hiện:**
  1. Gửi: `Build PC văn phòng 10 triệu tiết kiệm nhất.`
- **Kỳ vọng:**
  - Chọn stock cooler `0đ` hợp lệ thay vì tốn thêm tiền mua tản rời.

### SC-116 — CPU TDP cao không có Stock Cooler phải chọn tản rời đủ TDP

- **Tiền điều kiện:** CPU 125W–253W (`includes_stock_cooler=False`).
- **Các bước thực hiện:**
  1. Pin CPU i7/i9 hoặc Ryzen 9 trên `/build-pc`, chạy **AI tự tối ưu** ngân sách 45tr.
- **Kỳ vọng:**
  - Tự động chọn tản nhiệt rời trong catalog có `tdp_watts >= cpu.tdp_watts` (nếu có) và vừa chiều cao/radiator của Case.
