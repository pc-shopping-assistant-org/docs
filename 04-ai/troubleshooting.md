# Troubleshooting

Bắt đầu bằng startup log, selected runtime và dependency đã cấu hình; không reset
DB hoặc fallback legacy để che lỗi.

## Stateful routes không xuất hiện

Kiểm tra `AI_STATEFUL_ENABLED=true` trong Settings thực tế; biến shell override
`.env`. Restart server sau khi đổi config. Frontend V2 còn cần react enabled/version v2.

## AI_DATABASE_URL must be configured

Migrations/bootstrap đọc env từ working directory `ai-service/`.
Kiểm tra `.env` tồn tại và URL dùng `postgresql+psycopg://`. Không gửi credentials vào chat/log.

## PostgreSQL password/port error

Đối chiếu host port, user/password/database với Compose và local DSN.
Port host khác port nội bộ container. Volume đã initialize không tự đổi password
theo env mới; đừng xóa volume nếu chưa chốt việc bỏ dữ liệu.

## Migration or saver readiness error

Chạy `uv run alembic upgrade head`, sau đó
`uv run python -m ai_service.bootstrap_stateful`.
Application tables và native saver tables có owner khác nhau; không chỉnh tay saver rows.

## Submit returns 422

Kiểm tra path/body conversation ID, explicit `schema_version: 2`, UUID, current
`expected_revision` và chỉ một continuation command.
Schema ở [HTTP V2](../05-api/stateful-chat-v2.md), không copy field V1 sang V2.

## Submit returns 409

Run có thể busy, revision stale hoặc cùng request ID nhưng body đã đổi.
GET conversation/run trước khi quyết định gửi lượt mới.
Retry cùng request/body trả run cũ; nó không có nghĩa tạo recovery execution.

## Tool không được expose

Policy chỉ expose tools phù hợp state. Thiếu budget/workload/resolved requirements
thì `build_pc` không được gọi. Unsupported không được bỏ qua để build.

## Run busy sau worker chết

Lease hết hạn không chứng minh worker/checkpoint writes đã dừng. Runtime chỉ
auto-retry selected failures sau persisted owning stop ACK. Process-death recovery
mở rộng chưa enabled; cần trusted recovery policy, không sửa status/locks bằng SQL.

## SSE mất kết nối

Không tự cancel run. Poll GET run, rồi đọc accepted result/history. Reconnect
automatic/token stream ngoài scope; đừng gửi lại body với request ID mới chỉ để lấy result.

## Web page unreadable or facts UNKNOWN

Trang bị chặn, extractor không đọc được hoặc template/metadata không đủ.
Đổi nguồn hoặc trả thiếu evidence; không coi snippet/text chung là structured benchmark.

**Next:** [Configuration](configuration.md) · [Testing](testing.md).
