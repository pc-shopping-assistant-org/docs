# ADR-005 — Stateful bounded ReAct with LangGraph and Pydantic

Status: ACCEPTED. Updated 2026-10-14: flexible V2/core runtime implemented;
live integration và feature backlog vẫn mở. [Evidence](../../04-ai/core-audit.md).
Flexible action loop supersedes the mandatory requirement prefix trong V2.
Supersedes: [ADR-003 PydanticAI](ADR-003-pydantic-ai.md).
Scope: UC-AI-001/003 và PC build qua V2. Updated 2026-10-15: V2 is the only server
runtime; V1/guided selection and stateless chat endpoints are retired. Versioned
shared DTOs/DDL and historical test fixtures are not runtime fallbacks.

## Context

Cần multi-turn state/recovery, canonical catalog grounding và deterministic PC
optimization. Một orchestration runtime đủ; model wrapper không nên sở hữu history/
retry/tool loop riêng. Per-run threads/copy-values recovery mất native semantics.
Generic final advice có thể đúng facts nhưng chưa hoàn thành build request.

## Decision

1. LangGraph điều phối typed nodes và một bounded ReAct loop; Pydantic validate
   contracts; direct LangChain model adapters gọi OpenAI/Gemini. Bỏ PydanticAI.
2. Stable conversation_id = thread_id; nhiều runs/checkpoints. Application accepted
   head tách latest. Native checkpoints giữ lineage/next/tasks/pending writes.
3. Agent có thể khám phá bằng read tools trước khi requirements đầy đủ. Requirement
   proposal → reference/unit/source resolver → validated/confirmed atomic working
   merge là một nhánh trong loop, không mandatory prefix. Explicit user intent mới
   được auto-merge; agent-origin changes cần confirmation. Compiler versioned →
   existing deterministic optimizer → independent verifier; không DSL/optimizer mới.
   Accepted snapshot bất biến; working state ở native checkpoints. Giữ conversation
   revision cho CAS, requirements_hash cho content identity; không thêm accepted/
   working persisted counters. Application approve merge bằng evidence hoặc confirmation
   bind immutable proposal_id/hash/target-state revision/base_requirements_hash.
4. Sáu tools: search_catalog, get_product_details, compare_products, build_pc,
   search_web, read_web_page. Bốn action: CALL_TOOL, PROPOSE_REQUIREMENTS,
   ASK_CLARIFICATION, FINAL_ANSWER; model không có mutation authority.
   State-aware exposure, no hard intent router; tối đa một tool call mỗi model response.
   tool_results là canonical truth, transcript là projection.
5. Application sở hữu ownership/idempotency/revision/exclusive admission/call budget/
   completion/publication. LLM không cấp principal, locks, trusted source hay prices.
6. Lifecycle-managed executor độc lập HTTP/SSE. Status/lease expiry không release
   thread; verified stop/drain evidence mới cho execution tiếp theo.
7. Native lineage + terminal markers + fencing/CAS bảo vệ accepted publication.
   Durable reserve từng outbound attempt; không hứa provider exactly-once/billing cap.
8. Facts server render từ typed evidence; grounded answer phải đủ original tasks.
   Không detector/Pydantic guarantee factuality của mọi free prose.
   Typed insufficient-evidence/dependency outcomes không giả task completion;
   structured repair feedback hướng dẫn sửa lỗi. Requirements hash đổi invalidate dependent
   results, không xóa/relabel ledger lịch sử.
   INFEASIBLE cần typed optimizer proof trong declared scope, matching working/input
   hashes và đủ coverage/sound search. SEARCH_INCOMPLETE dành cho no-result nhưng
   chưa có proof; model prose, heuristic failure hoặc backend error không là proof.
9. V1 login-only, conversation-local memory; retention 90 ngày, orphan/debug 7 ngày.
   Debug/replay internal-only không publish; deletion stop/drain rồi purge.

## Consequences

Một runtime dễ trace; domain/optimizer không phụ thuộc graph/provider. Native
persistence không thay application transactions hoặc stale-worker control.
Requires real PostgreSQL gates, bounded state/context và versioned schema/provenance.

Initial accepted root/readiness đã implemented với synchronous initialization và
native recovery gates. ISSUE-092 còn automatic reconciliation/legacy migration.
ADR giữ rationale, không thay runtime evidence hoặc tuyên bố toàn plan hoàn tất.

Canonical documents: [architecture](../ai-architecture.md),
[ReAct](../../04-ai/agent-tools.md), [state](../../04-ai/context-management.md),
[contracts](../../05-api/tool-contracts.md), [delivery plan](../../04-ai/stateful-chat-implementation-plan.md).
