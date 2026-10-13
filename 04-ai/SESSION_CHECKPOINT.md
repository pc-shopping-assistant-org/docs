# Resume checkpoint — 2026-10-13

## Đọc trước

1. File này.
2. [Implementation status](stateful-implementation-status.md).
3. [Plan](stateful-chat-implementation-plan.md), chỉ phần phase đang làm.
4. Root `AGENTS.md`; không cần đọc lại toàn bộ lịch sử chat.

## Đã verify

- P6-01 core architecture audit COMPLETED theo scope đã chọn; **không phải toàn
  dự án/production hoàn tất**. V2 opt-in, default V1.
- Gate cuối: **725 core + 100 PostgreSQL tests pass**, Ruff/mypy168 pass;
  offline lock/diff checks pass. `alembic current`: `0003_initial_root (head)`.
- ISSUE-113 fixed: dynamic registration tiếp tục được accepted pending proposal;
  publication giữ task semantics, cho phép requirements revision đổi có authority.
- Confirm30m → explicit25m → optimizer → CAS/resume pass. Cancel/conflict không
  publish head/assistant mới. Stop ACK persist lỗi thì giữ busy, không fake release.
- R1 lỗi sau tool commit → stored stop ACK/release → saver reopen → R2 từ accepted
  root pass; không dùng newer orphan/evidence của R1.

Evidence: [core audit](core-audit.md), root `USECASE_IMPLEMENTATION.md`.
Tracker: 114 issues; open10 / in-progress12 / resolved92 / blocked0.
ISSUE-114: heartbeat cancellation fallback logs an expected cancel as ERROR;
functional CANCELLED/drain is verified, diagnostic improvement deferred.

## Đang dừng ở đâu

**P5 — GET `/api/v1/conversations`: implemented/verified.**
**P5 — POST cancel run: implemented/verified.** Durable flag before signal;
claimed execution stays busy until drain/ACK. Pending/no-claim cancels directly;
missed local signal uses owning heartbeat. Publication race suppresses head/answer.
Tests: `tests/test_run_cancel_api.py`, `integration_tests/test_run_cancel_postgres.py`
and `test_explicit_user_managed_postgres.py` CANCEL_DURING_PUBLISH case.

File mới:
`ai-service/integration_tests/test_conversation_list_postgres.py`

Focused command đã chạy:

```bash
cd /home/lamdx4/Projects/pc-shopping-assistant-org/ai-service
uv run --no-sync pytest -q integration_tests/test_conversation_list_postgres.py --tb=short
```

History: 2 PostgreSQL RED (missing list), 2 HTTP RED (GET405), now GREEN.
Also `tests/test_conversation_list_api.py`: auth, paging, envelope, V1/V2 schema,
saved flexible answer retained. List slice gate: 723 core / 96 PostgreSQL;
latest list+cancel full gate: 725 core / 100 PostgreSQL pass.

## Làm tiếp

1. Persisted event stream/SSE reconnect, then frontend conversation list/history/chat.
2. Live catalog/identity/model gate; delete/retention later. Update tracker/docs each slice.

Contract đã có: limit1–100/default20; updated_at DESC + id DESC; owner-only;
malformed/missing/foreign cursor trả400 static VALIDATION_ERROR, errors.field=cursor.
Cursor là UUID conversation đã lưu, lookup owner trước khi paging.
Order là live listing, không snapshot: conversation đổi updated_at có thể dịch vị trí.
Không cho cursor chọn checkpoint/owner; semantics đã ghi trong API docs.

`list_owned()` giữ limit tối đa100; service dùng query lookahead riêng limit1.
List response dùng public conversation
view; checkpoint lookup chỉ exact accepted head, không latest.

## Worktree / delivery

- Root workspace không là Git repo; `ai-service`, `docs`, `backend` là repo riêng.
- AI commits: `80303a1` (accepted-task/requirement-edit guards + root recovery gate),
  `d679cea` (conversation list/durable cancel + HTTP/PostgreSQL gates). Chưa push.
- Docs core/status/plan/API và checkpoint này được commit cùng đợt; xem
  `git -C docs log -1`. Không reset/overwrite dirty changes ở repo khác.
- Root tracker ngoài Git. Backend thay đổi riêng giữ nguyên; chưa update submodule.
- Không ghi/commit `.env`, keys/token/password; test cleanup chỉ UUID do fixture tạo.

## Còn lại ngoài core

P5 delete/events/persisted SSE/frontend/retention; live provider/catalog/
identity smoke; FULL_SETUP/soft scorer/source expansion/older selectors; P6-02 replay.
Hard-death authority, automatic root reconciliation/migration và multi-retry expansion
chưa implemented. Không takeover chỉ vì lease/heartbeat/run status.

User resumed with “ok impl”; list/cancel slices completed. Continue events/SSE next;
Commits đã được tạo theo yêu cầu user; chưa push. Core audit remains completed,
not whole-project completion.
