# Nhóm E: PC Build — 12 Profiles & Multi-Profile Blending (`SC-073` → `SC-096`)

Phạm vi: Kiểm thử toàn bộ 12 `UseCaseProfile` từ `profiles.json`, nội suy pha trộn 2 profile (`blend_profile_specs`), ngưỡng bão hòa RAM/SSD theo profile, luật iGPU-only, bottleneck penalty, CUDA & multi-core bonus.

---

### SC-073 — Profile `GAMING_1080P` (Full HD phổ thông)

- **Tiền điều kiện:** Phiên mới trên `/assistant`; catalog đủ 8 nhóm linh kiện.
- **Các bước thực hiện:**
  1. Gửi: `Mình muốn build một bộ PC chơi game Full HD 1080p mượt các game GTA V, Cyberpunk 2077, ngân sách khoảng 18 triệu.`
  2. Gửi tiếp: `Bộ này lưu trữ 1TB có đủ cài nhiều game nặng không?`
- **Kỳ vọng:**
  - Áp dụng `GAMING_1080P`: có GPU rời, RAM bão hòa ở 32GB, SSD bão hòa ở 1TB, tổng tiền `<= 18.000.000 VND`.

### SC-074 — Profile `GAMING_1440P` (2K AAA)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Tư vấn giúp mình dàn PC chơi game AAA ở độ phân giải 2K 1440p màn hình 165Hz, ngân sách 32 triệu.`
- **Kỳ vọng:**
  - Áp dụng `GAMING_1440P`: trọng số `gpu_perf` chiếm ưu thế (35–55%), không ghép CPU quá yếu gây `balance_penalty`.

### SC-075 — Profile `GAMING_4K` (4K Ultra)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình cần ráp dàn máy chiến game 4K Ultra trên màn hình lớn, ngân sách khoảng 68 triệu.`
- **Kỳ vọng:**
  - Áp dụng `GAMING_4K`: mặc định `PERFORMANCE`, cộng trọng số `gpu_vram` (15%) và `gpu_perf` (55%), SSD bão hòa 2TB.

### SC-076 — Profile `GAMING_ESPORTS` (FPS cao, thiên CPU)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình chỉ bắn Valorant, CS2, Apex Legends trên màn 240Hz 1080p, cần FPS cao và ổn định, ngân sách 21 triệu.`
- **Kỳ vọng:**
  - Áp dụng `GAMING_ESPORTS`: trọng số `cpu_perf > gpu_perf` và `bottleneck_threshold = 20.0` chặt hơn gaming thường.

### SC-077 — Profile `STREAMING_GAMING` (Chơi game + Livestream OBS)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình vừa chơi game 1440p vừa livestream lên YouTube/TikTok qua OBS, mở nhiều tab Discord/Chrome, ngân sách 36 triệu.`
- **Kỳ vọng:**
  - Áp dụng `STREAMING_GAMING`: ưu tiên NVIDIA (`cuda_bonus=3.5` cho NVENC), CPU đa nhân (`multicore_max_bonus=3.0`), RAM bão hòa 64GB.

### SC-078 — Profile `CONTENT_CREATION_3D` (Blender, Unreal Engine, V-Ray)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình làm kiến trúc 3D dùng Blender, 3ds Max, V-Ray và Unreal Engine 5, ngân sách 52 triệu.`
- **Kỳ vọng:**
  - Áp dụng `CONTENT_CREATION_3D`: RAM bão hòa 64GB, SSD 2TB, cộng `cuda_bonus=3.0` + `multicore_max_bonus=4.0`.

### SC-079 — Profile `VIDEO_EDITING` (Premiere Pro, DaVinci Resolve)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Tư vấn giúp mình bộ PC dựng phim 4K bằng Premiere Pro và DaVinci Resolve, ngân sách tầm 35 triệu.`
- **Kỳ vọng:**
  - Áp dụng `VIDEO_EDITING`: ưu tiên cao cho `cpu_perf`, `multicore_max_bonus=5.0`, `ram_capacity` (64GB) và `storage_capacity` (2TB).

### SC-080 — Profile `GRAPHIC_DESIGN_2D` (Photoshop, Illustrator, AutoCAD 2D)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình làm thiết kế đồ họa 2D Photoshop, Illustrator và AutoCAD 2D, ngân sách khoảng 16 triệu.`
- **Kỳ vọng:**
  - Áp dụng `GRAPHIC_DESIGN_2D`: ưu tiên CPU + RAM 32GB, chấp nhận iGPU nếu tối ưu ngân sách hoặc GPU rời tầm trung.

### SC-081 — Profile `AI_DATA_SCIENCE` (LLM, Stable Diffusion, PyTorch)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình cần ráp máy chạy AI local, Stable Diffusion và train model PyTorch, ngân sách 58 triệu.`
- **Kỳ vọng:**
  - Áp dụng `AI_DATA_SCIENCE`: `gpu_vram` 38%, `cuda_bonus=6.0`, ưu tiên card NVIDIA nhiều VRAM.

### SC-082 — Profile `SOFTWARE_DEV` (Code, Docker, Kubernetes, VM)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình lập trình backend chạy nhiều Docker container, IntelliJ và máy ảo Linux, không chơi game, ngân sách 24 triệu.`
- **Kỳ vọng:**
  - Áp dụng `SOFTWARE_DEV`: `allow_igpu_only=true` (`igpu_bonus=3.0`), `multicore_max_bonus=5.0`, RAM bão hòa 64GB, không lãng phí tiền mua GPU rời đắt.

### SC-083 — Profile `WORKSTATION_SILENT` (Chạy bền bỉ 24/7, êm ái)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Mình cần máy trạm chạy tính toán 24/7 trong phòng làm việc yên tĩnh, ưu tiên nguồn cực bền và tản nhiệt êm, ngân sách 45 triệu.`
- **Kỳ vọng:**
  - Áp dụng `WORKSTATION_SILENT`: trọng số `psu_quality` + `psu_headroom` + `platform_longevity` cao vượt trội.

### SC-084 — Profile `OFFICE_BUDGET` (Văn phòng, học tập tiết kiệm)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build giúp mình bộ PC văn phòng Word, Excel, kế toán, học online tầm 10 triệu.`
- **Kỳ vọng:**
  - Áp dụng `OFFICE_BUDGET`: `allow_igpu_only=true`, thưởng `igpu_office_fit`, RAM bão hòa 16GB, SSD 512GB, tận dụng stock cooler nếu hợp lệ.

### SC-085 — Multi-Profile Blend: Gaming 2K + Software Dev

- **Tiền điều kiện:** Gọi `/compatibility/optimize` hoặc chat với nhu cầu kép.
- **Các bước thực hiện:**
  1. Gửi: `Mình muốn build máy 34 triệu vừa chơi game AAA 2K vừa chạy Docker lập trình backend.`
- **Kỳ vọng:**
  - Pha trộn `GAMING_1440P` + `SOFTWARE_DEV`: giữ GPU rời (vì Gaming không cho iGPU-only) nhưng tăng ngưỡng RAM & thưởng CPU đa nhân.

### SC-086 — Multi-Profile Blend: Gaming Esports + Livestream

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Ráp PC 30 triệu vừa bắn Valorant 240Hz vừa livestream TikTok Live mượt.`
- **Kỳ vọng:**
  - Pha trộn `GAMING_ESPORTS` + `STREAMING_GAMING`: CPU xung/điểm cao + card NVIDIA hỗ trợ NVENC.

### SC-087 — Multi-Profile Blend: Video Editing + Content Creation 3D

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build máy 42 triệu vừa dựng phim Premiere 4K vừa làm render 3D Blender.`
- **Kỳ vọng:**
  - Pha trộn `VIDEO_EDITING` + `CONTENT_CREATION_3D`: RAM 64GB, SSD 2TB, NVIDIA CUDA + CPU đa nhân.

### SC-088 — Multi-Profile Blend: AI/Data Science + Software Dev

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build máy 50 triệu vừa viết backend Python/Docker vừa chạy local LLM bằng CUDA.`
- **Kỳ vọng:**
  - Pha trộn `AI_DATA_SCIENCE` + `SOFTWARE_DEV`: `allow_igpu_only=False` (bắt buộc GPU rời cho AI), RAM 64GB + GPU VRAM lớn.

### SC-089 — Multi-Profile Blend: Graphic Design 2D + Office Budget (cả 2 đều cho phép iGPU)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build máy 15 triệu vừa làm văn phòng vừa chỉnh ảnh Photoshop 2D nhẹ, ưu tiên gọn tiết kiệm.`
- **Kỳ vọng:**
  - Khi cả primary và secondary đều `allow_igpu_only=true`, build iGPU vẫn được hưởng `igpu_office_fit` nội suy.

### SC-090 — Multi-Profile Blend: Gaming 4K + Workstation Silent

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build máy 60 triệu vừa chơi game 4K vừa chạy tác vụ nặng êm và nguồn thật ổn định.`
- **Kỳ vọng:**
  - Cân bằng giữa GPU 4K và PSU Gold/Platinum công suất dư cao.

### SC-091 — Kiểm chứng bão hòa RAM Office ở 16GB

- **Tiền điều kiện:** Catalog có cả RAM 16GB và 32GB (hoặc test trực tiếp qua API).
- **Các bước thực hiện:**
  1. Build Office với ngân sách vừa đủ, quan sát điểm RAM ở mức 16GB vs 32GB.
- **Kỳ vọng:**
  - `OFFICE_BUDGET` bão hòa ở `16GB`, không đội tiền lên 32GB khi phần còn lại cần tối ưu CPU/giá.

### SC-092 — Kiểm chứng bão hòa RAM Gaming (32GB) vs 3D/AI (64GB)

- **Tiền điều kiện:** Ngân sách lớn (50 triệu).
- **Các bước thực hiện:**
  1. So sánh cấu hình 50 triệu cho `GAMING_1440P` và `CONTENT_CREATION_3D`.
- **Kỳ vọng:**
  - Gaming dừng ở 32GB để dồn tiền vào GPU/CPU; 3D/AI tiếp tục ưu tiên nâng RAM lên 64GB.

### SC-093 — Kiểm chứng NVIDIA CUDA Bonus ở AI/3D

- **Tiền điều kiện:** Catalog có 1 GPU NVIDIA và 1 GPU AMD cùng mức điểm & giá.
- **Các bước thực hiện:**
  1. Chạy tối ưu `AI_DATA_SCIENCE` ở mức giá trùng với 2 GPU đó.
- **Kỳ vọng:**
  - Chọn GPU NVIDIA nhờ `cuda_ecosystem` (`+6.0` điểm).

### SC-094 — Kiểm chứng CPU Multi-core Bonus (`core_count >= 8`)

- **Tiền điều kiện:** Catalog có CPU 6 nhân và CPU 12–16 nhân có `extra_specs.core_count`.
- **Các bước thực hiện:**
  1. Chạy tối ưu `VIDEO_EDITING` / `SOFTWARE_DEV` ở ngân sách trung-cao.
- **Kỳ vọng:**
  - CPU nhiều nhân được cộng thêm `cpu_multicore` tối đa `+5.0` điểm.

### SC-095 — Kiểm chứng Gaming Bottleneck Penalty

- **Tiền điều kiện:** Catalog có CPU rất yếu (score ~45) và GPU rất mạnh (score ~90).
- **Các bước thực hiện:**
  1. Chạy tối ưu `GAMING_1440P` ở ngân sách cao.
- **Kỳ vọng:**
  - `balance_penalty` trừ điểm cặp lệch pha `|gpu_perf - cpu_perf| > 25`, chọn cặp CPU–GPU cân đối hơn.

### SC-096 — Kiểm chứng Gaming ngân sách eo hẹp vẫn khả thi vật lý nếu CPU có iGPU

- **Tiền điều kiện:** Catalog chỉ có GPU rời đắt (16tr+) và ngân sách tổng chỉ 15tr, CPU có iGPU.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming tầm 14-15 triệu` trên catalog hạn chế GPU rẻ.
- **Kỳ vọng:**
  - Vẫn ra được cấu hình khả thi vật lý bằng iGPU (không crash `NoFeasibleBuildError`), nhưng **không** cộng `igpu_office_fit`.
