# Nhóm L: Observability, Distributed Tracing & Fault Handling (`SC-191` → `SC-200`)

Phạm vi: Kiểm thử stack `grafana/otel-lgtm` (Loki, Tempo, Prometheus), dashboard `pcshop-ai.json` & `pcshop-services.json`, W3C `traceparent` xuyên `api-gateway ↔ ai-service ↔ catalog-service`, `error_location` và nguyên tắc Privacy-by-Design.

---

### SC-191 — Bảng `AI Step Summary` trên Dashboard `PC Shopping - AI Runs`
- **Tiền điều kiện:** Đã chạy ít nhất 1 lượt chat hoàn chỉnh trên `/assistant`.
- **Các bước thực hiện:**
  1. Mở Grafana → Dashboard **PC Shopping - AI Runs** (`pcshop-ai.json`).
  2. Quan sát panel bảng **AI Step Summary**.
- **Kỳ vọng:**
  - Hiển thị đầy đủ các cột `Time | Step | Outcome | Duration (ms) | Status | Error | Location | Trace ID`.
  - Các step `begin_turn`, `prepare_agent`, `agent`, `validate_action`, `execute_tool`, `prepare_publish`, `run.execute` hiện trạng thái `SUCCEEDED` tô nền xanh.

### SC-192 — Giao diện `Detailed Logs` gọn 1 dòng (không còn nhãn rác)
- **Tiền điều kiện:** Mở `PC Shopping - AI Runs` & `PC Shopping - Services Overview`.
- **Các bước thực hiện:**
  1. Xem panel **Detailed Logs** / **All Logs**.
  2. Click vào 1 dòng log bất kỳ để mở Log Details.
- **Kỳ vọng:**
  - Không còn dải nhãn xám (`service_name`, `detected_level`, `scope_name`...) chen trước mỗi dòng; định dạng 1 dòng gọn `[trace_id_8] [step] SUCCEEDED (ms)`; click vào mới mở full metadata.

### SC-193 — Lọc Log theo `Level`, `Trace ID` và `Search`
- **Tiền điều kiện:** Có log cả `info` và `error`/`warn` trên hệ thống.
- **Các bước thực hiện:**
  1. Thử chọn `Level = error` trên thanh filter đầu dashboard.
  2. Thử gõ từ khóa vào ô `Search` (vd `compatibility` hoặc `agent`).
  3. Dán `trace_id` của 1 lượt chat vào ô `Trace ID`.
- **Kỳ vọng:**
  - Cả bảng **AI Step Summary** và **Detailed Logs** lọc khớp tức thì theo biến đã chọn.

### SC-194 — Liên kết trực tiếp từ `Trace ID` sang Tempo Waterfall
- **Tiền điều kiện:** Có dữ liệu trong bảng **AI Step Summary**.
- **Các bước thực hiện:**
  1. Click vào giá trị ở cột **Trace ID** trong bảng.
- **Kỳ vọng:**
  - Mở sang Explore Tempo đúng trace đó, thấy cây span cha–con `run.execute` → `agent` / `execute_tool` → `tool.*`.

### SC-195 — Distributed Trace cho API đồng bộ `/api/v1/compatibility/optimize`
- **Tiền điều kiện:** Gọi nút **AI tự tối ưu** trên `/build-pc` (đi qua `api-gateway` → `ai-service` → `catalog-service`).
- **Các bước thực hiện:**
  1. Tìm trace mới nhất trong Tempo của `api-gateway` hoặc `ai-service` cho `HTTP POST /api/v1/compatibility/optimize`.
- **Kỳ vọng:**
  - `trace_id` nối xuyên suốt từ `api-gateway` sang `ai-service` (`http_request_span` nhận `traceparent`) và xuống `catalog-service` (`GET /products/snapshot`).

### SC-196 — Distributed Trace khi ReAct gọi `search_catalog` / `compare_products`
- **Tiền điều kiện:** Gửi 1 câu hỏi tìm kiếm sản phẩm trong `/assistant`.
- **Các bước thực hiện:**
  1. Mở Tempo xem trace của run vừa thực hiện.
- **Kỳ vọng:**
  - Bên dưới span `tool.search_catalog` của `ai-service` xuất hiện span con thuộc `catalog-service` / `search-service` (nhờ `trace_headers()` trên `httpx`).

### SC-197 — Biểu đồ Prometheus Metrics cho `ai-service`
- **Tiền điều kiện:** `AI_OTLP_ENDPOINT=http://lgtm:4318` đang bật và vừa có vài lượt chạy.
- **Các bước thực hiện:**
  1. Kiểm tra 2 panel đầu của `PC Shopping - AI Runs`: **AI Step Rate by Outcome (req/s)** và **AI Step p95 Latency (ms)**.
- **Kỳ vọng:**
  - Có dữ liệu `ai_step_total` và `ai_step_duration_ms_bucket` phân tách theo `ai_step` và `ai_outcome`.

### SC-198 — Bắt lỗi 500 Unhandled Exception kèm `error_location`
- **Tiền điều kiện:** Kích hoạt 1 lỗi nội bộ chưa bắt (hoặc kiểm tra qua test / endpoint lỗi giả lập).
- **Các bước thực hiện:**
  1. Mở panel **Errors & Warnings** (hoặc lọc `Level=error`) trên Grafana.
- **Kỳ vọng:**
  - Log có đầy đủ `event=http.unhandled_exception`, `trace_id`, `error_type`, và `error_location` dạng `file.py:line:func` giúp định vị ngay vị trí lỗi.

### SC-199 — Kiểm tra Privacy-by-Design (Không rò rỉ Prompt / PII / Secret)
- **Tiền điều kiện:** Gửi tin nhắn có chuỗi nhận diện đặc biệt trong chat: `Xin chào CANARY_SECRET_TOKEN_998877 tư vấn PC 20 triệu`.
- **Các bước thực hiện:**
  1. Vào Grafana Explore → Loki & Tempo, tìm chuỗi `CANARY_SECRET_TOKEN_998877`.
- **Kỳ vọng:**
  - Trả về **0 kết quả** trong cả Loki logs lẫn Tempo span attributes.

### SC-200 — Độ ổn định bộ nhớ Container `lgtm` dưới tải liên tục
- **Tiền điều kiện:** Stack `compose.yaml` chạy full profile `apps` với `LGTM_MEM_LIMIT=1024m`.
- **Các bước thực hiện:**
  1. Chạy liên tiếp ~20 lượt chat + **AI tự tối ưu** trên UI.
  2. Kiểm tra `docker stats lgtm --no-stream` và `docker inspect lgtm`.
- **Kỳ vọng:**
  - `OOMKilled=false`, RAM sử dụng ổn định dưới ngưỡng giới hạn, Grafana/Loki/Tempo vẫn phản hồi nhanh.
