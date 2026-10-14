# First steps

Trang này giúp chạy **Stateful ReAct V2** và gửi một lượt chat.
Thực hiện từ workspace có `ai-service/`, `backend/` và `docs/` cạnh nhau.

## Prerequisites

- Python theo `ai-service/pyproject.toml` (hiện hỗ trợ 3.12–3.13) và uv.
- PostgreSQL có database `ai_db`; dùng backend Compose local.
- Identity service cấp access JWT và JWKS endpoint truy cập được.
- Catalog service có search/detail và [snapshot endpoint](../05-api/catalog-snapshot.md).
- OpenAI hoặc Gemini key; hardware mapping dùng category/option UUID thật.

Không có provider/catalog/auth thì có thể chạy [core tests](testing.md), nhưng
không thể coi đó là live chat.

## 1. Configure dependencies

Từ `ai-service/`, tạo ignored `.env` theo `.env.example` nếu chưa có. Không ghi đè
file đang chứa credentials. Điền DB/JWT/provider/catalog và chọn runtime:

```dotenv
AI_STATEFUL_ENABLED=true
AI_STATEFUL_BUILD_ENABLED=false
AI_STATEFUL_REACT_ENABLED=true
AI_STATEFUL_REACT_VERSION=v2
```

Xem [Configuration](configuration.md) cho các biến bắt buộc. Settings default vẫn
stateful-off/V1; frontend V2 không tự chuyển sang legacy khi server chưa cấu hình.

Bật database dùng chung:

```bash
docker compose -f ../backend/docker-compose.yml up -d postgres
```

Volume cũ chưa có `ai_db`: chạy init script sẵn có:

```bash
docker compose -f ../backend/docker-compose.yml exec -T \
  -e POSTGRES_MULTIPLE_DATABASES=ai_db postgres \
  bash /docker-entrypoint-initdb.d/init-multiple-databases.sh
```

Không reset volume để xử lý lỗi migration.

## 2. Install and initialize

```bash
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv sync
uv run alembic upgrade head
uv run python -m ai_service.bootstrap_stateful
uv run uvicorn ai_service.main:app --reload
```

Alembic tạo application tables; bootstrap tạo native saver tables. Startup chỉ
kiểm tra readiness, không làm migrations trong HTTP requests hoặc fallback sang RAM.

Mở `http://localhost:8000/docs`. Stateful routes phải xuất hiện trong OpenAPI.

## 3. Create a conversation

Các lệnh dưới dùng `AI_ACCESS_TOKEN` đã đặt trong shell local. Không lưu token vào docs/git.

```bash
curl -sS -X POST http://localhost:8000/api/v1/conversations \
  -H "Authorization: Bearer $AI_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Tư vấn PC"}'
```

Kết quả nằm trong `data`; lấy `id` và `revision` từ response. Conversation mới
READY có initial accepted root và revision 0, chưa có assistant message.

## 4. Submit a turn

Thay các UUID minh họa bằng conversation ID đã tạo và request ID mới:

```json
{
  "schema_version": 2,
  "conversation_id": "11111111-1111-4111-8111-111111111111",
  "request_id": "22222222-2222-4222-8222-222222222222",
  "expected_revision": 0,
  "message": "Tìm laptop phù hợp để học lập trình"
}
```

POST body đó tới `/api/v1/conversations/{conversation_id}/runs`. Server trả 202
và run ID; đây là admission, chưa phải answer hoàn tất. Dùng revision hiện tại,
không hardcode 0 cho các lượt tiếp theo.

## 5. Read the result

- Poll `GET /api/v1/conversations/{conversation_id}/runs/{run_id}`.
- Hoặc mở một SSE connection tới cùng path + `/events`.
- Đọc accepted state bằng GET conversation; history bằng path + `/messages`.

SSE disconnect không cancel run. Không reconnect/retry tự động; nếu mất stream,
poll run để biết kết quả. DELTA hiện là answer đã validate, không phải provider token stream.

**Next:** [Agent and tools](agent-tools.md). Gặp lỗi: [Troubleshooting](troubleshooting.md).
