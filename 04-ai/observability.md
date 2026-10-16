# Logs and traces

Mỗi turn được nhận tạo một `run_id` và một `trace_id` cố định. Mỗi step có span riêng;
retry/resume giữ trace cũ, nhưng có `execution_id` và `generation` khác.

```text
Submit turn → agent_runs.trace_id → ManagedExecutor
                                  └─ run.execute
                                     ├─ register_request / agent → model.call
                                     ├─ validate_action / resolve_proposal / ...
                                     ├─ tool.<name> → web.search / web.read
                                     └─ run.finalize
                                             │
                                      OTLP/HTTP exporter
                                             ↓
                              LGTM: Loki logs + Tempo traces
                                             ↓
                                          Grafana
```

`trace_id` là run UUID bỏ dấu `-` (32 hex), không phải conversation ID. Hai câu
trong cùng conversation có hai trace. Idempotent submit trả lại cùng run/trace.
Trace là reference chẩn đoán, không cấp quyền truy cập conversation.

## Chạy local

Từ workspace:

```bash
docker compose -f backend/docker-compose.yml up -d lgtm
```

Trong ignored `ai-service/.env`:

```dotenv
AI_OTLP_ENDPOINT=http://localhost:4318
AI_LOG_LEVEL=INFO
```

Restart AI service sau khi đổi env. Compose profile AI tự dùng `http://lgtm:4318`.
Không có endpoint: vẫn có JSON console logs; không gửi vào store.

Mở [PC Shopping - AI Runs](http://localhost:3300/d/pcshop-ai). Đăng nhập Grafana theo
cấu hình backend local, dán `data.trace_id` từ submit/get run vào ô **Trace ID**.
SSE START và result chứa cùng run reference. Dùng `.*` để xem tất cả.

- **Loki**: log theo step, thời gian, outcome và lỗi.
- **Tempo**: mở trace để xem waterfall và parent/child spans; search có thể chậm hơn lookup trực tiếp bằng ID.

Explore → Loki:

```logql
{service_name="ai-service"} | trace_id="<32-hex trace ID>"
```

Explore → Tempo: chọn lookup theo Trace ID, hoặc search:

```traceql
{ resource.service.name = "ai-service" }
```

## Một log chứa gì?

```json
{
  "event": "step.finished",
  "step": "web.read",
  "trace_id": "a9f00ab457504619a93b27998c5cb343",
  "span_id": "0123456789abcdef",
  "duration_ms": 184.2,
  "outcome": "SUCCEEDED",
  "result_status": "UNREADABLE"
}
```

Ngoài ra có timestamp, level, run/conversation/execution ID và generation.
`outcome` nói step thực thi thành công/lỗi/cancel; `result_status` nói kết quả nghiệp vụ.
Đọc trang thành công nhưng trang bị chặn có thể là `SUCCEEDED / UNREADABLE`.
Lỗi ghi class/static classification, không dump exception body/stack.

## Ownership và giới hạn

- Instrumentation nằm ở infrastructure; không nhét logging vào optimizer/domain.
- Executor sở hữu trace, không HTTP/SSE connection. Disconnect không đóng execution trace.
- Graph nodes, native model calls, dispatched tools và từng web I/O có spans/logs.
- JSON console luôn có; OTLP dùng batch SDK, shutdown sau executor drain rồi flush.
- Không ghi prompt, câu trả lời, tool args/results, API key, JWT hay full URL/query.
- Store dùng volume `pcshop-lgtm-data`; restart container không xóa volume. Không chạy `down -v` nếu muốn giữ log.
- LGTM all-in-one phục vụ local/dev. Chưa cấu hình retention/backup/access-control cho production;
  chính sách conversation90 ngày không tự áp vào telemetry. Export không phải audit journal:
  collector lỗi, queue đầy hoặc process bị kill vẫn có thể mất log; không được chặn business flow.
- Chưa tự truyền W3C context sang backend/external websites; trace này bao phủ AI execution,
  không mặc nhiên là distributed trace của mọi service. Chưa có token/cost dashboard.

Wiring: `infrastructure/observability.py`, `execution/supervisor.py`,
`graph/flexible.py`, `providers/failures.py`, `search/budgeted.py`.
Hướng kiểm thử: [Testing](testing.md). Tiến độ: [Status](stateful-implementation-status.md).

SDK/exporter theo [OpenTelemetry Python](https://opentelemetry.io/docs/languages/python/exporters/).
