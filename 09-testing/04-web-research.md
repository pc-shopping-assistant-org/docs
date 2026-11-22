# Nhóm D: Web Search & Hardware Research (`SC-053` → `SC-072`)

Phạm vi: Kiểm thử nhóm tool `research_hardware`, `research_compatibility`, `research_workload`, `research_pc_build`, `research_driver`, `search_web`, `read_web_page`; kiểm tra trích dẫn nguồn (`web_excerpts`), cảnh báo `missing_conditions` và fail-closed khi thiếu mạng.

---

### SC-053 — Nghiên cứu review phần cứng mới (`research_hardware`)
- **Tiền điều kiện:** Web search client đang hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Theo các bài đánh giá uy tín gần đây, hiệu năng và mức tiêu thụ điện thực tế của RTX 5070 hoặc RX 9070 XT như thế nào?`
- **Kỳ vọng:**
  - Gọi `research_hardware`, hiển thị đoạn trích dẫn (`Nội dung nguồn tham khảo`) + link nguồn thật trong `Nguồn tham khảo:`; không bịa URL.

### SC-054 — Kiểm tra tương thích BIOS / thế hệ mới (`research_compatibility`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `CPU AMD Ryzen 7 9800X3D gắn lên mainboard chipset B650 có chạy được luôn không hay cần cập nhật BIOS?`
- **Kỳ vọng:**
  - Gọi `research_compatibility`, ưu tiên nguồn chính hãng (`OfficialSourceStatus`), nêu rõ yêu cầu phiên bản BIOS.

### SC-055 — Tra cứu yêu cầu phần cứng game nặng (`research_workload`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Chơi Black Myth: Wukong ở độ phân giải 1440p thiết lập High/Very High cần cấu hình CPU và GPU như thế nào theo khuyến nghị?`
- **Kỳ vọng:**
  - Gọi `research_workload`, tổng hợp đúng theo tài liệu khuyến nghị, nêu rõ điều kiện phân giải/preset.

### SC-056 — Tra cứu vấn đề Driver / Độ ổn định (`research_driver`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Driver mới nhất của NVIDIA gần đây có lỗi gì đáng chú ý với game hay phần mềm đồ họa không?`
- **Kỳ vọng:**
  - Gọi `research_driver`, chỉ trích xuất sự kiện có trong nguồn đọc được, không suy đoán.

### SC-057 — Đánh giá cấu hình đã build trên web (`research_pc_build` sau `BUILD_PC`)
- **Tiền điều kiện:** Chạy trong cùng conversation sau khi đã build PC thành công.
- **Các bước thực hiện:**
  1. Gửi: `Build giúp mình dàn PC gaming 2K tầm 35 triệu.`
  2. Sau khi có build, gửi tiếp: `Tra cứu đánh giá thực tế trên mạng xem cặp CPU và GPU trong bộ bạn vừa build chơi game 2K có ổn định không?`
- **Kỳ vọng:**
  - `research_pc_build` được mở khóa trong `allowed_tools` vì đã có `BUILD` / `saved_build`; gọi đúng cho bộ vừa dựng.

### SC-058 — Chặn `research_pc_build` khi chưa có Build nào
- **Tiền điều kiện:** Phiên chat mới hoàn toàn (`saved_build=None`, chưa gọi `BUILD_PC`).
- **Các bước thực hiện:**
  1. Gửi: `Hãy tra cứu web đánh giá hiệu năng bộ PC hiện tại của mình đi.`
- **Kỳ vọng:**
  - `research_pc_build` không nằm trong `allowed_tools`; AI hỏi người dùng cung cấp cấu hình hoặc đề nghị build trước.

### SC-059 — Thiếu điều kiện Benchmark (`missing_conditions`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Card RTX 4060 chơi Cyberpunk 2077 đạt chính xác bao nhiêu FPS vậy bạn?`
- **Kỳ vọng:**
  - Không bịa ra 1 con số FPS cố định khi thiếu điều kiện độ phân giải, preset, Ray Tracing, DLSS/Frame Gen; cảnh báo rõ `Điều kiện benchmark chưa được cung cấp`.

### SC-060 — Ưu tiên nguồn chính hãng (`OfficialSourceStatus`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Kiểm tra trên trang thông số chính thức của ASUS/MSI xem mainboard B650M hỗ trợ RAM tối đa bao nhiêu GB.`
- **Kỳ vọng:**
  - Ưu tiên kết quả từ domain hãng, ghi nhận `official domain` đúng thực tế.

### SC-061 — Nghiên cứu hành vi kỹ thuật RAM 4 thanh trên DDR5
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Gắn 4 thanh RAM DDR5 trên nền tảng AM5 có bị hạ xung nhịp so với gắn 2 thanh không?`
- **Kỳ vọng:**
  - Gọi `research_compatibility`, trích dẫn nguồn kỹ thuật xác thực.

### SC-062 — Tra cứu phần cứng cho phần mềm chuyên ngành (`research_workload`)
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Làm việc với DaVinci Resolve Studio dựng video 4K RAW và Unreal Engine 5 thì hãng phần mềm khuyến nghị VRAM và RAM tối thiểu bao nhiêu?`
- **Kỳ vọng:**
  - Trả lời bám theo tài liệu chính thức từ Blackmagic / Epic Games nếu tìm thấy.

### SC-063 — So sánh công nghệ phần cứng qua Web (`search_web` + `read_web_page`)
- **Tiền điều kiện:** Web search & web reader hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Đọc và tóm tắt giúp mình sự khác biệt giữa NVIDIA DLSS 4 Multi Frame Generation và AMD FSR 3.`
- **Kỳ vọng:**
  - Đọc trang chi tiết bằng `read_web_page`, render quote và URL nguồn đầy đủ.

### SC-064 — Xử lý khi dịch vụ Web Search không khả dụng / Timeout
- **Tiền điều kiện:** Tắt hoặc ngắt kết nối web search adapter (hoặc test khi mất mạng).
- **Các bước thực hiện:**
  1. Gửi: `Tra cứu giúp mình bài review mới nhất về RTX 5080 trên mạng.`
- **Kỳ vọng:**
  - Không tự bịa kết quả web; thông báo rõ không truy cập được nguồn tìm kiếm bên ngoài (`DEPENDENCY_UNAVAILABLE` / fallback trung thực).

### SC-065 — Trang web trả về nội dung rỗng hoặc chặn Anti-Bot / CAPTCHA
- **Tiền điều kiện:** URL mục tiêu bị Cloudflare/CAPTCHA chặn khi `read_web_page`.
- **Các bước thực hiện:**
  1. Yêu cầu AI đọc đánh giá từ 1 bài viết bị chặn bot.
- **Kỳ vọng:**
  - Ghi nhận trạng thái `UNREADABLE` / bị chặn, tuyệt đối không cố vượt CAPTCHA hoặc bịa nội dung trang.

### SC-066 — Tách bạch giá Shop vs giá tham khảo trên Web
- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `RTX 4060 ở shop mình giá bao nhiêu, và giá bán lẻ đề xuất (MSRP) quốc tế của hãng là bao nhiêu?`
- **Kỳ vọng:**
  - Giá shop lấy từ `search_catalog`, giá MSRP lấy từ web research; tách bạch 2 nguồn rõ ràng.

### SC-067 — Kiểm tra giới hạn VRM Mainboard với CPU công suất lớn
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Mainboard chipset H610 giá rẻ có kéo nổi CPU Core i9 TDP 253W ở tải tối đa không?`
- **Kỳ vọng:**
  - Gọi `research_compatibility`, cảnh báo hiện tượng VRM thermal throttling nếu có trong nguồn.

### SC-068 — Tư vấn lựa chọn Driver Studio vs Game Ready
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Mình dùng máy vừa chơi game vừa làm Blender/Premiere thì nên cài NVIDIA Studio Driver hay Game Ready Driver?`
- **Kỳ vọng:**
  - Gọi `research_driver`, giải thích rõ chu kỳ cập nhật và sự ổn định của từng nhánh driver.

### SC-069 — Đọc sâu nội dung bài Benchmark cụ thể
- **Tiền điều kiện:** Web reader hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Tìm bài benchmark so sánh hiệu năng chơi game của Ryzen 7 7800X3D và tóm tắt các điểm chính giúp mình.`
- **Kỳ vọng:**
  - Dùng `search_web` tìm URL → `read_web_page` trích xuất nội dung có kiểm soát.

### SC-070 — Hỏi kiến thức chuẩn nguồn ATX 3.0 / 3.1
- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Chuẩn nguồn ATX 3.0 / ATX 3.1 và dây 12V-2x6 khác gì nguồn ATX 2.x cũ khi dùng với card RTX 40/50 series?`
- **Kỳ vọng:**
  - Trả lời chính xác về khả năng chịu xung dòng (power excursion) và đầu cấp nguồn mới.

### SC-071 — Kết hợp Web Research + Catalog để chốt linh kiện mua tại Shop
- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Tra giúp mình game Alan Wake 2 1440p cần tối thiểu card gì, rồi tìm luôn các mẫu card đó đang bán trong shop giúp mình.`
- **Kỳ vọng:**
  - Chạy `research_workload` + `search_catalog`, nối mượt giữa yêu cầu game và SKU có sẵn ở shop.

### SC-072 — Xử lý câu hỏi về sản phẩm tin đồn / chưa phát hành
- **Tiền điều kiện:** Web search hoạt động.
- **Các bước thực hiện:**
  1. Gửi: `Thông số chính thức và ngày bán của card đồ họa RTX 6090 (chưa ra mắt) là khi nào?`
- **Kỳ vọng:**
  - Nêu rõ chưa có thông tin phát hành chính thức, chỉ ghi nhận là tin đồn chưa xác thực nếu có trên web, không khẳng định bừa.
