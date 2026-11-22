# Nhóm H: Clarification, Unit Disambiguation & Amendment (`SC-133` → `SC-150`)

Phạm vi: Kiểm thử luồng `WAITING_INPUT`, `ASK_CLARIFICATION`, `interpret_reply`, `amend_pending`, `QUANTITY_UNIT_REQUIRED`, `PendingResolution`, `ProposalConfirmation` và phục hồi checkpoint khi F5.

---

### SC-133 — Yêu cầu trống thông tin → Hỏi làm rõ nhiều lượt

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Ráp giúp mình một bộ PC nhé.`
  2. Khi AI hỏi lại, gửi: `Tầm 22 triệu.`
  3. Khi AI hỏi thêm nhu cầu, gửi: `Chủ yếu chơi game 1080p.`
- **Kỳ vọng:**
  - Lượt 1 & 2 dừng ở `WAITING_INPUT` (`ASK_CLARIFICATION`), Lượt 3 đủ thông tin mới chạy `BUILD_PC`.

### SC-134 — Trả lời làm rõ bằng câu tự nhiên dài

- **Tiền điều kiện:** Đang ở trạng thái chờ làm rõ ngân sách/nhu cầu.
- **Các bước thực hiện:**
  1. Gửi: `Build giúp mình bộ PC.`
  2. Gửi tiếp: `Chắc mình chi tối đa khoảng 28 triệu thôi, dùng để vừa học lập trình vừa chơi game nhẹ cuối tuần.`
- **Kỳ vọng:**
  - `interpret_reply` tách đúng `28.000.000 VND` và profile phù hợp, không bắt user phải trả lời đúng cú pháp cứng.

### SC-135 — Unit Disambiguation: Thiếu đơn vị dung lượng (`QUANTITY_UNIT_REQUIRED`)

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build cho mình PC tầm 20 triệu có ổ cứng 1 và RAM 16.`
- **Kỳ vọng:**
  - Trigger `QUANTITY_UNIT_REQUIRED`, AI hỏi xác nhận đơn vị (1TB hay 1GB, 16GB).

### SC-136 — Trả lời Unit Clarification tự nhiên

- **Tiền điều kiện:** Đang chờ trả lời từ `SC-135`.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Ổ cứng 1TB còn RAM 16GB nhé bạn.`
- **Kỳ vọng:**
  - `unit_clarifier` chuẩn hóa đúng `STORAGE=1000GB`, `RAM=16GB` và chạy tiếp `BUILD_PC`.

### SC-137 — Ambiguous Product Reference (Tên chung khớp nhiều SKU)

- **Tiền điều kiện:** Shop có >= 2 biến thể `RTX 4060` (vd ASUS, Gigabyte, MSI).
- **Các bước thực hiện:**
  1. Gửi: `Build cho mình dàn PC 25 triệu bắt buộc dùng card RTX 4060 của shop.`
- **Kỳ vọng:**
  - Trả về `PendingResolution` (`WAITING_INPUT`) liệt kê các mẫu RTX 4060 của shop kèm giá để khách chọn.

### SC-138 — Chọn biến thể theo số thứ tự ("con thứ 2")

- **Tiền điều kiện:** Đang ở trạng thái `PendingResolution` từ `SC-137`.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Lấy con thứ 2 trong danh sách đó đi bạn.`
- **Kỳ vọng:**
  - `clarifier` map đúng sang lựa chọn số 2, ghim variant đó và hoàn tất build.

### SC-139 — Chọn biến thể theo đặc điểm ("bản rẻ nhất" / "hãng ASUS")

- **Tiền điều kiện:** Đang ở trạng thái `PendingResolution`.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Chọn giúp mình bản của ASUS (hoặc bản rẻ nhất) trong mấy con trên nhé.`
- **Kỳ vọng:**
  - `derive_resolution_reply` chọn đúng biến thể khớp tên/giá.

### SC-140 — Amendment khi đang Pending (`amend_pending` thay thế linh kiện)

- **Tiền điều kiện:** Đang chờ chọn biến thể RTX 4060 (`PendingResolution`).
- **Các bước thực hiện:**
  1. Gửi tiếp: `Thôi không lấy RTX 4060 nữa, đổi sang chọn RTX 4070 giúp mình với ngân sách 35 triệu.`
- **Kỳ vọng:**
  - Nhảy qua `amend_pending`, thay thế item cũ bằng RTX 4070 + 35tr mà không bị kẹt ở pending cũ.

### SC-141 — Discard khi đang Pending (Bỏ chọn thủ công để AI tự chọn)

- **Tiền điều kiện:** Đang chờ chọn biến thể GPU.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Thôi bỏ qua yêu cầu chọn riêng card đó đi, bạn cứ tự chọn card tối ưu nhất trong tầm 25 triệu giúp mình.`
- **Kỳ vọng:**
  - `amend_pending` bỏ item đang pending và chạy optimizer tự do theo ngân sách 25tr.

### SC-142 — Hỏi chen ngang (Side-question) giữa lúc Pending

- **Tiền điều kiện:** Đang ở `PendingResolution` với 2–3 lựa chọn GPU.
- **Các bước thực hiện:**
  1. Gửi tiếp: `Khoan, trong mấy con bạn vừa liệt kê thì con đầu tiên dài bao nhiêu mm vậy?`
  2. Sau khi AI trả lời, gửi: `OK vậy chốt lấy con đầu tiên đó nhé.`
- **Kỳ vọng:**
  - Lượt 1 trả lời đúng thông số từ `resolution_options` mà **không xóa mất `pending_draft`**; Lượt 2 chốt tiếp bình thường.

### SC-143 — Proposal Confirmation (`NEEDS_CONFIRMATION`)

- **Tiền điều kiện:** User đặt ràng buộc ngân sách/linh kiện khiến hệ thống đề xuất điều chỉnh.
- **Các bước thực hiện:**
  1. Yêu cầu thay đổi cấu hình lớn tạo ra `pending_proposal`.
- **Kỳ vọng:**
  - Tạm dừng ở `WAITING_INPUT`, hỏi rõ user có đồng ý cập nhật ràng buộc mới không.

### SC-144 — Xác nhận đồng ý Proposal

- **Tiền điều kiện:** Đang có `pending_proposal` từ `SC-143`.
- **Các bước thực hiện:**
  1. Gửi: `OK đồng ý đổi theo phương án đó đi.`
- **Kỳ vọng:**
  - `confirm_agent_patch` cập nhật `working_requirements` (tăng `revision`) và chạy lại build.

### SC-145 — Từ chối Proposal (`discard_pending`)

- **Tiền điều kiện:** Đang có `pending_proposal`.
- **Các bước thực hiện:**
  1. Gửi: `Không, giữ nguyên yêu cầu ban đầu của mình đi.`
- **Kỳ vọng:**
  - Hủy `pending_proposal`, không thay đổi `working_requirements`.

### SC-146 — Chuyển hướng nhu cầu đột ngột giữa phiên

- **Tiền điều kiện:** Vừa build xong dàn Gaming 30tr.
- **Các bước thực hiện:**
  1. Gửi: `À thôi giờ mình không mua máy chơi game nữa, đổi sang tìm bộ văn phòng 10 triệu cho em gái nhé.`
- **Kỳ vọng:**
  - Reset đúng mục tiêu sang `OFFICE_BUDGET` 10tr, không giữ lại ràng buộc GPU rời của lượt trước.

### SC-147 — Diễn đạt tiền tệ bằng tiếng lóng Việt Nam

- **Tiền điều kiện:** Đang hỏi làm rõ ngân sách.
- **Các bước thực hiện:**
  1. Gửi: `tầm 25 củ khoai` (hoặc `15tr5`, `30 chai`).
- **Kỳ vọng:**
  - Parse chính xác sang `25.000.000` / `15.500.000` / `30.000.000 VND`.

### SC-148 — Nhập ngân sách dạng khoảng ("20 đến 25 triệu")

- **Tiền điều kiện:** Phiên mới.
- **Các bước thực hiện:**
  1. Gửi: `Build PC gaming 1080p ngân sách từ 20 đến 25 triệu.`
- **Kỳ vọng:**
  - Chọn cận trên hợp lý (25M) để tối ưu trong giới hạn khách cho phép, không lỗi validation.

### SC-149 — Gửi câu hỏi ngoài lề khi đang chờ Clarification

- **Tiền điều kiện:** Đang ở `WAITING_INPUT` chờ chọn ngân sách.
- **Các bước thực hiện:**
  1. Gửi: `À cho mình hỏi shop có hỗ trợ trả góp không?`
- **Kỳ vọng:**
  - Trả lời lịch sự trong phạm vi thông tin có được (hoặc nhắc câu hỏi còn dang dở), không làm hỏng state graph.

### SC-150 — Tải lại trang (F5) ngay giữa trạng thái `WAITING_INPUT`

- **Tiền điều kiện:** Đang chờ chọn biến thể hoặc trả lời clarification.
- **Các bước thực hiện:**
  1. Nhấn **F5** tải lại trang `/assistant`.
  2. Tiếp tục gửi câu trả lời lựa chọn.
- **Kỳ vọng:**
  - Checkpoint Postgres khôi phục đầy đủ `pending_draft` / `task_outcomes`, cuộc hội thoại nối tiếp mượt mà.
