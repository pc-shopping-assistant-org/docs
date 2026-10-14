# Testing

Tests được chia theo **business core**, **native persistence** và **live integration**.
Pass ở một lớp không chứng minh lớp khác.

## Core tests

Từ `ai-service/`:

```bash
uv run pytest -q
```

Scripted model/HTTP/catalog fixtures kiểm tra decisions; optimizer, resolver,
compiler, verifier và application rules là code thật.

Ưu tiên các flow chính: đọc catalog, build, sửa requirements, confirmation, hỏi
làm rõ và tiếp tục. Sau đó kiểm tra rejection quan trọng: wrong owner, stale refs,
unsupported constraints, thiếu evidence và atomic merge failure.

## PostgreSQL integration

Cấu hình `AI_TEST_POSTGRES_DSN` local/test và chạy:

```bash
uv run alembic upgrade head
uv run python -m ai_service.bootstrap_stateful
uv run pytest -q integration_tests
```

Dùng saver/SQL thật để kiểm tra accepted-vs-orphan, root, restart/resume, attempts,
stop evidence, lineage và CAS. Không thay bằng MemorySaver/SQLite để claim durability.

Không reset volume hoặc trỏ test vào production. Authentication/model/catalog
fixtures trong native tests vẫn không phải live service proof.

## Static checks

```bash
uv run ruff check src tests integration_tests migrations
uv run mypy src
uv lock --check
```

## Live smoke

Chỉ chạy khi owner đã cấu hình identity/catalog/model thật. Theo một hành trình:

1. Login → create conversation → catalog question.
2. Build có budget/workload → clarify/confirm nếu cần.
3. Follow-up đổi một yêu cầu → build mới hoặc typed unsupported/negative outcome.
4. Reload/read accepted history; kiểm tra sản phẩm, chi phí và quyền sở hữu.

Không suy semantic quality hoặc factuality của prose từ Pydantic validation.
Không ghi API key/JWT/raw sensitive prompt vào logs hoặc test fixtures.

## Test a change

Viết regression cho lỗi thực tế → chứng minh RED → fix nhỏ nhất → focused GREEN.
Thay requirement/tool phải test cả output contract và final completion, không chỉ
handler trả DTO. Sau đó chạy relevant full/static/native gates theo risk.

Kết quả có date/command/environment ở [status](stateful-implementation-status.md);
historical counts không phải bằng chứng chạy lại hôm nay.

**Next:** [Add a tool](guides/add-tool.md) · [Extend requirements](guides/extend-requirements.md).
