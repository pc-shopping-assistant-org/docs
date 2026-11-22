# Nhóm I: Multi-Task Registration, Hội Thoại Nối Tiếp & `RESPOND` (`SC-151` → `SC-164`)

Phạm vi: Kiểm thử nhánh đăng ký đa tác vụ (`register_request`, `resolve_registered_tasks`, `MULTI_TASK`), `RespondAction`, `dialogue_continuation`, hủy/ngắt stream và cô lập giữa các phiên.

---

### SC-151 — Chào hỏi xã giao (`RespondAction` trực tiếp)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Xin chào, bạn có thể hỗ trợ mình những gì?`
- **Kỳ vọng:**
  - Agent dùng `RespondAction` trả lời trực tiếp, **không gọi tool thừa** (`search_catalog` hay `build_pc`).

### SC-152 — Câu hỏi ngoài phạm vi tư vấn PC (`Out-of-scope`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Hôm nay thời tiết Sài Gòn thế nào? Viết giúp mình một bài thơ 4 câu về mùa thu.`
- **Kỳ vọng:**
  - Từ chối lịch sự đúng vai trò trợ lý mua sắm PC, gợi ý quay lại tư vấn linh kiện/build máy.

### SC-153 — Multi-Task: Tìm kiếm phụ kiện + Build PC (`SEARCH` + `BUILD`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Tìm giúp mình 2 mẫu màn hình 2K dưới 7 triệu, đồng thời build riêng một bộ PC gaming 28 triệu chơi game 2K nhé.`
- **Kỳ vọng:**
  - `register_request` tách đủ 2 task, hoàn thành cả 2 phần trong `FinalAnswerAction(outcome="MULTI_TASK")`, không bỏ sót vế màn hình.

### SC-154 — Multi-Task: So sánh + Kiểm tra tương thích (`COMPARE` + `COMPATIBILITY`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `So sánh giúp mình RTX 4060 và RX 7600 của shop, tiện thể check luôn xem RTX 4060 lắp vừa case Montech Air 100 không.`
- **Kỳ vọng:**
  - Thực thi cả `compare_products` và `check_build_compatibility`, trả lời rõ ràng từng vế.

### SC-155 — Multi-Task có 1 vế thiếu thông tin (`pending_task_resolution`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `So sánh Ryzen 5 7600 với Core i5-14400F giúp mình và build luôn một bộ PC nhé.` (chưa nêu ngân sách cho vế build).
- **Kỳ vọng:**
  - Xử lý phần so sánh và hỏi làm rõ phần còn thiếu của task build qua `pending_task_resolution` mà không văng lỗi `TASK_INCOMPLETE`.

### SC-156 — Trả lời & Sửa yêu cầu trong `pending_task_resolution` (`interpret_task_reply` / `amend_task`)

- **Tiền điều kiện:** Đang chờ bổ sung từ `SC-155`.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Phần build thì lấy tầm 25 triệu chơi game 1080p, à đổi so sánh sang Ryzen 5 7600 với i5-12400F nhé.`
- **Kỳ vọng:**
  - Đi qua `interpret_task_reply` / `amend_task` → `resolve_registered_tasks`, hoàn tất trọn vẹn cả 2 task mới.

### SC-157 — Dialogue Continuation (`RESPOND` giải thích `saved_build`)

- **Tiền điều kiện:** Vừa build PC xong ở Lượt 1.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 30 triệu chơi game 2K.`
  2. Sau khi có kết quả, gửi tiếp: `Tại sao bạn lại chọn bộ nguồn công suất này và socket này cho cấu hình trên?`
- **Kỳ vọng:**
  - `dialogue_continuation=True`, AI dùng `RespondAction` giải thích từ `saved_build` & `evidence` đã có, **không chạy lại `BUILD_PC` vô ích**.

### SC-158 — Follow-up chỉnh nhẹ 1 linh kiện trong cấu hình đã có

- **Tiền điều kiện:** Đã có `saved_build` ở Lượt 1.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Giữ nguyên cấu hình vừa rồi nhưng đổi ổ SSD lên 2TB giúp mình nhé.`
- **Kỳ vọng:**
  - Cập nhật constraint lưu trữ, tính lại tổng tiền và kiểm tra tương thích lại.

### SC-159 — Hỏi tính toán tổng tiền khi thêm linh kiện phụ

- **Tiền điều kiện:** Đã có `saved_build`.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Nếu mình mua thêm 1 chiếc màn hình rẻ nhất tầm 4 triệu của shop nữa thì tổng cả bộ + màn hình hết khoảng bao nhiêu?`
- **Kỳ vọng:**
  - Tìm màn hình thật từ `search_catalog`, cộng đúng số tiền với `saved_build.total_price`.

### SC-160 — Chế độ Read-Only Turn (khi xem lại lịch sử / hội thoại chỉ đọc)

- **Tiền điều kiện:** `read_only_turn=True`.
- **Các bước thực hiện:**
  1. Gửi câu hỏi về cấu hình đã lưu ở phiên chỉ đọc.
- **Kỳ vọng:**
  - Chỉ đọc và trả lời, không cho phép ghi đè `working_requirements` hay kích hoạt `BUILD_PC`.

### SC-161 — Nhắc lại cấu hình đã chốt sau nhiều lượt hỏi phụ

- **Tiền điều kiện:** Đã build ở Lượt 1, qua 2–3 lượt hỏi ngoài lề.
- **Các bước thực hiện:**
  1. Gửi: `Tóm tắt lại giúp mình đầy đủ 8 món và tổng tiền của cấu hình chúng ta vừa chốt ở trên nhé.`
- **Kỳ vọng:**
  - Truy xuất đúng `saved_build` của conversation, không bị lệch giá hoặc nhầm sang sản phẩm khác từng search.

### SC-162 — Hội thoại dài 6 lượt liên tiếp (Full Journey)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. `Tìm hiểu PC chơi game 2K tầm 30 triệu.`
  2. `Cho xem 2 mẫu card NVIDIA tầm 12-15 triệu ở shop.`
  3. `So sánh 2 con đó.`
  4. `Chốt con hiệu năng cao hơn và build nguyên bộ 30 triệu quanh nó.`
  5. `Check lại xem nguồn có đủ tải lâu dài không.`
  6. `Nếu nâng RAM lên 32GB thì tổng mới là bao nhiêu?`
- **Kỳ vọng:**
  - Chạy trọn vẹn 6 lượt không chạm `REACT_STATE_TOO_LARGE`, giữ đúng `evidence_refs` và ra build hợp lệ mở được sang `/build-pc`.

### SC-163 — Người dùng bấm Hủy / Dừng sinh câu trả lời giữa chừng

- **Tiền điều kiện:** Đang stream câu trả lời trên `/assistant`.
- **Các bước thực hiện:**
  1. Gửi một yêu cầu phức tạp, ngay khi đang xử lý bấm nút dừng (hoặc đóng/abort request).
  2. Sau đó gửi tiếp 1 tin nhắn mới trong cùng conversation.
- **Kỳ vọng:**
  - Run cũ kết thúc với `CANCELLED`, checkpoint chính thức trước đó vẫn toàn vẹn để chat tiếp lượt sau.

### SC-164 — Cô lập giữa 2 cuộc hội thoại song song cùng 1 tài khoản

- **Tiền điều kiện:** Mở 2 tab trình duyệt cùng đăng nhập 1 user, tạo 2 conversation khác nhau.
- **Các bước thực hiện:**
  1. Tab A: Build PC Gaming 40 triệu.
  2. Tab B: Build PC Văn phòng 10 triệu.
  3. Quay lại Tab A hỏi: `Tổng tiền bộ máy của mình là bao nhiêu?`
- **Kỳ vọng:**
  - Tab A trả lời đúng ~40 triệu, tuyệt đối không bị `saved_build` của Tab B ghi đè (`saved_snapshot_scope`).
