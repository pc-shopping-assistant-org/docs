# Resume checkpoint — 2026-10-14

## Đọc trước

Root `AGENTS.md` → [AI documentation](README.md) → [status](stateful-implementation-status.md) →
[plan](stateful-chat-implementation-plan.md), chỉ phase đang làm.

## Đã làm

**Selected core-code milestone COMPLETED**, audit2026-10-14 theo plan§3.6.
Không có nghĩa live/full-project/production complete.

- FE chat/attachments/immutable confirmation dùng V2; không legacy fallback.
- Basic SSE: 1 admission + 1 subscription/run; no Last-Event-ID/reconnect/retry.
  Disconnect không cancel executor. DELTA là final validated text, không model tokens.
- Journal/lifecycle0004–0005: owner-scoped, dedup/sequence; completion atomic cùng CAS.
- Published context: tối đa4 cặp/12k chars, owner/revision scoped; freeze khi recovery.
  Task registration và agent cùng nhận history, không dùng nó làm current facts.
- Hardware snapshot lazy ở build/resolve; read-only không preload.
- Numerical facts server-rendered; qualitative explanation cần selected evidence refs.
- Named limits/enum cho FE/BE; wire values và authority boundaries không đổi.
- Tom’s parser v2: explicit header/column, same-model conflict không publish số đo;
  missing binding fallback content. Reader→ledger→finalizer regression verified.

## Verification

AI gate2026-10-14:738 core +105 native PostgreSQL; Ruff/mypy175/lock/diff pass.
RED6 parser failures → GREEN9; curated slice35/native runtime5 pass. Native attachment
→ ordinary follow-up preserves one conversation/history. Fixtures, không live LLM/catalog.
FE post-merge gate2026-10-14:135 tests/typecheck/lint/API check; Webpack build66 pages pass.
Browser mocked API: 2 turns + proposal confirmation, no page error; không live LLM.
ISSUE-120 fixed: bỏ root redirect page
trùng proxy; giữ locale root layout. HTTP root307→vi, vi/en200 đúng html lang.
Default Turbopack worker port lỗi vẫn ISSUE-122; build script/CI unchanged.
Backend:148 catalog/common-lib tests +compose pass; CLI release unset/source25/target25
do local JDK default release25 lỗi (ISSUE-124), không sửa pom hoặc claim full reactor.

## Làm tiếp

1. Live identity/catalog/model gate khi owner cấu hình; hiện chỉ source/fixtures.
2. ISSUE-121/074/096/097 resolved; audit refreshed old tracker wording.
   ISSUE-122: kiểm chứng default bundler tại môi trường có quyền process/socket.
   ISSUE-124: full Java25 toolchain/default compile gate.
3. FE list/history/reload, delete/retention/replay và nguồn benchmark là backlog.
   Không claim toàn bộ P2–P6 hoặc production hoàn tất.
4. ISSUE-125 resolved: documentation manual overview/first steps/concepts/guides/reference;
   historical slice evidence tách khỏi status. ISSUE-126 resolved theo quyết định lấy
   scoring hiện tại của optimizer làm baseline; chỉ đồng bộ docs, không đổi code.
   Links/coverage/examples/OpenAPI checks pass; không runtime test rerun. Inspect
   tracker để lấy trạng thái mới nhất.

## Worktree

AI6a16569 và backend e7ae822 đã push; backend pin đúng published AI. FE45068a8
giữ cả remote member changes và local V2 delivery; docs commit cùng đợt.
Parser/audit và docs refresh sau đợt push đó hiện chưa commit; backend submodule vẫn pin6a16569.
Root AGENTS/tracker nằm ngoài Git nên không có trong các pushes. Không tự copy/move.
Quyền push cho đợt cũ đã dùng; lần sau chờ yêu cầu mới. Xem git log/status khi resume.
Không ghi API key, không đổi `.env`; app DB ở0005. Inspect status trước khi làm.
