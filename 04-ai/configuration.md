# Configuration

Settings đọc `AI_*` từ ignored `.env`; biến shell có ưu tiên cao hơn.
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
| `AI_HARDWARE_CATALOG_MAPPING` | Versioned JSON mapping taxonomy/spec/options |
| `AI_PROVIDER` | `openai` hoặc `gemini` cho stateful execution |
| `AI_OPENAI_API_KEY` / `AI_GEMINI_API_KEY` | Key tương ứng provider đã chọn |

`AI_MODEL_NAME` là bare model ID override, không dạng `provider:model`.
Default provider model names nằm trong Settings, không phải khuyến nghị benchmark.
`AI_REQUEST_TIMEOUT_SECONDS` điều khiển HTTP/provider timeout, không phải toàn run deadline.

`AI_PROVIDER=fallback` không hợp lệ cho server. Thiếu provider/key/mapping sẽ làm
startup lỗi; Settings/OpenAPI và các công cụ offline vẫn dựng được không cần network.

## Hardware mapping

Mapping nội bộ có `version`, `categories`, `spec_fields`, `option_fields`:

- Category UUID map tới một core component category; không đoán từ tên hoặc kế thừa category con.
- `spec_fields` map canonical field tới backend specification key.
- Option UUID map tới canonical field; `null` chỉ cho cosmetic option.
- Variant option override product common spec; price/stock/ID luôn từ variant.
- Không nhận mapping từ user/model; thiếu metadata không tự điền defaults.

Xem [catalog snapshot reference](../05-api/catalog-snapshot.md). Read-only turns không
quét hardware snapshot; mapping vẫn là startup prerequisite cho runtime build/resolve.

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

## Execution limits

Graph limits và durable attempt/run limits là hai lớp khác nhau. Defaults thuộc
`ReactLimits`, coordinator và provider adapters, không tự biến thành hard billing cap.
Thay limits phải giữ version/config snapshot và các budget/recovery tests.

**Next:** [State and recovery](context-management.md) · [Troubleshooting](troubleshooting.md).
