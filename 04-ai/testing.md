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

## GitHub Actions

`ai-service/.github/workflows/build-image.yml` chạy verify trên mọi push, PR,
merge queue và manual dispatch. Job chạy Ruff/mypy/core tests, tạo PostgreSQL18 tạm,
chạy Alembic + saver bootstrap rồi native tests; không dùng DB local hoặc model key.
Image chỉ chạy sau verify theo điều kiện release/PR, không publish từ merge queue.

Frontend workflow dùng Corepack/Yarn đã pin, sinh Next.js types trước typecheck,
kiểm tra lint/OpenAPI snapshots/tests/build. Không refresh OpenAPI từ live services.
Required check names: `Verify Python service`, `Verify Next.js application`.
Chọn chúng trong GitHub branch rules nếu muốn chặn merge; workflow không tự đổi policy.
Workflow/local verification không được coi là một GitHub run đã thành công.

Kiểm chứng local2026-10-15 trên checkout sạch: AI753 core +102 PostgreSQL18.3,
Ruff/mypy176; FE135 tests, lint/types/OpenAPI và default Turbopack build66 pages.
Python3.12.13/Node24.14.0; CI pins Python3.12/Node22. Cả hai workflow pass actionlint.
Chưa chạy trên GitHub; peer warning Next/ESLint hiện có được ghi tại ISSUE-132.

**Next:** [Add a tool](guides/add-tool.md) · [Extend requirements](guides/extend-requirements.md).
