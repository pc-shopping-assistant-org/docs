# Resume checkpoint — 2026-10-14

## Đọc trước

Root `AGENTS.md` → [status](stateful-implementation-status.md) →
[plan](stateful-chat-implementation-plan.md), chỉ phase đang làm.

## Đã làm

- FE chat/attachments/immutable confirmation dùng V2; không legacy fallback.
- Basic SSE: 1 admission + 1 subscription/run; no Last-Event-ID/reconnect/retry.
  Disconnect không cancel executor. DELTA là final validated text, không model tokens.
- Journal/lifecycle0004–0005: owner-scoped, dedup/sequence; completion atomic cùng CAS.
- Published context: tối đa4 cặp/12k chars, owner/revision scoped; freeze khi recovery.
  Task registration và agent cùng nhận history, không dùng nó làm current facts.
- Hardware snapshot lazy ở build/resolve; read-only không preload.
- Numerical facts server-rendered; qualitative explanation cần selected evidence refs.
- Named limits/enum cho FE/BE; wire values và authority boundaries không đổi.

## Verification

AI gate2026-10-13:729 core +105 native PostgreSQL; Ruff/mypy175/lock, không rerun ở FE slice.
FE post-merge gate2026-10-14:135 tests/typecheck/lint/API check; Webpack build66 pages pass.
Browser mocked API: 2 turns + proposal confirmation, no page error; không live LLM.
ISSUE-120 fixed: bỏ root redirect page
trùng proxy; giữ locale root layout. HTTP root307→vi, vi/en200 đúng html lang.
Default Turbopack worker port lỗi vẫn ISSUE-122; build script/CI unchanged.
Backend:148 catalog/common-lib tests +compose pass; CLI release unset/source25/target25
do local JDK default release25 lỗi (ISSUE-124), không sửa pom hoặc claim full reactor.

## Làm tiếp

1. Live identity/catalog/model gate khi owner cấu hình; hiện chỉ source/fixtures.
2. ISSUE-121: Tom's parser cần model-header validation + conflicting dimensions.
   ISSUE-122: kiểm chứng default bundler tại môi trường có quyền process/socket.
   ISSUE-124: full Java25 toolchain/default compile gate.
3. FE list/history/reload, delete/retention/replay và nguồn benchmark là backlog.
   Không claim toàn bộ P2–P6 hoặc production hoàn tất.

## Worktree

AI6a16569 và backend e7ae822 đã push; backend pin đúng published AI. FE45068a8
giữ cả remote member changes và local V2 delivery; docs commit cùng đợt.
Root AGENTS/tracker nằm ngoài Git nên không có trong các pushes. Không tự copy/move.
Owner chỉ cho phép push đợt này; lần sau chờ yêu cầu mới. Xem git log/status khi resume.
Không ghi API key, không đổi `.env`; app DB ở0005. Inspect status trước khi làm.
