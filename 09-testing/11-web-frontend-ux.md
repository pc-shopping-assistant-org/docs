# Nhóm K: Web Frontend UX (`/assistant`, `/build-pc`, Floating Bubble) (`SC-179` → `SC-190`)

Phạm vi: Kiểm thử giao diện người dùng trên `web-frontend`: Markdown inline links, Carousel sản phẩm hợp nhất, chuyển dữ liệu sang `/build-pc`, nút **"AI tự tối ưu"**, song ngữ `vi`/`en`, Floating AI Widget và responsive.

---

### SC-179 — Inline Product Links mở cùng tab
- **Tiền điều kiện:** Có câu trả lời AI nhắc tên sản phẩm trong catalog.
- **Các bước thực hiện:**
  1. Click vào tên sản phẩm có gạch chân/link ngay trong đoạn văn trả lời của AI.
- **Kỳ vọng:**
  - Điều hướng sang `/products/<slug>` **trong cùng tab trình duyệt** (không mở tab mới), bấm Back quay lại vẫn giữ cuộc trò chuyện.

### SC-180 — Hợp nhất toàn bộ Product Cards vào 1 Carousel ngang
- **Tiền điều kiện:** Câu trả lời AI nhắc >= 4 sản phẩm (vd danh sách GPU hoặc trọn bộ PC).
- **Các bước thực hiện:**
  1. Quan sát bố cục thẻ sản phẩm trong câu trả lời trên `/assistant`.
- **Kỳ vọng:**
  - Không có thẻ sản phẩm rời rạc chèn giữa các đoạn text; tất cả gom gọn vào **1 thanh `Carousel` ngang** ở cuối câu trả lời.

### SC-181 — Điều hướng Carousel trên Desktop & Mobile
- **Tiền điều kiện:** Carousel có > 3 sản phẩm.
- **Các bước thực hiện:**
  1. Bấm nút mũi tên Next / Prev trên Carousel ở Desktop.
  2. Thử vuốt ngang trên Mobile viewport.
- **Kỳ vọng:**
  - Trượt mượt, không che chữ, các nút chuyển trang hoạt động đúng.

### SC-182 — Chuyển giao cấu hình từ `/assistant` sang `/build-pc?build=<JSON>`
- **Tiền điều kiện:** AI vừa đề xuất 1 cấu hình hoàn chỉnh có `PcBuildSummary`.
- **Các bước thực hiện:**
  1. Bấm nút **Mở trong Build PC** trên thẻ tóm tắt cấu hình.
- **Kỳ vọng:**
  - Mở trang `/build-pc`, tự động điền đủ 8 slot (`CPU`, `MAINBOARD`, `RAM`, `GPU`, `SSD` — map chuẩn từ `STORAGE`, `PSU`, `CASE`, `COOLER`).
  - Trạng thái hiển thị **`Tương thích`** và tổng giá khớp với AI.

### SC-183 — Nút "AI tự tối ưu" trên `/build-pc` với Pinned Slots
- **Tiền điều kiện:** Mở `/build-pc`.
- **Các bước thực hiện:**
  1. Chọn thủ công 1 **CPU** và 1 **CASE** bất kỳ.
  2. Bấm nút **AI tự tối ưu**.
  3. Chọn profile `GAMING_ESPORTS`, ưu tiên `PERFORMANCE`, ngân sách `25000000`, bấm **Tối ưu ngay**.
- **Kỳ vọng:**
  - CPU và CASE đã chọn **không bị thay đổi** (`pinned_slots`); 6 slot còn lại tự động điền đầy đủ và `COMPATIBLE`.

### SC-184 — Kiểm thử song ngữ Tiếng Việt (`/build-pc`) & Tiếng Anh (`/en/build-pc`)
- **Tiền điều kiện:** Mở lần lượt `/build-pc` và `/en/build-pc`.
- **Các bước thực hiện:**
  1. Mở dialog **AI tự tối ưu / AI Auto-Optimize** ở cả 2 ngôn ngữ.
  2. Kiểm tra danh sách 12 profile, 3 objective, nhãn nút xóa slot (`Xóa` / `Delete`), thông báo thành công/thất bại.
- **Kỳ vọng:**
  - 100% văn bản hiển thị đúng ngôn ngữ tương ứng, không còn chữ tiếng Việt bị hardcode ở bản `/en`.

### SC-185 — Dialog chọn linh kiện & Phân trang trên `/build-pc`
- **Tiền điều kiện:** Mở `/build-pc`.
- **Các bước thực hiện:**
  1. Bấm chọn slot **GPU** để mở dialog picker.
  2. Thử đổi bộ lọc/sắp xếp (`PickerSort`) và bấm chuyển sang trang 2 (`Pagination`).
- **Kỳ vọng:**
  - Dùng component shadcn chuẩn (`DialogContent`, `Select`, `Pagination`), chuyển trang nhanh, không giật hay lỗi console.

### SC-186 — Floating AI Chat Bubble trên trang chi tiết sản phẩm (`/products/[slug]`)
- **Tiền điều kiện:** Mở bất kỳ trang `/products/<slug>` nào.
- **Các bước thực hiện:**
  1. Bấm biểu tượng bong bóng chat AI ở góc dưới bên phải.
  2. Kiểm tra **chip ngữ cảnh sản phẩm** hiện trong khung chat.
  3. Gửi: `Con này lắp với mainboard nào của shop thì hợp?`
- **Kỳ vọng:**
  - Popover mở nhanh, chip ngữ cảnh hiển thị đúng sản phẩm đang xem và AI hiểu đúng sản phẩm đó mà không cần gõ lại tên dài.

### SC-187 — Floating AI Chat Bubble tự ẩn ở các route loại trừ
- **Tiền điều kiện:** Điều hướng lần lượt tới các đường dẫn đặc biệt.
- **Các bước thực hiện:**
  1. Mở `/assistant`, `/checkout`, `/login`, `/register`, `/admin/orders`.
- **Kỳ vọng:**
  - Bong bóng chat nổi tự động ẩn hoàn toàn trên tất cả các trang này.

### SC-188 — Responsive Mobile (chiều rộng 375px)
- **Tiền điều kiện:** Bật DevTools mobile emulation (`375x812`).
- **Các bước thực hiện:**
  1. Kiểm tra `/assistant`, `/build-pc` (kèm Setup Summary & Slot Quick Bar), và Floating Bubble.
- **Kỳ vọng:**
  - Không bị tràn khung ngang (`horizontal scroll`), các nút và bảng linh kiện đọc rõ ràng.

### SC-189 — Lưu & Khôi phục cấu hình Local trên `/build-pc`
- **Tiền điều kiện:** Đã chọn ít nhất 4–8 linh kiện trên `/build-pc`.
- **Các bước thực hiện:**
  1. Lưu cấu hình hiện tại vào danh sách đã lưu local.
  2. Bấm xóa toàn bộ cấu hình đang dựng.
  3. Mở danh sách đã lưu và khôi phục lại.
- **Kỳ vọng:**
  - Khôi phục chính xác từng linh kiện và số lượng mà không làm thay đổi giỏ hàng thật.

### SC-190 — Hiển thị lỗi rõ ràng khi "AI tự tối ưu" không tìm được cấu hình (`NO_FEASIBLE_BUILD`)
- **Tiền điều kiện:** Trên `/build-pc`, pin 1 GPU đắt (vd 30 triệu+).
- **Các bước thực hiện:**
  1. Mở **AI tự tối ưu**, nhập ngân sách `10000000` (10 triệu) và bấm **Tối ưu ngay**.
- **Kỳ vọng:**
  - Dialog giữ nguyên để user sửa lại ngân sách/profile và hiển thị thông báo lỗi rõ ràng (`autoOptimizeFailed`), không đóng form hay crash trang.
