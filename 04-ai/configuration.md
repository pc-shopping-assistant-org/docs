# Configuration

Settings đọc `AI_*` từ ignored `.env`; biến shell có ưu tiên cao hơn.
Biến env rỗng được bỏ qua để dùng mặc định; các giá trị bắt buộc vẫn được kiểm tra khi startup.
Nguồn chuẩn: [Settings](../../ai-service/src/ai_service/config/settings.py) và
[env example](../../ai-service/.env.example). Không đưa secrets vào tài liệu.

## Runtime

Server chỉ chạy Stateful ReAct V2. Các cờ `AI_STATEFUL_ENABLED`,
`AI_STATEFUL_BUILD_ENABLED`, `AI_STATEFUL_REACT_ENABLED` và `AI_STATEFUL_REACT_VERSION`
đã bỏ; xóa chúng khỏi env cũ. Startup kiểm tra dependencies trước khi mở tài nguyên.
`/chat` và `/chat/stream` cũ không còn được serve; dùng conversations/runs/events.
Không upgrade ngầm accepted V1 execution checkpoints. DTO/snapshot/DDL dùng chung
vẫn giữ version gốc; các fixture graph lịch sử không được chọn bởi server runtime.

## Required services

| Biến | Ý nghĩa |
| --- | --- |
| `AI_DATABASE_URL` | Application DB URL, scheme `postgresql+psycopg://` |
| `AI_JWT_JWKS_URL` | JWKS endpoint của identity service |
| `AI_JWT_ISSUER`, `AI_JWT_AUDIENCE` | Claims phải khớp access JWT |
| `AI_BACKEND_API_URL` | Catalog API root; adapter thêm `/products` |
| `AI_PROVIDER` | `openai`, `gemini` hoặc self-hosted `qwen` |
| `AI_OPENAI_API_KEY` / `AI_GEMINI_API_KEY` | Key tương ứng provider đã chọn |
| `AI_QWEN_BASE_URL` | Required với Qwen; vLLM API root, ví dụ http://localhost:8001/v1 |
| `AI_QWEN_MODEL_NAME` | Base ID hoặc adapter alias được vLLM serve |
| `AI_QWEN_API_KEY` | Optional nếu vLLM yêu cầu authentication |
| `AI_QWEN_MAX_TOKENS` | Output cap, default2048 |
| `AI_QWEN_REQUEST_TIMEOUT_SECONDS` | Qwen timeout riêng, default120s |

`AI_MODEL_NAME` là bare model ID override cho OpenAI/Gemini, không dạng `provider:model`.
Qwen dùng biến riêng trên; xem [train/serving runbook](training.md).
Default provider model names nằm trong Settings, không phải khuyến nghị benchmark.
`AI_REQUEST_TIMEOUT_SECONDS` điều khiển HTTP/cloud-provider timeout; Qwen có timeout
riêng. Chúng không phải toàn run deadline.

`AI_PROVIDER=fallback` không hợp lệ cho server. Thiếu provider/key sẽ làm
startup lỗi; Settings/OpenAPI và các công cụ offline vẫn dựng được không cần network.

## Hardware mapping

Category type lấy từ `hardwareType` (code của master data) trong snapshot catalog,
không đọc mapping UUID
từ env. Catalog seed production quản lý taxonomy; đổi tên category không đổi loại.
Category `OTHER` và các nhóm sản phẩm như `PREBUILT_PC` không phải slot linh kiện
nên được bỏ qua khi dựng candidate pool; chúng vẫn hợp lệ cho catalog/product search.
Snapshot thiếu field `hardwareType` vẫn bị từ chối; mã master mới không làm hỏng toàn
bộ trang nhưng không được tự ép vào một slot optimizer. Deploy catalog mới trước AI mới.

`AI_HARDWARE_CATALOG_MAPPING` là optional, chỉ dùng cho custom field mapping:
`version`, `spec_fields`, `option_fields`. Bỏ `categories` khỏi env cũ.

- Không đoán hardware type từ tên hoặc kế thừa category con.
- `spec_fields` map canonical field tới backend specification key.
- Option UUID map tới canonical field; `null` chỉ cho cosmetic option.
- Variant option override product common spec; price/stock/ID luôn từ variant.
- Không nhận mapping từ user/model; thiếu metadata không tự điền defaults.

Xem [catalog snapshot reference](../05-api/catalog-snapshot.md). Read-only turns không
quét hardware snapshot. Startup không cần category data hoặc field mapping;
catalog được đọc khi xử lý build/resolve.

## Database initialization

Application migrations và native bootstrap chạy riêng theo [First steps](getting-started.md).
Readiness fail nếu release migration không khớp hoặc saver tables chưa sẵn sàng.

`AI_TEST_POSTGRES_DSN` là DSN riêng cho integration tests, chỉ trỏ local/test.
Không dùng production, không sửa tables trực tiếp để né migration validation.

## Optional retrieval

`AI_RETRIEVAL_BACKEND=backend` là lexical baseline. Qdrant/hybrid cần
`AI_QDRANT_URL`, embedding provider/endpoint và collection đã provision.
Hash embeddings chỉ dành development. Indexing không điều kiện để stateful chat hoạt động;
[Retrieval](rag.md) phân biệt seam này với V2 canonical tools.

## Logs and traces

`AI_LOG_LEVEL` là DEBUG/INFO/WARNING/ERROR/CRITICAL, default INFO. JSON console logs
có run/trace/span IDs. `AI_OTLP_ENDPOINT=http://localhost:4318` gửi logs/traces vào
LGTM local; compose AI dùng `http://lgtm:4318`. Bỏ endpoint thì không export.
Kho log, Grafana và giới hạn: [Observability](observability.md).

## Execution limits

Graph limits và durable attempt/run limits là hai lớp khác nhau. Defaults thuộc
`ReactLimits`, coordinator và provider adapters, không tự biến thành hard billing cap.
Thay limits phải giữ version/config snapshot và các budget/recovery tests.

**Next:** [State and recovery](context-management.md) · [Troubleshooting](troubleshooting.md).
