# Agent và tools

Cập nhật 2026-10-13. Flexible ReAct V2 có runtime opt-in; mặc định vẫn V1 với
prefix extract → resolve → merge. Tiến độ/gates: [status](stateful-implementation-status.md).
Schema tool: [tool contracts](../05-api/tool-contracts.md).
Execution/recovery: [context](context-management.md).

## 1. Flow

```text
Load accepted state + register requested tasks → Agent
                     ┌────────────────────────────┤
                     │                            │
                     ↓                            ↓
             CALL_TOOL                    PROPOSE_REQUIREMENTS
             Policy → Dispatch            Resolve → Validate/confirm
                     ↓                            ↓
                  Observe ←──────────── Atomic working-state merge
                     │                            │
                     └────────→ Agent ←───────────┘

Agent → ASK_CLARIFICATION → validate/persist pending → WAITING_INPUT
Agent → FINAL_ANSWER → grounding/completion per registered task → prepare publish
```

ReAct là bounded tool-calling trong một LangGraph, không có agent runtime thứ hai.
Graph điều phối; application kiểm soát quyền, state và publish; optimizer quyết định build.
Không lưu hoặc gửi hidden reasoning ra frontend.

Không bắt mọi turn resolve/merge requirements trước khi đọc dữ liệu. Application
đăng ký requested tasks từ source-bound proposals; chưa bind đủ subjects không
chặn read tools, nhưng không được công nhận completion. Model không hạ BUILD/COMPARE
thành ANSWER. Read tools được dùng để khám phá trước khi user chốt cấu hình.

## 2. Tool policy

V1 có 6 tools:

- Nội bộ (Catalog / Optimizer): `search_catalog`, `get_product_details`, `compare_products`, `build_pc`.
- Nghiên cứu web (External Web Research): `search_web`, `read_web_page`.
  `build_pc` xử lý cả tạo mới và điều chỉnh; không có `adjust_build`.

`tool_policy.resolve(phase, consultation, current_build, principal)` trả subset
được phép ở mỗi vòng. Dispatcher kiểm tra lại ngay trước execution.

| Điều kiện                                       | Hành vi                               |
| ----------------------------------------------- | ------------------------------------- |
| Thiếu budget/use case hoặc binding chưa resolve | Ẩn build_pc; hỏi đúng thông tin thiếu |
| Chưa có build cũ nhưng prerequisites đủ         | Cho phép build_pc                     |
| Cancelled, hết deadline hoặc thiếu quyền        | Không execute tool                    |
| Tool schema cũ không còn hợp lệ với state       | Reject; không gọi handler             |

Read tools không bị intent routing cứng. Exposure không thay authorization.
V1 không có tool mutation cart/payment, shell, browser hay long-term memory.

### 2.1. Web research tools (V1 IMPLEMENTED)

Pipeline 2-phase cho tra cứu phần cứng bên ngoài:

1. `search_web(query, limit)`: Tìm kiếm danh sách nguồn (trả về URL, title, snippet; snippet có thể rỗng). Snippet search chỉ dùng để agent chọn nguồn, **không sinh citation evidence**.
2. `read_web_page(url)`: Tải HTML và trích xuất nội dung bài viết + bảng dữ liệu qua `trafilatura` (kèm cờ `include_tables=True`). Trả về `status` (`READABLE | UNREADABLE | EMPTY`), `final_url`, `content_hash` và `evidence_ref = web:{hash(final_url, content_hash)}` khi `READABLE`. Khi không đọc được, `content: null`. Hai nguồn có content giống nhau vẫn có ref khác nhau.
3. **Query Presets**: 8 nhóm nghiệp vụ cũ (reviews, FPS benchmark, game requirements, PSU tier, hardware issues, compatibility, vendor specs, drivers) được chuẩn hóa thành static helpers `WebSearchPresets`, dùng chung pipeline 2 tool trên.
4. **Server-rendered citations**: Server tự động render danh sách link nguồn từ `ReadWebPageResult` trong ledger:
   ```markdown
   Nguồn tham khảo:

   - [{title}]({final_url})
   ```
   Model không được tự bịa URL. Bằng chứng web chỉ dùng để trả lời / tư vấn, **không thỏa mãn task BUILD hoặc COMPARE** và không tự ý ghi đè catalog.

Content-only answer yêu cầu `web_excerpts[{evidence_ref, quote}]`: quote phải là đoạn
liên tục khớp chính xác selected page segment. Server render trích dẫn và ghi rõ
chưa xác thực thông số/điều kiện đo; không xuất bản free-form `text` của model.
Citation link do server render. Khi chọn cả catalog/build và web evidence, giữ canonical
catalog/build output, thêm exact quotes có nhãn chưa xác thực và citation;
không append prose tự do của model.
Search/read trong ReAct reserve TOOL_IO trước dispatch; model calls reserve MODEL.
Exact quote chỉ chứng minh nội dung có trong nguồn, không chứng minh đúng model,
đủ điều kiện đo hoặc đáp ứng câu hỏi. Structured facts dùng `fact:` refs riêng,
server render typed values/status và link nguồn. Benchmark synthesis vẫn TODO;
dimension parser ở mục 2.2 không đóng toàn bộ web research.

DuckDuckGo parser đọc organic title/URL/snippet theo cấu trúc HTML, bỏ advertising
click-through và decode redirect một lần. Chỉ trang có marker no-results mới trả
empty success. Challenge, layout không nhận diện hoặc HTTP lỗi trả
`FAILED / WEB_SEARCH_UNAVAILABLE` cho ReAct; không giả thành không có nguồn.

`read_web_page(url, offset=0, max_chars=12000)` trả tối đa 16000 ký tự mỗi
đoạn. `next_offset` cho phép đọc tiếp; `total_chars` là độ dài nội dung extractor.
Offset tính bằng ký tự Python, không phải byte. Offset ngoài nội dung bị reject.
`content_hash` giữ hash toàn bài ở lần fetch; `evidence_ref` của tool định danh
source + offset + đoạn thực sự trả về. Không xem phần chưa đọc là evidence.
Mỗi lần đọc tiếp fetch lại trang và reserve TOOL_IO; hash có thể đổi nếu nguồn đổi.
Đây chưa phải immutable page cache. Curated parser đọc DOM toàn trang và chỉ expose
các facts thực sự trích xuất; facts không bị giới hạn bởi offset của text segment.

Native model adapter: `infrastructure/providers/react_model.py` dùng providers
OpenAI/Gemini hiện có. Chỉ bind allowed tool schemas của lượt hiện tại; native
AIMessage/ToolMessage được dựng từ canonical ToolRecord, không có history riêng.
Gemini thought signature được giữ như opaque provider_signature trên call để
serialize/reopen không mất protocol context; không nằm trong tool arguments.
Malformed output vào bounded repair; multiple calls bị reject toàn response bởi graph.
Adapter unit/SDK binding and managed runtime composition verified with native SQL
and model fixtures; live provider/agent execution not verified. Live ASUS reader
is verified separately; it does not prove live LLM source selection.

`NativeRequirementExtractor` gọi structured Draft qua MODEL reservation; absent
giữ nguyên, SET/CLEAR tham chiếu existing IDs, nguồn dùng character spans.
Malformed/refusal không được đổi thành empty patch. Resolver kiểm tra source/unit,
compiler quyết định supported constraints; extractor không sinh canonical SKU UUID.

`BackendProductCatalog` dùng DTO catalog-service hiện tại: summary có minPrice/
maxPrice, detail có specifications + variants.price. Range không thành exact price;
detail chỉ trả exact price khi các ACTIVE variants có cùng giá. ProductEvidence
luôn dùng product ID, không dùng nhầm variant ID. Mỗi HTTP request reserve TOOL_IO;
404 detail trả absent, error envelope/malformed data báo unavailable.
Adapter này phục vụ read tools, không thay hardware candidate snapshot adapter.

Comparison ambiguity persists original tasks/source/revision and canonical product
bindings in `pending_tasks`; public options use product IDs, not SKU IDs.
Typed task replies validate offered choices then recheck canonical catalog.
Previously resolved subjects keep their identity; disappearance asks again.
Original task/completion IDs reach model context on continuation. No reply keeps
pending, not a new ANSWER. Free-text task choices use a budgeted TaskChoiceDraft
with exact source evidence, then the same typed validation/canonical lookup path.
The dedicated choose_task checkpoint precedes lookup; resume reuses a committed
choice. Empty/unclear choices remain pending. Unit/mention amendment stays open.
Contract: [task continuation](../05-api/stateful-chat-v1.md#producttask-clarification-continuation).

`BackendRequirementCatalog` phục vụ optimizer: quét đủ cursor pages trong giới hạn
100 canonical variants/20 pages, không dùng keyword/top-k để chứng minh SKU duy nhất.
Vượt giới hạn hoặc hết call budget là lỗi rõ, không trả một catalog bị cắt rồi báo
INFEASIBLE. Dùng [snapshot page](../05-api/catalog-snapshot.md), một TOOL_IO/page;
không còn list + detail HTTP từng product. Specs/variants bắt buộc trong DTO;
summary-shaped response bị reject, không trở thành catalog rỗng. Backend assemble
associations theo batch trong page transaction. Run cap 16 calls vẫn giữ nguyên.

`HardwareCatalogMapping` là cấu hình nội bộ versioned:

- `categories`: exact category UUID → một trong tám ComponentCategory; không đoán
  từ tên và không tự kế thừa category con. Mọi leaf category cần được khai báo.
- `spec_fields`: canonical field → product attribute key; không khai báo alias thì
  chỉ nhận đúng canonical key. Giá/ID/tồn kho luôn từ variant, không từ specs.
- `option_fields`: exact option UUID → canonical field; null chỉ cho option cosmetic.
  Option chưa mapping hoặc hai options ghi cùng field bị reject. Giá trị option
  đọc như JSON scalar/list hoặc text, sau đó strict-validate; `32GB` không tự thành 32.

Product specs là common metadata; mapped variant options override đúng field.
Giữ ACTIVE variants kể cả stock=0 cho owned-resource validation; compiler quyết
định purchasable stock. Thiếu metadata không thêm performance/physical defaults.
Evidence hash gắn product/variant snapshot và mapping version/payload. Adapter đã
có fixture proof tới optimizer/verifier, chưa có mapping taxonomy thật/live catalog
hoặc live catalog. Guided/ReAct graph factories use this adapter; không nhận
config mapping từ model/user HTTP.

### 2.2. Curated Fact Extraction (IN PROGRESS)

Đã có một template: `www.asus.com/motherboards-components/graphics-cards/*/*/techspec/`,
dimensions mm. Parser kiểm tra canonical URL, title/model và DOM `rowTableTitle` /
`rowTableItemViewBox`; không match thì fallback. Golden fixture là DOM rút gọn từ
[ASUS techspec](https://www.asus.com/motherboards-components/graphics-cards/tuf-gaming/tuf-rtx5070ti-o16g-gaming/techspec/).

Fact V1 chứa model, `attribute=dimensions`, tuple ba số, unit, fact_status, source_url,
hash decoded HTML, parser_version, locator và quote. `fact:` ref hash toàn DTO;
đổi value/source thì identity validation fail. Tuple giữ thứ tự hãng công bố,
không suy ra axis/fit/compatibility. UNKNOWN/CONFLICT không có publishable value.
Ledger/checkpoint giữ fact; presenter không xuất prose tự do. Native PostgreSQL
reopen/resume sau explanation failure không fetch lại committed tool result.
Benchmark conditions/parsers và query-relevance quality gate vẫn chưa triển khai.

#### A. Phân tách trạng thái 2 lớp (Orthogonal Status)

- **Cấp độ trang (`extraction_status`)**:
  - `STRUCTURED`: Khớp curated template và bóc tách thành công danh sách facts có cấu trúc.
  - `CONTENT_ONLY`: Curated parser không khớp layout hoặc site ngoài danh sách, nhưng fallback đọc được text/tables thô qua Trafilatura. Trả về `facts: []`.
  - `FAILED`: Cả curated parser lẫn fallback đều không đọc được (lỗi mạng, HTTP 4xx/5xx, captcha, trang rỗng hoàn toàn).
- **Cấp độ từng fact (`fact_status`)**:
  - `SUPPORTED`: Khớp pattern, đủ ngữ cảnh đo đạc cần thiết và có đoạn/bảng nguồn đối chiếu rõ ràng.
  - `UNKNOWN`: Thiếu ngữ cảnh đo đạc cần thiết hoặc bài viết không nhắc tới thông số của model cần tìm.
  - `CONFLICT`: Dữ liệu tự mâu thuẫn trong **cùng ngữ cảnh / cùng điều kiện đo**.

#### B. Quy tắc điều kiện đo (Conditions)

- **Dynamic Benchmark (FPS, nhiệt độ, dBA, điện năng)**: Bắt buộc có điều kiện đo tương ứng:
  - FPS: Game, resolution (1080p/1440p/4K), graphic preset, upscaling (Native / DLSS / FSR / FrameGen).
  - Nhiệt độ (°C), độ ồn (dBA), điện năng tiêu thụ (W): Workload test (Full load FurMark, Cinebench, Gaming, Idle...) và điều kiện môi trường/testbed tương ứng.
  - _Lưu ý_: Khác điều kiện đo so với câu hỏi **không phải là `CONFLICT`**, mà là kết quả không phù hợp câu hỏi.
- **Static Physical Specs (Chiều dài VGA mm, chiều cao tản nhiệt mm, số khe RAM)**: Chỉ cần đúng `model`, `giá trị` và `đơn vị`.

#### C. Fallback và ranh giới nguồn tin

- Nhánh Trafilatura (`CONTENT_ONLY`) chỉ cung cấp content và metadata nguồn để model tóm tắt/dẫn lời, **tuyệt đối không tự tạo structured fact**.
- Ngoài template ASUS trên, các domain review/spec chỉ là ứng viên; chưa có parser/golden fixture thì không được ghi là nguồn supported.
- Match domain/template chỉ chứng minh parser có rule đọc trang đó, không tự động chứng minh thông tin là chân lý tuyệt đối. Khi thiếu ngữ cảnh hoặc layout đổi, trả `UNKNOWN` / fallback `CONTENT_ONLY`, không đoán.

## 3. State và authority

| Channel                               | Nội dung                                                        |
| ------------------------------------- | --------------------------------------------------------------- |
| requirement_state                     | Canonical requirements sau atomic merge                         |
| consultation                          | Stage/result/history; legacy constraints là compiled projection |
| requirement_draft / resolution        | Draft chưa tin cậy, candidates và pending clarification         |
| completion_requirement                | Danh sách task do application validate                          |
| current_run_id / turn_input           | Identity/input do server cấp                                    |
| phase / selected_action               | Phase enum và tối đa một pending call                           |
| catalog_evidence / public_build       | Canonical snapshots; public_build có thể explicit null          |
| tool_results                          | Ledger current-run: typed outcome/evidence theo tool_call_id    |
| messages                              | Model-facing projection từ ledger                               |
| counters                              | Projection từ durable attempt ledger, không authority           |
| answer_candidate / publication hashes | Output chưa public; hashes do application tính                  |

### State identity — target flexible flow

- Giữ `conversation_revision` cho publication CAS/API expected_revision và run
  base_revision. Không thêm accepted_revision/working_revision persisted counters.
- `requirements_hash` là hash versioned của canonical requirements content, gồm
  stable identities và semantics/authority ảnh hưởng merge/compiler. Không dùng
  bookkeeping revision, timestamps, run IDs hoặc phase/counters làm content identity.
- Working state nằm trong native checkpoints. Merge thay content/hash, không đổi
  accepted head/snapshot. Hash/provenance của từng kết quả giữ nguyên để kiểm tra reuse.
- CAS chỉ publish validated snapshot. Publish success tăng conversation_revision;
  failure/cancel/conflict giữ accepted state/head/revision. Không gán accepted=working revision.

Ví dụ: accepted revision publication=12, requirements hash=H0. Hai merge tạo working
H1 rồi H2. CAS success publish snapshot H2 ở revision 13; fail vẫn public H0/revision 12.
Checkpoint H1/H2 tồn tại không có nghĩa đã publish. Existing requirements revision
fields là compatibility/migration concern ở P3-F01/F04; không tự xóa/đổi nghĩa DTO cũ
hoặc suy content equality chỉ từ các counter này.

Target phase phân biệt AGENT_READY, TOOL_PENDING/COMPLETED, PROPOSAL_PENDING,
RESOLVING, MERGED, CLARIFICATION_READY và READY_TO_PUBLISH; DTO enum/version chốt ở
P3-F01, không reinterpret checkpoint cũ. Phase không thay RunStatus.

Run mới reset action, ledger, answer, counters projection và publication markers;
giữ domain state. Resume không chạy reset/begin_turn.
Pydantic validate input, node output, restored state và public DTO; TypedDict/reducers
không tự bảo đảm các boundary này.

ToolResult đã durable là execution truth. Observe tạo matched ToolMessage với stable ID;
crash trước observe thì project lại, không execute lại tool đã commit.
Cùng call ID khác args bị reject. Audit/SSE journal không được sửa canonical outcome.

## 4. State và trust boundary

### Requirement contracts

```text
RequirementDraftV1
  operations, part_mentions, requested_outcome, source_evidence

CanonicalRequirementStateV1
  schema_version, constraints_revision
  goals, requirements, available_resources, resolved_bindings, unresolved

RequirementV1
  id                         # stable, server-bound
  subject                    # setup / component / workload selector
  predicate, operator        # allowlisted semantic keys
  value                      # typed quantity/unit, canonical ref hoặc enum/text
  strength                   # HARD / SOFT
  source_evidence

RequirementPatchV1
  operations                 # SET(value) / CLEAR, theo stable identity
```

Static versioned registry kiểm tra tổ hợp subject/predicate/operator/unit/value.
Không dùng arbitrary paths, regex, expressions, Any hay DSL/plugin framework.

| Patch                             | Semantics          |
| --------------------------------- | ------------------ |
| Absent                            | Giữ nguyên         |
| SET có typed value                | Thay giá trị       |
| CLEAR không value                 | Gỡ yêu cầu/binding |
| null, malformed hoặc extra fields | Reject             |

Merge atomic: một operation lỗi thì không apply phần còn lại.
Source, lock, confirmation, revision do application kiểm tra; model không tự gán
USER/SYSTEM, unlock hoặc cấp confidence làm bằng chứng.

### Resolution và clarification

```text
PartMentionV1
  mention_id, operation, binding_target, slot
  text (SET), source_message_id, source_span

PartResolutionV1
  mention_id
  status: RESOLVED / AMBIGUOUS / NOT_FOUND / METADATA_INSUFFICIENT
  candidates, resolved_variant_id?, evidence_refs
```

Resolver dùng canonical search/detail và normalized attributes; không lấy top-1
hay model confidence làm uniqueness proof. Exact pin/owned phải resolve variant/SKU,
không chỉ product. UI ref cũng phải verify identity, slot, quyền và visibility.

Unresolved mention/unit giữ toàn bộ pending draft, không partial merge. Clarification
nêu đúng field/mention và bounded candidates. Follow-up lựa chọn phải khớp pending
identity/options/revision; canonical revalidate trước merge. CLEAR không cần name lookup.
Source span chứng minh text tồn tại, không tự chứng minh intent hay confirmation.

Guided runtime SKU-choice slice: checkpoint giữ pending draft cùng source message,
constraints revision và canonical candidate IDs. Follow-up nhận typed
`clarification_reply`; application revalidate offered choice/catalog, rồi merge toàn
bộ original draft. GET trả public options từ accepted head, không trả internal draft.
Không có choice thì giữ pending, không re-extract và làm mất budget/pin.
Free-text SKU choice đã có: một structured ChoiceDraft dùng options của accepted
head, reserve MODEL, bind source span và đi qua validator typed choice/canonical
catalog. Không có choice thì giữ pending. Choose có checkpoint riêng trước resolve;
resume catalog không gọi lại choice đã commit. Không regex ordinal/agent runtime mới.
Unit confirmation đã có: draft-only UNRESOLVED_QUANTITY giữ số gốc; typed/free-text
reply bind original source và unit token ở follow-up. Server normalize tiền/TB,
merge atomic và checkpoint choice trước catalog. Xem [API](../05-api/stateful-chat-v1.md#quantity-unit-clarification).
Pending requirement edits đã có: budgeted amendment node sửa value/mention hoặc bỏ
item chưa merge, không đổi target identity. Per-item source giữ evidence của câu mới;
items/task không đổi giữ source cũ. Changed item bỏ choice/unit confirmation cũ,
resolve lại catalog và merge atomic. Node checkpoint trước IO, không re-extract cả
draft. Comparison subject edits dùng source-bound mention overrides, giữ original
task/source và bindings của subjects không đổi. Edited subject bỏ binding cũ, lookup
canonical lại; ambiguity mới vẫn đi qua public options/choice contract. Native
amendment node checkpoint trước lookup. Bỏ/thay whole draft vẫn TODO. Source span không
chứng minh model đã hiểu đúng intent; live model và quality eval chưa verify.

ExtractionEvidenceV1 giữ field path, source message/span/value, resolved candidates
và confirmation; trusted application kiểm chứng trước khi gán USER provenance.

### Requirement semantics

| Người dùng nói                   | Biểu diễn                 | Tác động                                         |
| -------------------------------- | ------------------------- | ------------------------------------------------ |
| RAM ít nhất 32GB                 | HARD capacity, GTE        | Filter kit candidates                            |
| SSD đúng 1TB                     | HARD media + capacity, EQ | Filter verified SSD drive                        |
| Ưu tiên RTX 5070 Ti              | SOFT family/model         | Ranking, không exclude GPU khác                  |
| Giữ đúng ASUS TUF RTX 5070 Ti OC | HARD exact identity       | Resolve variant, compile thành paid pin          |
| Tôi đã có linh kiện này          | Available resource        | Chưa buộc dùng; binding xác nhận mới thành owned |

Không rõ EQ/GTE, TB/TiB, tổng kit/module hoặc drive quantity thì hỏi lại.
Không giả nhiều kit/ổ bằng một SKU. Owned ngoài catalog chưa resolve được là
unsupported/unknown, không fake specs. Resolution/FPS goal không phải benchmark promise.

### Compiler và satisfaction verifier

```text
Canonical state → Versioned compiler → Optimizer input
                 → Existing optimizer → Independent verifier → Grounded explanation
```

Compiler thuần trả CompiledRequirementInputV1: state hash/revision, versions,
optimizer input và mapping cho **mọi** requirement.

| Mapping             | Xử lý                                       |
| ------------------- | ------------------------------------------- |
| APPLIED             | Dùng supported mapping                      |
| NEEDS_CLARIFICATION | Hỏi đúng ambiguity                          |
| UNSUPPORTED         | Báo rõ; giữ requirement                     |
| CONFLICT            | Báo conflict; không tự relax/pin substitute |

Hard filters chạy trước pruning và kiểm tra cả owned/pinned.
Soft preference chỉ ảnh hưởng versioned scoring; unmet phải disclose.
Scorer chưa support thì UNSUPPORTED, không nhận rồi bỏ qua.
Pin mâu thuẫn hard constraint thì conflict; không đổi pin để có nghiệm.

Verifier đọc canonical state + normalized evidence/result, không chỉ compiler output.
SatisfactionReportV1 giữ state/result hashes và per-requirement status:
SATISFIED / UNSATISFIED / UNKNOWN / NOT_EVALUABLE, strength, reason và evidence.
Goals/resources cũng phải đủ outcome/binding coverage.
Hard status khác SATISFIED chặn feasible success. Supported soft unmet không chặn,
nhưng phải hiển thị. Missing metadata/unsupported khác optimizer INFEASIBLE.

Input hash chứa semantics, units, bindings, catalog và compiler/scoring/policy versions.
Requirement đổi invalidate dependent stages; không mutate requirement để verifier pass.

### 4.7. FULL_SETUP and semantic support registry

BUILD_PC mặc định chỉ core. FULL_SETUP cộng monitor, mouse, keyboard, headset;
tối đa một/type. Owned spending=0; pinned vẫn tính tiền.
Không tự chia 80/20 hoặc chọn cheapest policy. Ngân sách/phụ kiện chưa rõ thì hỏi.

Snapshot lưu selected variants, reference price, spending, stock/time/evidence.
Historical setup đọc snapshot cũ, không ghép phụ kiện hiện tại.
Registry hữu hạn/versioned map normalize → compile → score → verify.
build_pc.objective chỉ có hiệu lực khi policy hỗ trợ, không override trusted objective.

## 5. Agent protocol và execution graph

### Flexible action contract — APPROVED / TODO (P3-F01–F04)

Runtime selection: default `AI_STATEFUL_REACT_VERSION=v1`; explicit `v2` with
ReAct enabled selects the flexible graph, V2 HTTP schema/public DTO and V2
coordinator together. Accepted V1 execution checkpoints require explicit migration;
only the matching initial native root is exempt. Version checked before outbound
catalog/model work. API details: [Stateful V2](../05-api/stateful-chat-v2.md).
Actual two-turn lifespan gate uses SQL/native saver with provider/catalog/auth fixtures;
this does not close managed recovery or live-provider acceptance.

F01 pure contracts implemented in `react/actions.py`, `react/search_evidence.py`
and `requirements/proposals.py`. `NativeFlexibleModel` parses V2 actions using shared
OpenAI/Gemini native tool history; malformed/multiple/mixed actions need repair.
Thirteen V2 protocol tests pass; graph/API wiring and live-provider proof remain open.
`requirements_hash` excludes legacy revision but includes stable IDs, values and
source/authority evidence; this is a distinct versioned hash, not a replacement of
old stage hashes by default. Confirmation revalidates immutable payload/owner/base
and returns a detached patch, never merges/publishes itself. Search DTO validates
declared metadata consistency only; actual completeness proof belongs to the
trusted optimizer adapter/F03/B03, not to Pydantic or model fields.

Optimizer trace/report đã có: `OptimizerSearchTrace` ghi enumeration kết thúc,
pool IDs, candidate removals và missing-metadata/scoring rejections. Receipt giữ
trace + policy hash; dispatcher gắn `BuildResult.search_evidence` sau independent
verifier. Report rechecks normalized input/current catalog/policy before mapping.
Scope chỉ là SUPPLIED_NORMALIZED_CANDIDATES, không phải toàn catalog backend.
No-result chỉ INFEASIBLE khi enumeration complete, không có unknown/scoring loss và
không remove candidate; có removals chưa có losslessness proof → SEARCH_INCOMPLETE.
Found verified build → FEASIBLE. Legacy receipt thiếu trace/policy hash không được
auto-certified. Internal flexible terminal rendering đã có; managed publication còn open.

Một decision có đúng một discriminated action; proposal không có quyền commit:

| Action               | Application xử lý                                                       |
| -------------------- | ----------------------------------------------------------------------- |
| CALL_TOOL            | State-aware exposure, schema/auth/limits, dispatcher, typed ledger      |
| PROPOSE_REQUIREMENTS | Source/reference/unit resolution, merge policy, confirmation khi cần    |
| ASK_CLARIFICATION    | Validate missing field/options/reason, persist pending và kết thúc lượt |
| FINAL_ANSWER         | Grounding/completion theo tasks; MULTI_TASK kiểm tra từng index và giữ partial result |

User yêu cầu rõ → patch hợp lệ có thể merge ngay. Agent tự đề xuất thay đổi mục tiêu,
budget, hard requirement, owned/pinned → cần user xác nhận immutable proposal.
Pending proposal giữ origin AGENT_PROPOSED; explicit-user merge dùng private
application receipt, không model-supplied origin flag. Confirmation bind proposal_id, proposal_hash,
target-state publication revision và base_requirements_hash;
không bịa span trong message user, không coi mọi câu “OK” là đồng ý mọi thay đổi.
Ambiguous SKU/unit/semantics hỏi lại; unsupported báo rõ, không bỏ requirement.

V1 chỉ một confirmation proposal đang chờ/conversation. Application đóng băng
normalized proposal payload và cấp identity trước khi công bố; pending proposal
và target snapshot được publish cùng CAS. Target-state revision là revision của
snapshot công bố proposal, không lấy nhầm run base trước lượt clarification.
“OK” chỉ resolve đúng proposal đang pending; confirmation phải lặp đúng ID/hash/
target revision và current requirements_hash phải khớp base_requirements_hash.
API expected_revision vẫn là current conversation CAS revision: một read-only
publication không tự đổi nội dung proposal. State content đổi, proposal bị thay/hủy
hoặc payload đổi → confirmation cũ không apply; tạo proposal mới, không mutate ID/hash cũ.

Application là nơi duy nhất quyết định ACCEPT / NEEDS_CONFIRMATION / REJECT và
thực hiện merge. Source quote khớp/Pydantic valid/model confidence không tự đủ để
coi suy luận của agent là yêu cầu user. Không có bằng chứng ý định rõ hoặc exact
confirmation hợp lệ thì không đổi requirements, kể cả thay đổi có vẻ tối ưu hơn.

F02 pure admission đã có trong `requirements/admission.py`: agent-origin patch
thay đổi content luôn tạo pending; exact confirmation mới merge và consume pending.
Không thay pending ngầm. No-op giữ bindings/hash và pending hiện tại. `content_changed`
là tín hiệu invalidate artifacts. V2 opt-in có explicit-user admission và publication
replay; không suy diễn authority từ source quote.

Explicit-user admission policy: application independently extracts
the real user message and matches the complete proposed item set, including targets,
operators/strength and source spans. Agent-authored source_text is ineligible; mismatch
or unresolved units/references cannot auto-merge. Matching resolved drafts issue a
private receipt bound to run/message/base hashes and policy version. Replay resolves
again against canonical catalog and merges a copy. SET/CLEAR preserve unmentioned
state. This is model-based semantic assessment, not deterministic proof of user intent.
V2 wires the existing budgeted extractor only when an agent proposes user-sourced
requirements, not as a mandatory prefix. Complete resolved matches update working
state; private receipt chains are checkpointed and replayed from exact accepted/
confirmed state before stop/lineage/CAS publication. Mismatch/agent text keeps the
confirmation path; ambiguous units/SKUs keep clarification/consent, never guessed
partial merge. Extraction operation keys bind input context so multiple state
revisions in a turn cannot reuse a key with a different payload.
Managed PostgreSQL verifies fresh build and stopped recovery without re-extraction
or repeated optimization; accepted state stays unchanged until publish. Pure graph
also verifies an explicit merge followed by a missing-budget question. Model/catalog
are fixtures; live semantic quality/evaluation is a separate gate.

Typed SKU continuation đã có: `PendingResolution(schema_version=2)` wraps unresolved
draft, owner/conversation, published target_revision và base_requirements_hash.
`continue_reference` validates offered item/variant and current canonical candidates,
reuses original draft/source, preserves unselected items. Resolved agent patch creates
new pending confirmation; SKU selection alone does not grant merge authority.
Internal graph handles typed `reference_reply` before model, rejects mixed confirmation/
selection, and ends WAITING_INPUT. PostgreSQL reopen gate passes. Typed/free-text
choices, pending item/subject edits and bound REPLACE/DISCARD are now supported.
Discard publishes a server acknowledgement, not task completion; requirements/build
stay unchanged and no model/tool runs. Its normal stop/lineage/CAS gate still applies.
Legacy unscoped pending shape is not silently
upgraded; graph version is now `native-flexible-react-v2-managed`, migration gate pending.

Typed unit_reply reuses confirmations_for_pending: exact source span/alias, original
amount and source/revision are checked. QuantityConfirmation retains the full user
message; proposal includes that message and both number/unit evidence spans. Partial
unit→SKU continuation preserves the same draft and confirmations across serialization.
Graph handles one typed reply kind before model and still waits for proposal consent.
V2 transport and managed SQL publication pass; live-provider evidence remains separate.

F04 native wrapper gate: DurableConversationGraph accepts an explicit supported-base
version set. Guarded V2 requires an initialized root, recognizes only revision-zero
conversation-root-v1 initialization marker/identity, and rejects unsupported/empty
base versions before model/checkpoint dispatch. Exact accepted-head invocation is
unchanged; a newer orphan is never substituted. Four memory cases and PostgreSQL
reopen pass (rejection writes no checkpoint). Existing V1 policy is unchanged when
the guard is unset; V2 factory must set it. This is not stop/lineage/CAS publication
acceptance or permission to switch a legacy conversation without migration.

Ledger freshness (ISSUE-107 fixed): application sets origin_run_id; V2 projects only
current-run, context-matching complete pairs. Older results remain history and cannot
serve current price/visibility without explicit revalidation. IDs are unique within
a run, so provider IDs can repeat in later runs. Same-run native recovery still reuses
committed outcomes; origin never comes from model arguments.
At a new managed V2 turn, prior-run ledger rows stay in immutable native checkpoint
history instead of being copied into every later working state. Same-run rows are
retained across requirement changes and native resume. No ancestor/evidence deletion;
pending state and domain memory remain intact. Default V1 is unchanged.
Graph and publication use the same projection (ISSUE-112): a same-run requirement
merge preserves old-context records but excludes them from final grounding. Fresh
results can publish without rewriting history; selecting stale refs still rejects.

Answer-publication preparation: graph/publication share validate_final_answer.
prepare_answer_publication rechecks terminal decision, current ledger and rendered
answer against an exact accepted base. Unchanged-requirements read/data-negative
responses preserve its historical public build; verified BUILT maps receipt to a
public snapshot. Confirmed-change lane re-derives state from exact accepted proposal
and stored command (ID/hash/target/base/owner), not terminal working fields. History
keeps amounts but becomes stale; known partial bindings project from compiler mapping
without a fake optimizer receipt.
Waiting preparation re-resolves a new proposal from stored request/action/catalog,
checks owner/content/next publication target and asks only actual compiler missing
fields. Typed SKU/unit continuation re-derives from accepted pending + stored reply;
it does not merge requirements or complete tasks. Eleven core cases and PostgreSQL
reopen for new resolved/unresolved artifacts pass. Confirmation-bound waiting now
shares transition binding with answer publication: confirmed requirements persist,
history becomes stale, the next question leaves tasks unresolved. Five core cases
and PostgreSQL confirm→clarify reopen pass; head revisions in that gate are fixtures,
not SQL CAS proof. Later managed SQL gates verify coordinator integration; see status.
Pure preparation does not authorize CAS or replace
stop/lineage/fencing; PostgreSQL reopen test proves revalidation without publication.

Persisted V2 projection: checkpoint channel `accepted_snapshot` contains the
validated `AcceptedConversationSnapshot.flexible` (schema 2). It stores original
task message/ID, final answer or exactly one pending artifact with unresolved tasks.
Pending content hash and BUILD task binding must match canonical requirements;
mixed V1/V2 pending fields reject. Reader requires the exact checkpoint ID and
matching conversation, never latest. `accepted_snapshot_for` encodes validated
preparation; trusted task source comes from application registration, not model
inference or a confirmation reply. With trusted `FlexiblePublicationInput`, graph
routes answer/waiting through `prepare_publish` before END and clears inherited
snapshot at begin-turn. Input binds exact accepted projection, stored request and
commands; continuation preserves original task source. Native recovery resumes
preparation without repeating committed model/tool work. Runtime factory must
supply this binding; standalone kernel without it cannot publish. Neither terminal
checkpoint nor preparation authorizes CAS.

`infrastructure/graph/flexible.py` là internal V2 loop: read trước budget, resolve
proposal, confirmation ở begin-turn, typed tool ledger và bounded structured repair.
Ledger cũ không mutate; model chỉ nhận complete pairs còn khớp context hash. Build
vẫn qua dispatcher/optimizer/verifier; legacy negative result không thành proof
INFEASIBLE. V2 opt-in đã verify managed SQL read/choices/confirmation/build,
pending edits/actions, exact accepted head/stop/CAS và stopped native recovery.
Model/catalog/auth là fixtures; không phải live-provider proof. Explicit-user
receipt replay và missing-fact/mixed-task outcomes đã verified; live semantic quality,
remaining recovery/version gates và final audit còn mở.

Merge chỉ đổi working graph state. Khi requirements_hash đổi,
compile lại và invalidate dependent optimization/build/explanation markers.
Giữ toàn bộ ledger với requirements/input/source/version hashes và publication context;
model-facing context lọc kết quả còn hợp lệ. Không relabel kết quả cũ hoặc xóa ledger để
qua validator. Catalog/read evidence chỉ reuse khi identity/visibility/freshness
vẫn hợp lệ; build theo hash cũ không thỏa task BUILD theo requirements mới.
Accepted conversation chỉ đổi sau finalization/CAS; ASK_CLARIFICATION không giữ
coroutine chờ user. Vẫn một active execution/thread và durable attempt caps.

RepairFeedback chứa code, missing/invalid fields hoặc task/evidence refs và allowed
corrective actions. Agent nhận feedback từ validator, không chỉ repair=true;
không lộ internal secrets/hidden reasoning. Repair và proposal loops đều bounded.

Model response là một action thuộc contract trên.
Mixed text+tool không được stream như final. Schema/provider failure có repair hữu hạn.

### Provider protocol

- Dùng native tool calling; không text parser/exec/dynamic discovery.
- Bind parallel_tool_calls=False nếu adapter/model hỗ trợ; vẫn validate response.
- Assemble stream chunks xong mới kiểm tra name/args/call ID.
- Multi-call/malformed response: reject toàn response, giữ last valid transcript,
  reserve attempt mới cho repair. Không append hai calls rồi chỉ trả một ToolMessage.
- Accepted call phải có matched ToolMessage từ ledger, kể cả FAILED/REJECTED.
- Trim giữ complete AI/tool pairs; không gọi model với unresolved pair.
- Provider không hỗ trợ contract thì fail capability, không fake ReAct fallback.

### Nodes

| Node                  | Trách nhiệm                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| begin_turn            | Reset ephemeral state của run mới                                              |
| register_request      | Source-bound requested tasks; không mandatory full requirement resolution      |
| agent                 | Bind allowed subset, chọn action                                               |
| validate_action       | Schema, quyền, prerequisites, limits                                           |
| execute_tool          | Một invocation; checkpoint typed result                                        |
| resolve_proposal      | Canonical refs/units/source; unresolved tạo targeted clarification             |
| validate_merge        | Atomic working requirements, confirmation policy, revision/marker invalidation |
| prepare_clarification | Validated question/pending artifact; user tiếp tục ở run sau                   |
| observe               | Project result thành matched ToolMessage                                       |
| validate_result       | Grounding/public projection                                                    |
| validate_completion   | Đủ task outcomes                                                               |
| prepare_publish       | Validated payload/hash + READY_TO_PUBLISH                                      |

Clarification kết thúc lượt với WAITING_INPUT sau finalize; không giữ coroutine chờ user.

## 6. Catalog và tool boundary

ToolContext do server cấp; identity, revision, execution, cancellation/deadline và
policy không xuất hiện trong model args. Không truyền JWT/DB session cho model.

Keyword/vector chỉ tìm candidates; backend revalidate ACTIVE/visibility trước context.
Product ID dùng get/compare; variant UUID/SKU dùng optimizer.
Missing socket/TDP/DDR/size/power thì báo thiếu metadata, không bịa số.
Synthetic iGPU/stock cooler cần parent CPU evidence, không fake purchased SKU.

Tool không sửa trusted requirements hoặc public build. Build phải qua preparation,
compiler, optimizer, verifier và typed presenter.
Catalog descriptions là untrusted data, không instructions.
Each outbound request qua [durable reservation](context-management.md#durable-call-budget).

V2 read-only turns không preload hardware snapshot. Chỉ tải/freeze candidates khi
BUILD hoặc resolve requirement cần catalog; recovery giữ snapshot đã checkpoint.
Hardware mapping vẫn là cấu hình runtime bắt buộc, không phải mỗi lượt đều gọi snapshot.

Call ledger giữ name/version, ID, args hash, revision, catalog/policy hash, typed
outcome/evidence, execution identity và timestamps. Cache reuse cần inputs/versions/
evidence khớp; không dùng SUCCEEDED attempt thay durable graph result.

## 7. Grounding và completion

### Consultation explanation — implemented

Giá/spec/build facts vẫn do server render từ typed evidence. Candidate có thể thêm
`explanation: {text, evidence_refs}`: refs phải thuộc kết quả đã chọn trong canonical
ledger. Phần này được ghi nhãn nhận định tư vấn, không phải benchmark.
Kiểm tra refs chỉ chứng minh nguồn liên kết, không chứng minh mọi câu prose đúng;
semantic/factuality eval là quality gate riêng. Model không được tự tạo FPS/spec/giá.

### Answer contract — target extension

```text
AnswerCandidateV1
  schema_version=1, text, evidence_refs, build_ref?, claims

GroundedClaimV1
  kind: SKU / PRICE / STOCK / COMPATIBILITY / TOTAL_PRICE / BENCHMARK
  evidence_ref, subject_ref, fact_key, typed value, text_span
```

Refs chỉ resolve canonical snapshots/build/report/benchmark của authorized context.
Model URL/UUID không là bằng chứng. Historical result phải có stale/historical label.

Validator kiểm tra subject, visibility, revision, versions, value và exact text span.
Giá dùng integer VND; stock có timestamp; benchmark có source/workload/unit;
compatibility theo modeled rule result. Thiếu evidence thì không khẳng định.

Facts quan trọng được server render từ typed DTO/claims. LLM chỉ diễn giải.
Claim list/Pydantic không chứng minh mọi prose claim đúng; câu “mọi game 2K cực mượt”
vẫn là performance claim. Unsupported assertion bị bỏ/reject/repair; fallback evidence-only.
Factuality eval là quality test, không correctness guarantee hay validator truth source.

### Completion contract

Target: application đăng ký source-bound requested tasks ở đầu turn và resolve
bindings khi có đủ dữ liệu; không chặn exploration vì bindings chưa đầy đủ.
Trước công nhận kết quả, phải có CompletionRequirementV1 đã validate:
kind, required subjects/fields, constraints revision và historical build ref.
Multi-task phải đủ mọi outcome; final model không được thêm/bỏ/hạ task.

Implemented extraction prerequisite: `Draft.tasks[]` holds `kind`, exact
`start/end/quote` and bounded product-mention `subjects` for COMPARE. Provider and
resolver validate spans; extra product IDs are rejected. These are proposals,
not trusted completion requirements: source matching does not prove intent.
`resolve_tasks` binds BUILD to current requirements revision and COMPARE to
canonical product IDs. `BackendProductCatalog.resolve` exhausts keyword cursor
pages (100 products/20 pages maximum); it does not use ranked top-k. Names use
casefold/whitespace normalization and literal matching, not alias guessing.
Missing/ambiguous subjects produce pending candidates; any pending task withholds
the whole completion set. Cursor/schema/budget errors fail, never imply uniqueness.
V2 task-only extraction is available as `NativeRequirementExtractor.extract_tasks`:
one reserved `tasks:register:v2` call returns `TaskDraftBatch`, with no requirements
or previous-state payload. Empty/refused/forged drafts reject, not default ANSWER.
Nine core tests cover source validation, budget rejection and canonical comparison
resolution. Exact quote matching is not a semantic-intent guarantee.
Internal V2 graph now commits task extraction at `register_request` before canonical
`resolve_registered_tasks`; native recovery retains both results. Agent receives
original task/draft plus resolved completion targets. Missing/ambiguous subjects
do not block read tools, but final answers reject until bindings resolve. A task
clarification prepares `flexible.pending_task_resolution` (source-bound
`PendingTaskDraft`), not a fake COMPARE completion target or ANSWER downgrade.
Previously bound subjects are preserved during re-resolution. Three core cases +
two PostgreSQL reopen gates pass; budgets/model/catalog are fixtures in native gates.
V2 `FlexiblePublicationInput.task_reply` binds selection to accepted pending task
source/revision/offered candidates; it cannot mix with confirmation/SKU/unit commands.
Application validates before agent dispatch and re-resolves against current catalog.
Unavailable selected IDs remain bound/unresolved; previous subjects/mention overrides
and original task source survive. Six core + two PostgreSQL reopen gates pass;
native head revisions are fixtures, not managed publication proof. V2 free-text/
amendment continuation and selected factory/transport/CAS remain open.
Accepted saved-build binding and typed/free-text product task continuation are
implemented; unit confirmation, comparison subject correction và requirement-item
amendment cũng đã có. Whole-draft
replacement và arbitrary historical selectors vẫn TODO.
Current runtime (chưa migrate): the managed ReAct factory uses this resolver before the agent. An empty task list
is retained for existing guided drafts;
the general runtime must reject that absence, not infer BUILD.

| Task                | Outcome hợp lệ                                                                                                                     |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| BUILD               | Verified FEASIBLE hoặc scope-proven INFEASIBLE; SEARCH_INCOMPLETE chưa chứng minh infeasible, advice không đủ                      |
| COMPARE             | Comparison đủ 2..5 products yêu cầu, chọn evidence của từng product; thiếu một ref không được COMPLETED. Unknown specs ghi unknown |
| EXPLAIN_SAVED_BUILD | Exact authorized published snapshot, đúng stale label                                                                              |
| CLARIFY             | Đúng missing field/reference và prerequisite reason; task gốc vẫn pending                                                          |
| ANSWER              | Grounded answer, không thay pending build/compare                                                                                  |

Saved-build slice: factory reads the exact authorized application base checkpoint,
not latest, and supplies `SavedBuildEvidence(source_ref, snapshot)` to trusted
context. Ref hashes checkpoint identity + snapshot. EXPLAIN selects that exact ref;
server renders names, historical spending and STALE label, never model prices/FPS.
It cannot satisfy a new BUILD. Finalizer rechecks selected saved evidence against
the run's accepted base. No fake tool call/transcript entry is created for this data.
Missing snapshot asks for one; arbitrary older-run selection is not implemented.

Requirement publication stores `consultation.published_build_hash` binding the
canonical public snapshot, not a second copy of build facts. Projection keeps the
actual constraints revision; publication and accepted reads validate hash/stale
consistency. Legacy optimizer history remains readable when this hash is absent.

Target negative outcomes phải có typed evidence/reasons:

- NEEDS_CLARIFICATION: đúng missing field/reference hoặc user confirmation.
- INSUFFICIENT_EVIDENCE: thiếu facts/measurement conditions; NO_RESULTS và
  SOURCE_UNAVAILABLE dựa trên actual tool outcomes. FACT_UNKNOWN/FACT_CONFLICT cần
  exact typed fact refs tương ứng; không suy absence từ prose hoặc search coverage.
- INFEASIBLE: chỉ khi application/optimizer chứng minh không có nghiệm **trong scope
  đã nêu**. Result phải bind requirements/input hash, candidate/catalog snapshot và
  algorithm/pruning/policy versions; coverage và search phải đầy đủ trong scope,
  pruning không làm mất nghiệm. Không suy ra vô nghiệm trên toàn catalog ngoài scope.
- SEARCH_INCOMPLETE: không có nghiệm tìm được nhưng search chưa đầy đủ, heuristic/
  lossy pruning, thiếu coverage hoặc dừng vì budget/time limit. Không tìm thấy ≠ không
  tồn tại; presenter nói “chưa tìm được trong dữ liệu/phạm vi đã kiểm tra”.
- Không gọi optimizer, dùng stale result, thiếu metadata hoặc backend lỗi không tạo
  infeasibility proof. NO_FEASIBLE_BUILD không là model-selected shortcut/enum đồng nghĩa;
  negative build result đi qua hai outcomes trên. Legacy INFEASIBLE không có search/
  coverage evidence không tự nâng thành proven result khi migrate/replay.
- DEPENDENCY_UNAVAILABLE: actual adapter failure, không giả catalog rỗng/no solution.

F03 implemented slice (`react/outcomes.py`, internal flexible graph): final action
names unique `supporting_tool_call_ids`; selected current ledger must contain actual
FAILED adapter outcome, empty search, or unreadable/empty page. Server renders
DEPENDENCY_UNAVAILABLE / NO_RESULTS / SOURCE_UNAVAILABLE, not model prose. Readable
structured UNKNOWN/CONFLICT facts now support FACT_UNKNOWN/FACT_CONFLICT through
exact fact/call refs; positive completion selecting them rejects. Fact status/model/
source use the existing server renderer, not agent numbers. Native PostgreSQL
reopen/resume and pure publication revalidation pass without refetch; not managed
SQL CAS or live-provider proof.
`FlexibleAnswer(schema_version=2)` separates response status from original task
outcomes: negative response and requested tasks stay UNRESOLVED. Positive response
is mapped only after grounding/completion passes. These are internal DTOs, not a
change to default V1 API. V2 opt-in uses these DTOs. Optimizer search evidence is
implemented below; partial completion across mixed tasks uses MULTI_TASK below.
Benchmark-condition facts remain source backlog. Current curated facts cover
dimensions only; readable general prose cannot
certify absence of facts or builds.

MULTI_TASK final candidates cover every registered task index exactly once. Each
candidate reuses the single-task validator; application supplies task kind, derives
completion/reason and combines grounded output. A completed build can be published
alongside unresolved fact research; scoped optimizer failure cannot erase a verified
catalog answer. Overall completion requires all tasks completed. Aggregate prose
and evidence are not another authority; per-task public metadata is a projection
of validated results. Native reopen/resume, pure preparation and managed SQL
confirmation/build/CAS/history pass. Managed partial-build gate uses the real
attempt ledger; duplicate submit does not advance the head or duplicate messages.
The next turn explains the preserved saved build without optimizing again.
Model/catalog/web sources are fixtures, not live-provider proof.
Per-task validation failure yields static TASK_INCOMPLETE with failed task_indices;
bounded repair reuses the canonical ledger. Core repair regression verifies one
optimizer call and one page read, not retries of successful work.

Search final validation re-derives selected report from current input/catalog/policy
and compares it to canonical tool evidence. Server renders scoped INFEASIBLE or
SEARCH_INCOMPLETE; no model prose/global absence claim. Proven scoped INFEASIBLE
completes BUILD only; COMPARE/other tasks remain unresolved. SEARCH_INCOMPLETE
completes no task. PostgreSQL reopen after optimizer commit reuses receipt/report
without optimizing again; fixture scope is an explicitly empty supplied candidate
set, not proof of empty backend catalog or managed publication.

Tìm được build qua independent verifier → FEASIBLE, kể cả search dùng heuristic
hoặc chưa exhaustive. Đây là proof tồn tại, không guarantee optimality. Search
completeness chỉ bắt buộc khi kết luận không có nghiệm; SEARCH_INCOMPLETE áp dụng
khi chưa tìm được nghiệm và chưa có infeasibility proof.

Execution status và task completion tách biệt: có thể kết thúc lượt với lời giải thích
thiếu dữ liệu nhưng task BUILD/COMPARE vẫn UNRESOLVED, không được COMPLETED. F01
phải chốt DTO/run-status mapping và failure policy trước code; lỗi DB/auth/ownership
không được bypass để publish negative answer. Bounded repair hoặc typed negative
outcome; không ép agent bịa evidence để thoát loop.
Current validator chỉ có success/clarification/reject; negative outcomes chưa wired.
FINAL_ANSWER chỉ là candidate. Application validate outcome/evidence/completion
trước END/READY_TO_PUBLISH; lời model “không có cấu hình phù hợp” không phải proof.
SEARCH_INCOMPLETE không hoàn thành BUILD bằng một khẳng định vô nghiệm; task outcome
phải phản ánh chưa kết luận, không biến timeout/dependency failure thành solution proof.

## 8. Publication và delivery

Internal V2 coordinator uses application-written `publication_context`, not model
actions, to revalidate the exact accepted base and stored `TurnRequestV2`. Fresh
tasks require source-bound registration; fixed tasks may only continue accepted
waiting work. Owner/run/conversation, saved-build base, outcome/grounding and
prepared snapshot must match. Native lineage binds run/execution/generation/base/
input hash/graph version. Only drained stop proof allows the existing fenced CAS
to advance head/revision and insert one assistant message. WAITING_INPUT maps to
run WAITING_INPUT; other published responses finish the run while typed task
outcomes can remain UNRESOLVED. Bad lineage/snapshot does not publish or release
the slot. Seven core + three PostgreSQL managed read/waiting/rejection gates pass;
provider/catalog are fixtures. Managed confirmation→build→saved explanation also
passes with the real optimizer: source-bound task persists, spending/requirements
stay unchanged in historical explanation, no extra optimization or duplicate
publication on retry. Selected factory/HTTP and managed SKU/unit/task-selection/
recovery gates remain open.

Opt-in runtime: `AI_STATEFUL_REACT_ENABLED=true`, guided flag false, plus configured
DB/JWKS/model/key/catalog mapping. `add_react_nodes` registers the bounded loop
directly on the outer requirement graph: no second thread or nested agent runtime.
Trusted context gets owner/run from SQL claim and merged requirements/candidates;
per-turn ledger/counters reset only on a new turn. Read-only tasks skip hardware
scan and preserve unchanged published builds. BUILD prerequisites fail into typed
clarification/unsupported, not generic advice. Read completion publishes ANSWERED
only with validated answer/tasks; same stop/lineage/CAS rules apply. SSE remains TODO.

Finalizer kiểm tra [native lineage/stop/CAS](context-management.md#native-checkpoint-and-finalization-protocol).
Graph marker không tự publish hoặc nhường thread.

SSE chỉ gửi public progress/provisional output; COMPLETED sau CAS.
Không gửi intermediate agent text, ledger, checkpoint selectors hay hidden reasoning.
Reconnect đọc persisted events, không chạy model lại.
Logs correlate conversation/run/execution/call nhưng không log secrets/PII/raw prompts
hoặc account UUID thành high-cardinality metric label.

## 9. Core acceptance

- Resolve ambiguous SKU/unit đúng; merge atomic, không mất CLEAR/source/locks.
- Hard/soft/pin/owned khác semantics; compiler thiếu/sai mapping bị verifier reject.
- Unsupported không thành success; FULL_SETUP không mất phụ kiện hay tự chia budget.
- Stale tool policy chặn handler; multi-call repair giữ valid provider transcript.
- Tool committed rồi crash trước observe: một projected message, không rerun tool.
- Grounding và task completion độc lập; correct advice không hoàn thành BUILD.
- Khám phá catalog trước khi có đủ budget/use case; không execute build_pc quá sớm.
- Agent proposal giảm RAM/đổi GPU không tự commit; exact confirmation mới apply.
- Tool phát hiện ambiguity → hỏi user, reopen giữ original task và accepted state.
- Proposal đổi constraints sau một build → giữ ledger cũ nhưng không reuse stale build.
- Một run merge H0→H1→H2: accepted H0/head bất biến; cancel/CAS failure không đổi
  public state; CAS success publish validated H2, chỉ tăng conversation_revision.
- Agent tự giảm RAM để tăng GPU bị giữ ở proposal; confirmation sai ID/hash/target
  revision/base requirements hash reject. “OK” không chấp nhận payload đã bị sửa.
- Không có optimizer proof hoặc proof input/hash cũ bị reject trước END. Exhaustive
  no-solution có scope proof trả INFEASIBLE; heuristic/limited search không tìm được
  nghiệm trả SEARCH_INCOMPLETE. Heuristic tìm được build hợp lệ vẫn trả FEASIBLE.
- Search empty/403 hoặc thiếu điều kiện đo → typed negative result, không fabricated FPS.
- Structured repair feedback sửa đúng lỗi; exhausted caps kết thúc hữu hạn.
- Stage reuse và native recovery giữ hash/versions; scripted model + optimizer thật.
- PostgreSQL/stop/budget/root gates: [context acceptance](context-management.md#core-acceptance).
