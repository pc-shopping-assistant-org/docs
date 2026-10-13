# Plan — Stateful AI Chat & Guided PC Build

Revision 27 · 2026-10-12 · Core architecture first; feature delivery is a separate backlog.
Scope: UC-AI-001/003 và PC-builder extension; AI, catalog/identity boundary, gateway, frontend.
Tiến độ/evidence: [status](stateful-implementation-status.md).
Requirement-by-requirement core audit: [audit](core-audit.md).
Issues: [tracker](../../USECASE_IMPLEMENTATION.md).

## 1. Mục tiêu

Chat tiếp qua nhiều lượt/reload/restart, giữ requirements và build.
Lỗi giữa lượt recover từ checkpoint đúng; không mất yêu cầu hoặc publish orphan result.

Thiết kế đã chốt, không định nghĩa lại trong plan:

| Contract | Tài liệu |
| --- | --- |
| Stack và boundaries | [Architecture](../02-architecture/ai-architecture.md) |
| Requirements, compiler, tools, grounding/completion | [Agent](agent-tools.md) |
| Execution, root, attempts, recovery, lineage/CAS, retention | [Context](context-management.md) |
| HTTP/SSE và tool DTOs | [Stateful API](../05-api/stateful-chat-v1.md), [tools](../05-api/tool-contracts.md) |
| Application DB và replay provenance | [Schema](../03-data/ai-stateful-schema.md) |
| Optimizer và policies | [Optimizer](pc-build-optimizer.md), [hardware](hardware-knowledge.md) |
| Frozen P0 contracts | [Baseline](stateful-chat-contracts.md) |

Ngoài V1: guest, cross-conversation memory, multi-agent, commerce mutation tools,
replay dashboard và production deployment.

## 2. Quy tắc triển khai

- Version/migrate root/readiness và canonical state cùng DTO, DB checks, API, tests.
  Không reinterpret legacy checkpoint bằng defaults mới.
- Giữ optimizer hiện có; compiler/verifier là finite typed services, không DSL framework.
- Root ai-service là canonical source; backend/ai-service là submodule.
- Mỗi slice: tracker IN PROGRESS → implement → focused tests → relevant full/static/native gates
  → ghi evidence. Chỉ COMPLETED khi toàn slice đã verify.
- Không đổi approved business rules để tránh gate khó; issue non-blocking ghi lại và tiếp tục.

Ba invariant chốt cho flexible flow (chi tiết ở [agent](agent-tools.md)):
1. Giữ conversation_revision/API expected_revision cho CAS; không thêm hai counter
   persisted accepted/working. Working state ở checkpoint, requirements_hash nhận
   diện content thay đổi. Chỉ publish validated snapshot; không gán accepted=working revision.
2. Agent chỉ propose; application quyết định merge từ explicit user evidence hoặc
   valid immutable-proposal confirmation. Không auto-merge suy luận giảm RAM/đổi GPU.
3. Validate trước END/publish: INFEASIBLE cần search/coverage proof trong scope và
   matching requirements/input/catalog/policy hashes. Heuristic/lossy pruning hoặc
   limited search không tìm được nghiệm và chưa có proof → SEARCH_INCOMPLETE.
   Tìm được build qua verifier vẫn FEASIBLE, không guarantee optimality.
Confirmation bind proposal_id/hash, target-state revision và base_requirements_hash;
“OK” chỉ xác nhận immutable pending payload. Target revision thuộc snapshot công bố
proposal; không lấy nhầm run base trước CAS clarification. Nội dung đổi → proposal mới.
Giữ flow/P4; không thêm framework hoặc mở rộng mutation authority.

## 3. Phases và delivery

### 3.1. Phases

| Phase | Batch | Deliverable |
| --- | --- | --- |
| P0 | B0 | Frozen specification/contracts |
| P1 | B2 core | Pure multi-turn merge và markers |
| P2 | B1 | DB/auth/saver, root readiness và owner-scoped reads |
| P3 | B2 extraction + B3 | Requirement pipeline, bounded ReAct, verified build/answer |
| P4 | B4 | Durable admission/executor/attempts, native recovery và publication |
| P5 | B5 | APIs/events/SSE/frontend, retention/delete |
| P6 | B6 | Cross-phase core audit và internal replay |

P0/P1 completed baseline; P2–P6 in progress; P6 core audit started.
Chi tiết source và verification chỉ ở status, không lặp test counts trong plan.

**Ưu tiên thực hiện: core architecture**, không chờ toàn bộ feature delivery.
Giữ IDs P0–P6 để trace công việc cũ, không tạo thêm phase/counter tiến độ.

| Track | Phạm vi |
| --- | --- |
| Core architecture — làm trước | Minimum P2 persistence/auth/owner boundary; P3-F01–F04, typed tools/optimizer/verifier; P4 execution/attempts/recovery/publication; API submit/poll/history tối thiểu; P6-01 core audit |
| Feature backlog — làm sau | P5 mở rộng API, events/SSE/frontend/retention/delete; FULL_SETUP/soft scorer; thêm benchmark/source templates, older-build selectors; P6-02 replay tooling |

Core không phải production readiness/full project completion. Retention 90/7 ngày,
delete/stop-drain và feature acceptance vẫn là requirements giữ trong backlog;
không enable/claim các chức năng đó trước runtime verification. Code đã có giữ lại.

### 3.2. Test strategy

Core dùng scripted model, canonical fixtures và optimizer thật.
Native PostgreSQL dùng saver thực cho accepted/orphan/root/restart/claim/lineage/CAS.
Live provider/browser smoke là evidence riêng, không thay core test.
Không dùng MemorySaver/SQLite/unit count để chứng minh durable runtime.

### 3.3. Dependency

```text
P2 root/readiness → P4-A execution/attempt authority
                 → P3-A requirements/adapters
                 → P3-B ReAct + verified outcomes
                 → P4-B recovery/publication
                 → minimum submit/poll/history → P6-01 core audit

Core ổn → feature backlog: P5 delivery/cleanup, domain extensions, replay
```

Pure P3 core có thể làm trước P4-A. External customer execution chỉ enable sau P4-A.
P2 initializer dùng minimal exclusive claim/stop/CAS; P4 reuse cùng admission boundary.

### 3.4. Delivery checklist còn lại — thứ tự triển khai

Ưu tiên P3-F01 → F02 → F03 → F04 dưới đây để migrate flow tuyến tính hiện tại.
Reuse resolver/atomic merge/compiler/optimizer và execution guards; không rewrite
foundation, thêm runtime agent, DSL hoặc tự mở commerce mutation scope.

| ID | Deliverable | Dependency | Gate để đóng |
| --- | --- | --- | --- |
| P2-01 | Versioned conversation readiness/head contract + migration | Native root experiment đã pass | READY revision-zero có exact terminal root; INITIALIZING không submit; legacy không bị reinterpret |
| P2-02 | Exclusive initialization, root lookup/reconciliation và CAS READY | P2-01 + admission guards | Concurrent initializer, crash-before/after-CAS, restart; root không gọi LLM/tool và không tạo message/revision |
| P2-03 | Owner-scoped create/get/list với readiness và exact accepted projection | P2-02 | Wrong owner/JWT reject; initializing state không giả empty accepted state; opt-in startup fail closed |
| P4-A01 | Durable submit/idempotency/revision/busy transaction | P2 ready head | Same request/body reuse trước revision check; changed body 409; hai submit chỉ một active slot |
| P4-A02 | SQL claim/heartbeat/cancel/stop ACK nối managed executor | P4-A01 | Một execution/conversation; status/TTL không release; shutdown drain cả claim vừa commit |
| P4-A03 | Reserve từng MODEL/TOOL_IO attempt, retries disabled/instrumented | P4-A02 | Không reservation → không outbound; crash RESERVED/UNKNOWN vẫn consumed; retry/restart không reset cap |
| P3-A01 | Provider wire draft → canonical requirements + source-bound task drafts | P4-A03 cho runtime | Absent/SET/CLEAR, refusal/truncation/malformed; không đoán UUID/confirmation hoặc downgrade task |
| P3-A02 | Canonical product/variant/unit resolver và component snapshots | P3-A01 | ACTIVE/visibility recheck; product khác variant; ambiguous/unknown giữ pending; specs thiếu không bịa |
| P3-A03 | Atomic canonical merge + targeted clarification continuation | P3-A02 | Một operation sai không apply phần còn lại; IDs/pending choices đúng revision/source; reset không tự xóa state |
| P3-A04 | Feature backlog: supported soft scorer và FULL_SETUP projection | P3-A03 | Core giữ finite capability mapping/unsupported explicit; feature gate mới đòi supported soft scoring và complete setup snapshots, không tự chia budget |
| P3-F01 | IN PROGRESS: versioned actions/hash/confirmation + V2 request/answer/task DTO | P3-A01 + existing typed tools | Opt-in HTTP/public DTO/factory và free-text/amendment/actions đã pass; còn complete runtime audit. Không thêm persisted counters |
| P3-B01 | IN PROGRESS: native V2 adapter + opt-in flexible runtime | P4-A03 + P3-F01 | One-call/structured repair/Gemini signature và lifespan/API/SQL integration pass; còn live provider gate |
| P3-F02 | IN PROGRESS: flexible graph + choices/pending edits/actions | P3-F01 + P3-B01 + P3-A02/A03 | Choices/edits/actions và explicit-user extraction/receipt/native replay/managed publication verified. Ambiguous/inferred changes remain consent-bound. Còn cross-phase audit và live semantic quality gate |
| P3-F03 | IN PROGRESS: post-read clarification + typed data/search outcomes | P3-F02 | Scoped search, UNKNOWN/CONFLICT, MULTI_TASK grounding/native resume/managed publication và indexed bounded repair verified. Còn cross-phase audit/live provider; benchmark facts thuộc source backlog |
| P3-F04 | IN PROGRESS: native/head + V2 preparation/selection + opt-in managed publication | P3-F03 + P4-A01–A03 | Managed read/choices/confirm/build/saved-explain, pending edits/actions, stopped recovery và factory/HTTP pass; còn process-death authority, legacy migration policy và final audit |
| P3-B02 | Flexible ReAct với trusted requested tasks và verified outcomes | P3-F01–F04 | Explore → ask → confirmed proposal → build → explain hoàn chỉnh; không mandatory extract/resolve/merge prefix; model không downgrade task; grounded facts và typed negative outcomes |
| P3-W01 | Web Research pipeline 2-phase: discovery & deep read (IMPLEMENTED) | P3-B01 | search_web + read_web_page (Trafilatura markdown/tables), web:hash citation, web-answer không override catalog/build |
| P3-W02 | Feature backlog: thêm curated facts/benchmark sources (IN PROGRESS) | P3-W01 | Giữ ASUS dimensions đã có; benchmark/source expansion làm sau. Core vẫn phải giữ CONTENT_ONLY/UNKNOWN boundaries và typed insufficient-evidence outcome; không fake benchmark facts |
| P3-B03 | IN PROGRESS: actual optimizer trace + scoped report/terminal presenter | P3-B02 | Trace, stale-policy/input rejection, scoped final validation và PostgreSQL reopen reuse pass. Còn selected-runtime/publication integration; proof không mở rộng ra whole catalog |
| P3-B04 | Stage hashes/status markers, provenance capture, bounded context/state | P3-B03 | Optimize committed/explain fail không rerun; changed input/version invalidates; full coverage và bounded state |
| P4-B01 | IN PROGRESS: selected V2 recovery/cleanup + stopped-source reconciliation | P4-A02 + P3-B04 | API/executor timeout→resume→publish, proof-bound cleanup và missing/stale cursor reconciliation pass; same-execution fork reject. Còn multi-retry source advancement/process-death reconciliation. Mất heartbeat không takeover |
| P4-B02 | Native ancestry/input-boundary/version validator | P4-B01 | Same-thread sibling/debug/orphan/missing ancestor/pending task reject; accepted root/current run lineage đúng |
| P4-B03 | Fenced atomic accepted head/revision/message/run/result publication | P4-B02 | Hai finalizer publish một lần; same result retry reuse; crash-before/after-commit không duplicate/recompute |
| P5-01 | Feature backlog: list/cancel và API UX mở rộng | P4-B03 | Submit/poll/history + ownership/idempotency/exact accepted reads là core gate; list/cancel expansion có acceptance riêng. Internal cancellation/stop safety vẫn thuộc P4 |
| P5-02 | Feature backlog: persisted event journal + SSE reconnect | P5-01 | Disconnect không cancel; completion sau CAS; authorized offsets; không chặn core verification qua polling |
| P5-03 | Feature backlog: req/res/models/mappers và stateful frontend | P5-02 | Account/cache/history/reload/build/clarification UX có browser gates riêng; chưa cần UI để đóng core architecture |
| P5-04 | Feature backlog: stop/drain deletion và retention jobs | P4-B03 + P5-02 | Giữ 90/7-day policy; protected lineage/evidence; không enable delete/retention khi chưa test, không chặn dev core milestone |
| P6-01 | Core acceptance audit: scripted model + real optimizer/PostgreSQL/API | P2 minimum + P3 core + P4 + minimum API | Flexible normal/negative flows, native reopen/resume, hashes/confirmation/scope proof/stop/CAS; full/static/lock/migration gates; không phụ thuộc P5 feature backlog |
| P6-02 | Feature backlog: snapshot-only deterministic replay và full requirement audit | P6-01 | Replay không live fallback/publish; full audit vẫn tính deferred features, không gọi core completion là toàn project xong |

P3-A03 progress: persisted typed/free-text SKU and comparison product choices are
verified, including native saver reopen, unchanged merged budget and reuse of a
checkpointed choice after catalog failure. Typed/free-text unit confirmations also
retain the original draft, bind both sources and survive PostgreSQL saver reopen.
Requirement amount/SKU amendment and removal of individual unmerged items are also
verified, with per-item sources and checkpoint reuse. Comparison mention corrections
also retain the original task and unaffected bindings, with native lookup/resume gates.
Whole-pending discard/replacement is verified. Full phase
status/evidence stays in [status](stateful-implementation-status.md).

### 3.5. Contract migration gates

| Extension | Gate |
| --- | --- |
| Initial root/readiness | P2-01/02: exclusive initialize, crash/concurrency/CAS, explicit legacy policy |
| Canonical requirements/tasks | P3-A01/03/B02: schema version, source-bound atomic merge, không task downgrade |
| Flexible actions/proposals/outcomes | P3-F01–F04: legacy schema policy, immutable confirmation binding, content-hash-aware ledger projection; old INFEASIBLE thiếu proof không upgrade ngầm; adapters cùng version; preserve stop/accepted-head guards |
| FULL_SETUP/soft registry | P3-A04/B03: supported scorer/mapping, complete snapshots, không tự chia budget |
| Attempts/context/storage | P4-A03/P3-B04: every outbound reserved, bounded 100-turn fixture |

### 3.6. Definition of done

**Core architecture done** khi verify được:

- Một native LangGraph/thread qua managed executor, owner-scoped submit/poll/history;
  claim/idempotency, durable attempts và stop/accepted-head/CAS hoạt động.
- Read exploration → validated/confirmed proposal → merge theo content hash → optimizer/
  verifier → grounded answer hoặc đúng scoped negative/clarification outcome.
- Scripted model + real optimizer/PostgreSQL chứng minh restart/resume, stale inputs,
  confirmation mismatch và accepted state không đổi khi fail/cancel/CAS conflict.
- Relevant full/static/lock/migration gates pass; remaining features được ghi riêng.

Live provider/catalog smoke vẫn là integration evidence riêng: fixtures không chứng
minh live services hoạt động. Feature backlog không bị chuyển thành COMPLETED chỉ
vì core done; retention/SSE/UI/replay có DoD riêng trước external feature rollout.

Acceptance ở [agent](agent-tools.md#9-core-acceptance) và
[context](context-management.md#core-acceptance); API/DB gates theo contracts tương ứng.

Mỗi slice phải có command, environment/date, observed result và giới hạn verification.
Owner-reported PASS không đổi thành agent-run evidence.
Final audit so tracker với UC/spec, review required issues; blocked functionality không được claim 100%.

Commands từ ai-service:

```bash
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q integration_tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run ruff check src tests integration_tests migrations
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run mypy src
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv lock --check
```

Migration/bootstrap theo [README](../../ai-service/README.md) trên local ai_db;
không reset volume/hand-edit saver tables. FE dùng scripts của web-frontend và verify
reload/reconnect flow. Source docs edit không tự resume implementation hoặc authorize commit/push.

## 4. Open gates

| Issues | Việc còn thiếu |
| --- | --- |
| ISSUE-092 | Main root/readiness/CAS implemented; reconciliation/legacy deferred |
| ISSUE-093/097 | Extraction authority, pending confirmation và completion |
| ISSUE-096/099 | Canonical metadata, supported requirements, soft/FULL_SETUP |
| ISSUE-085/087 | Accessory selection policy và historical setup snapshot |
| ISSUE-094/095 | SQL main path done; production executor/provider wiring, version validation; recovery deferred |
| ISSUE-098 | State bounds, event journal, retention/delete/replay |
| ISSUE-100 | Full verification và native provider/runtime adapters |

Next: P3-F01 contracts → F02 flexible graph → F03 outcomes/repair → F04 native gates.
Current SQL admission → managed graph → atomic publish đã verified với PostgreSQL
và fixture catalog; không dùng evidence này để claim flexible flow đã implemented.
P2 main initializer đã verified; không mở rộng rare recovery trước main chat flow.
Không thay phase completion chỉ vì contract hoặc native experiment đã pass.
