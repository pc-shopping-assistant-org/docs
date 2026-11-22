# Nhóm G: Kiểm Tra Tương Thích Phần Cứng (`SC-117` → `SC-132`)

Phạm vi: Kiểm thử tool `check_build_compatibility` trong ReAct và `LocalHardwareRuleEngine` / `/api/v1/compatibility/check` cho toàn bộ 10 luật tương thích cơ–điện.

---

### SC-117 — Cấu hình 8 món chuẩn xác (`COMPATIBLE`)

- **Tiền điều kiện:** 8 SKU hợp lệ (AM5 + DDR5 + ATX + PSU dư tải).
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra tương thích giúp mình 8 món này: <liệt kê 8 mã SKU hợp lệ từ shop>.`
- **Kỳ vọng:**
  - Trả về `COMPATIBLE`, nêu rõ công suất đỉnh (`estimated_sustained_peak_watts`) và công suất PSU khuyến nghị.

### SC-118 — Lệch Socket CPU vs Mainboard (`LGA1700` vs `AM5`)

- **Tiền điều kiện:** Có CPU Intel i5-14400F và Main B650M trong shop.
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra xem CPU Intel Core i5-14400F có gắn chung được với mainboard MSI B650M Gaming Plus của shop không?`
- **Kỳ vọng:**
  - Gọi `check_build_compatibility`, báo **`INCOMPATIBLE`** do khác socket (`LGA1700` vs `AM5`).

### SC-119 — Lệch chuẩn RAM (`DDR5` vs `DDR4`)

- **Tiền điều kiện:** Có Mainboard DDR5 và RAM DDR4 trong shop.
- **Các bước thực hiện:**
  1. Gửi: `Mainboard B650M DDR5 lắp với thanh RAM Kingston Fury Beast DDR4 trong shop có chạy được không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** do khác chuẩn RAM (`DDR5` vs `DDR4`).

### SC-120 — Vượt số khe RAM (`kit_modules > ram_slots`)

- **Tiền điều kiện:** Mainboard 2 khe RAM + kit RAM 4 thanh (`kit_modules=4`).
- **Các bước thực hiện:**
  1. Gửi: `Nếu mainboard chỉ có 2 khe RAM mà mình chọn kit RAM 4x8GB trong shop thì có lắp được hết không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** vì số thanh RAM vượt quá `ram_slots` của mainboard.

### SC-121 — Mainboard không vừa kích thước Case (`FormFactor`)

- **Tiền điều kiện:** Mainboard ATX + Case chỉ hỗ trợ Micro-ATX / Mini-ITX.
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra giúp mình mainboard chuẩn ATX trong shop lắp vào vỏ case chỉ hỗ trợ tối đa Micro-ATX có vừa không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** do form factor mainboard không nằm trong `supported_form_factors` của Case.

### SC-122 — GPU quá dài so với Case (`gpu_length_mm > max_gpu_length_mm`)

- **Tiền điều kiện:** GPU dài 330–350mm + Case `max_gpu_length_mm` nhỏ hơn.
- **Các bước thực hiện:**
  1. Gửi: `Check giúp mình xem con card RTX 3 quạt dài trong shop lắp vào vỏ case mini của shop có bị cấn không?`
- **Kỳ vọng:**
  - Đối chiếu số mm cụ thể và báo **`INCOMPATIBLE`** nếu `gpu_length_mm > max_gpu_length_mm`.

### SC-123 — Tản nhiệt khí quá cao so với Case (`cooler_height_mm > max_cooler_height_mm`)

- **Tiền điều kiện:** Tản tháp cao >160mm + Case giới hạn 155mm.
- **Các bước thực hiện:**
  1. Gửi: `Tản nhiệt khí cao 165mm lắp vào vỏ case có khoảng trống tối đa 155mm có đóng được nắp kính không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** kèm chênh lệch chiều cao mm.

### SC-124 — Tản nước AIO Radiator không vừa Case (`radiator_mm > max_radiator_mm`)

- **Tiền điều kiện:** AIO 360mm + Case `max_radiator_mm=240` (hoặc `0`).
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra giúp mình tản nước AIO 360mm của shop gắn vào vỏ case chỉ hỗ trợ radiator 240mm được không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`**.

### SC-125 — Tản nhiệt không hỗ trợ Socket CPU

- **Tiền điều kiện:** Tản nhiệt chỉ hỗ trợ `LGA1700` + CPU `AM5`.
- **Các bước thực hiện:**
  1. Gửi: `Check xem mẫu tản nhiệt chỉ có ngàm LGA1700 có lắp được cho CPU Ryzen 5 7600 socket AM5 không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** do `AM5` không nằm trong `supported_sockets`.

### SC-126 — Công suất tản nhiệt nhỏ hơn TDP CPU (`cooler.tdp_watts < cpu.tdp_watts`)

- **Tiền điều kiện:** CPU TDP cao (vd 170W–253W) + tản nhiệt TDP 95W.
- **Các bước thực hiện:**
  1. Gửi: `CPU TDP 253W mà gắn tản nhiệt khí nhỏ công suất giải nhiệt 95W thì hệ thống kiểm tra có cho qua không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** (không để CPU quá nhiệt do tản yếu).

### SC-127 — Nguồn PSU thiếu công suất (`psu.wattage < minimum_capacity_watts`)

- **Tiền điều kiện:** CPU + GPU công suất cao + PSU 450W.
- **Các bước thực hiện:**
  1. Gửi: `Lắp CPU Core i7/i9 kèm RTX 4070 Ti Super mà dùng nguồn 450W trong shop có an toàn không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`** kèm mức công suất tối thiểu cần thiết.

### SC-128 — SSD M.2 NVMe gắn Mainboard không có khe M.2 (`m2_slots=0`)

- **Tiền điều kiện:** Mainboard `m2_slots=0` + SSD M.2 NVMe.
- **Các bước thực hiện:**
  1. Gửi: `Mainboard đời cũ có 0 khe M.2 thì lắp ổ cứng SSD M.2 NVMe của shop được không?`
- **Kỳ vọng:**
  - Báo **`INCOMPATIBLE`**.

### SC-129 — Thiếu thông số bắt buộc (`UNKNOWN`, không đoán bừa `COMPATIBLE`)

- **Tiền điều kiện:** Sản phẩm giả lập thiếu `gpu_length_mm` hoặc `supported_form_factors`.
- **Các bước thực hiện:**
  1. Kiểm tra qua `/compatibility/check` với 1 sản phẩm thiếu trường kích thước vật lý.
- **Kỳ vọng:**
  - Trả về **`UNKNOWN`** và nêu rõ thiếu thông số nào, tuyệt đối không trả `COMPATIBLE` bừa.

### SC-130 — Kiểm tra cấu hình thiếu slot (Partial Build: chỉ CPU + Main + RAM)

- **Tiền điều kiện:** Chỉ chọn 3 món trên `/build-pc` hoặc hỏi 3 món qua chat.
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra nhanh giúp mình 3 món CPU Ryzen 5 7600 + Main B650M + RAM DDR5 có hợp nhau không (chưa chọn các món khác)?`
- **Kỳ vọng:**
  - `check_build_compatibility` kiểm tra đúng 3 món đã cung cấp và báo hợp lệ cho phần đó.

### SC-131 — Kiểm tra build iGPU (không có GPU rời) cho Văn phòng

- **Tiền điều kiện:** CPU có iGPU + không chọn GPU rời.
- **Các bước thực hiện:**
  1. Chọn 7 món (không GPU rời) với Ryzen 5 8600G trên `/build-pc`, xem trạng thái tương thích.
- **Kỳ vọng:**
  - Hiển thị **`Tương thích`** (`COMPATIBLE`) và tính công suất điện hợp lý.

### SC-132 — Nhất quán giữa API `/compatibility/check` và ReAct `check_build_compatibility`

- **Tiền điều kiện:** Lấy 1 bộ linh kiện từ `/build-pc`.
- **Các bước thực hiện:**
  1. Kiểm tra bộ đó trên `/build-pc` (gọi `/compatibility/check`).
  2. Copy đúng tên các món đó hỏi AI trong `/assistant` để AI gọi `check_build_compatibility`.
- **Kỳ vọng:**
  - Kết quả verdict và lỗi tương thích (nếu có) trùng khớp 100% giữa 2 nơi.
