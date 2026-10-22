# Plan — Separate task and requirement extraction

Ngày: 2026-10-21 · Executor dự kiến: Luna 6, reasoning max.
Trạng thái: **COMPLETED — T0–T6** · Tracker: `ISSUE-148`, `UC-AI-001`.

## 1. Kết quả cần đạt

Một nguồn đăng ký task; requirement extractor chỉ trả requirement items.

```text
User message → Task extractor → registered tasks → ReAct
                                                   ↓ khi cần sửa requirements
                                      Requirement extractor → validate/merge
```

Ví dụ: “Build PC 25 triệu, RAM ít nhất 32GB”:
- Task: BUILD, kèm source spans.
- Requirements: budget LTE 25000000 VND; RAM capacity GTE 32GB.
- Không extract BUILD lần nữa khi kiểm tra proposal requirements.

Không đổi optimizer, tool policy, consent, public HTTP/SSE hoặc CAS publication.
Không thêm framework/dependency, không sửa FE/BE/infra, không train GPU/deploy.

## 2. Cách giao việc cho Luna

Không giả định chất lượng chỉ từ tên model. Plan giảm lượng context và quyết định
ngầm: mỗi lượt làm **một task** ở bảng dưới, chạy gate rồi ghi handoff.

1. Đọc `AGENTS.md`, plan này, handoff và `git status` trước mỗi lượt.
2. Chỉ đọc source/tests của task hiện tại cùng định nghĩa được import trực tiếp.
3. Viết test fail → sửa tối thiểu → chạy focused tests. Không đổi expected để che lỗi.
4. Lỗi import/type do chuyển contract: dùng `rg` tìm caller; không thêm alias/fallback.
5. Không refactor toàn repo hoặc đổi version để làm tests xanh.
6. Gate fail thì dừng task, giữ nguyên evidence; không tự đánh COMPLETED.
7. Thay đổi semantic/checkpoint chưa có rule: ghi issue, hỏi owner; không tự quyết mất dữ liệu.
8. Không tự commit/push. Đề xuất commit nhỏ sau gate nếu owner yêu cầu.

Mỗi handoff tối đa 8 dòng: task/status, files, test command/result, issue, next task.
Không dựa vào lịch sử chat để suy ra quyền deploy hay trạng thái test.

## 3. Contract đích đã chốt

| Thành phần | Trách nhiệm |
| --- | --- |
| `TaskDraftBatch`, `TaskExtractor` | Giữ task contract hiện tại; không chứa requirements |
| `RequirementDraft` | Chỉ `schema_version` và `items`; không có `tasks` |
| `NativeTaskExtractor` | extract_tasks, choose_task, amend_task |
| `NativeRequirementExtractor` | extract, choose, choose_unit, amend |
| Shared structured invocation | Tái sử dụng hành vi `_generate`/`invoke_provider`, không tự retry |

`RequirementDraft` là contract mới, dùng `schema_version = 2`; kế thừa strict
`Contract`. Có field `tasks` dù rỗng cũng bị reject đối với **input mới**.
Giữ nguyên `DraftItem`, operations SET/CLEAR/absent, evidence spans và admission rules.
Không đổi độc lập các public DTO version chỉ vì đổi tên Python class.

Đặt contract mới cạnh resolver hiện tại; task adapter mới tại
`infrastructure/providers/task_extractor.py`. Chỉ tách một helper gọi structured
model nếu hai adapter cần dùng; không thêm class base, factory hoặc agent runtime.
Không duy trì `Draft = RequirementDraft` hay method task alias trên requirement adapter.

### Checkpoint/receipt compatibility — bắt buộc kiểm tra trước khi bỏ contract cũ

- Thu thập fixture từ serializer hiện tại cho accepted head, pending requirement,
  pending task, proposal/user receipt và failed run có thể recover; không cần dữ liệu server.
- Phân biệt graph legacy `requirement_build` với runtime V2 `flexible`; tests còn
  import graph cũ không chứng minh production đang dùng nó.
- Đọc payload cũ phải validate contract cũ trước. Không `pop('tasks')` trên JSON tùy ý.
- Không sửa accepted checkpoint, receipt/proposal hash, task evidence, lineage hoặc revision.
- Chỉ normalize dữ liệu sau boundary validation, trước khi tạo working input mới.
  Historical signed/hashed receipts giữ nguyên; chuyển kiểu không được làm đổi consent.
- Recovery dùng native checkpoint, không copy `snapshot.values` sang thread mới.
- Nếu cần giữ legacy DTO, cô lập nó ở boundary đọc lịch sử, không expose cho model mới.
  Đây không phải alias/runtime fallback. Chỉ giữ khi fixture chứng minh cần thiết.
- Nếu migration đổi hash hoặc native resume semantics: **gate fail**, yêu cầu review
  solution cụ thể trước khi implement tiếp phần compatibility. Không reset conversation/DB.

## 4. Trình tự triển khai

Các đường dẫn source dưới đây tương đối với `ai-service/src/ai_service/`.
Không triển khai các task song song; task sau dùng kết quả đã verify của task trước.

| Phase / Task | Phạm vi | Gate |
| --- | --- | --- |
| P0 / T0 | Baseline và compatibility inventory | Có fixture matrix + baseline; không quyết định migration bằng phỏng đoán |
| P1 / T1 | Contract mới + adapter riêng | Schema/prompt không trùng trách nhiệm; adapter tests pass |
| P1 / T2 | Chuyển toàn bộ caller runtime V2 | Explicit user admission, task registration và follow-up pass |
| P2 / T3 | Boundary dữ liệu cũ | Accepted/pending/recovery giữ semantics và hash; native persistence pass |
| P2 / T4 | Training/export/evaluation/Qwen | Nhãn, prompt và schema runtime–train đồng bộ |
| P3 / T5 | Chuyển coverage, bỏ graph gộp | Không còn production/active test import graph cũ |
| P3 / T6 | Full verification + docs | Không thiếu gate; report đúng mức bằng chứng |

### T0 — Baseline và regression (COMPLETED)

Đọc trước: `requirements.md`, `context-management.md`, `training.md`;
`resolver.py`, `providers/requirement_extractor.py`, `execution/build_runtime.py`,
`graph/durable.py`, `graph/requirement_build.py`, `training/dataset.py`.

- Inspect dirty files và ghi base commit; không checkout/reset công việc của owner.
- `rg` map `Draft`, `.tasks`, `NativeRequirementExtractor`, `build_requirement_graph`.
- Ghi fixture matrix compatibility: nơi persist, version, field, hash phụ thuộc.
- Chạy baseline focused tests nêu ở §5; ghi fail có sẵn riêng.
- Thêm regression chứng minh requirement prompt/schema còn yêu cầu tasks trong khi
  dataset validator cấm chúng. Giữ test fail cho tới T1/T2, không sửa production trước.

#### T0 kết quả và compatibility matrix

Baseline từ AI `dd6248451c8c864ee135c6d3a41c038ad152610f`, worktree sạch trước khi
thêm test:

```text
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q \
  tests/test_native_requirement_extractor.py \
  tests/test_native_task_registration.py tests/test_explicit_user_admission.py \
  tests/test_training_export.py tests/test_qwen_provider.py tests/test_qwen_training.py
45 passed
```

Hai regression `test_requirement_extraction_schema_does_not_register_tasks` và
`test_requirement_extraction_prompt_does_not_ask_for_task_registration` đỏ có
chủ đích: provider nhận `Draft` có `tasks`, và prompt mở đầu bằng yêu cầu trích
task. Characterization `test_requirement_dataset_rejects_tasks_from_combined_draft`
pass, xác nhận validator từ chối chính payload đó với
`REQUIREMENTS_CANNOT_REPLACE_TASKS`. Kết quả: **2 failed như dự kiến, 1 passed**.
Không có lỗi baseline trước thay đổi này.

| Artifact được kiểm tra | Serialization/persistence hiện tại | Version và identity/hash cần giữ | Fixture/test hiện có |
| --- | --- | --- | --- |
| Accepted head | SQL `conversations.accepted_checkpoint_id`; `ConversationHeadV1` tạo `CheckpointRefV1(thread_id, checkpoint_id)` | `revision` + exact checkpoint ref là CAS base; không suy ra từ latest | `integration_tests/test_accepted_head_postgres.py::test_new_turn_uses_accepted_head_after_orphan_and_pool_restart`; `integration_tests/test_failed_first_turn_postgres.py` |
| Accepted flexible state | Native LangGraph checkpoint; `FlexiblePublishedState.model_dump(mode="json")` trong `accepted_snapshot` | `FlexiblePublishedState.schema_version=2`; saver metadata có `FLEXIBLE_GRAPH_VERSION=native-flexible-react-v2-managed` | `integration_tests/test_flexible_storage_postgres.py`; `integration_tests/test_flexible_graph_postgres.py` |
| Pending requirement | `FlexiblePublishedState.pending_resolution` → `PendingResolution(schema_version=2)` → `PendingDraft` → `Resolution.draft: Draft` | `Draft.schema_version=1`, có `items` **và `tasks`**; `PendingResolution.base_requirements_hash` dùng `requirements-content:v1`; source message/id, lựa chọn và quantity confirmation thuộc artifact | V2: `test_new_waiting_preparation_revalidates_artifact_after_reopen`, `test_typed_choice_after_postgres_reopen_still_requires_confirmation`, `test_managed_confirmation_build_and_saved_explanation_preserve_snapshot` |
| Pending task | `FlexiblePublishedState.pending_task_resolution` → `PendingTaskDraft`; task graph channel có `task_draft`/`task_resolution` | `FlexiblePublishedState.schema_version=2`; `PendingTaskDraft`/`TaskDraftBatch` chưa có schema version riêng; task message, source spans, constraints revision, candidates/bindings phải còn nguyên | `integration_tests/test_flexible_task_selection_postgres.py::test_task_selection_reopen_preserves_source_and_selected_identity`; `integration_tests/test_flexible_registration_postgres.py::test_registered_tasks_survive_reopen_without_extraction_or_lookup_repeat`; `integration_tests/test_flexible_managed_task_postgres.py` |
| User receipt | `FlexibleState.user_receipts[]` checkpoint channel; `UserRequirementReceipt` giữ `proposed` và `extracted` Draft | `policy_version=explicit-draft-match-v1`; `message_hash` + `base_requirements_hash`; không có hash toàn receipt. Tasks trong `extracted` được source-validate, nhưng `_same_items` chỉ so requirement items | `integration_tests/test_explicit_user_managed_postgres.py::test_user_requirements_publish_without_confirmation_and_survive_recovery` |
| Agent proposal/confirmation | `FlexiblePublishedState.pending_proposal` trong accepted snapshot | `PendingRequirementProposal.schema_version=2`; `proposal_hash` hash payload; confirmation gắn proposal id/hash, target revision và base requirements hash | `integration_tests/test_flexible_graph_postgres.py::test_confirm_then_clarify_preparation_survives_reopen`; `integration_tests/test_flexible_managed_publication_postgres.py::test_v2_managed_run_publishes_snapshot_message_and_head_once` |
| Failed/recoverable run | SQL `agent_runs.request_payload`, `request_hash`, `base_checkpoint_ref`, `last_checkpoint_ref`, `final_checkpoint_ref`, `versions`, status/attempt fields; native checkpoint giữ working values | `request_hash` không đổi; `versions.graph_version` phải khớp; recovery dùng exact stored source/ref và stop evidence, không đổi accepted head | `integration_tests/test_flexible_managed_publication_postgres.py`; `integration_tests/test_native_resume_postgres.py::test_exact_native_resume_reopen_does_not_reexecute_committed_node`; `integration_tests/test_failed_first_turn_postgres.py` |
| Legacy build graph | `graph/requirement_build.py` đã được xóa ở T5; `open_build_runtime` dùng flexible V2 | Checkpoint V1 không được resume như graph V2; persisted receipt/draft cũ vẫn qua strict compatibility decoder | V2 coverage được liệt kê trong T5 coverage map; `test_v2_native_wrapper_uses_accepted_head_and_rejects_legacy_after_reopen` |

Task/requirement training và runtime đã dùng contract riêng (`TaskDraftBatch`,
`RequirementDraft`). `Draft` chỉ còn ở strict reader/resolver cho artifact lịch sử.
`NativeTaskExtractor` và `NativeRequirementExtractor` sở hữu các port riêng;
runtime composition chọn `build_flexible_graph`.

T0 không tạo fixture JSON độc lập: ma trận trỏ tới test tích hợp đang serialize,
reopen và validate các artifact thật, tránh snapshot tự tạo khác serializer. T3
phải chuyển các test này thành compatibility gates trước khi đổi decoder/schema.

### T1 — Contract + providers (COMPLETED)

Files: `requirements/resolver.py`, `providers/requirement_extractor.py`,
`providers/task_extractor.py` (mới); helper structured call chỉ nếu cần.

- Thêm `RequirementDraft` theo §3; chưa xóa DTO cũ trước khi chuyển callers.
- Requirement prompt chỉ trích items; bỏ instruction BUILD/COMPARE/ANSWER extraction.
- Chuyển task methods/prompt builder sang task adapter, giữ nội dung task semantics.
- Chuyển các test task hiện nằm trong `test_native_requirement_extractor.py`
  (`BUILD` exact span, invalid span, `COMPARE` subjects) sang test adapter task;
  giữ assertions, không xóa coverage để làm suite xanh.
- Giữ attempt boundary, tên operation ổn định khi semantics không đổi; không thêm
  retries ngoài ledger. Không phát sinh thêm model call mỗi turn.
- Test requirement schema reject `tasks`, task output không lẫn requirements;
  adapter vẫn validate structured output và exact spans.

### T2 — Runtime V2 (COMPLETED)

Files: `requirements/{build,catalog_policy,user_admission}.py`, `react/actions.py`,
`commerce/hardware_catalog.py`, `graph/flexible.py`, `execution/build_runtime.py`.

- Dùng `RequirementDraft` cho proposals, resolution, catalog input và user extraction.
- Resolver/admission không validate task từ requirement draft nữa; task validation
  vẫn ở task registration/clarification, không xóa validation chung bằng find-replace.
- Instantiate hai adapters dùng cùng provider/attempt boundary/context.
- Wire `task_extractor/task_clarifier/task_amender` sang task adapter;
  `user_extractor/clarifier/unit_clarifier/amender` sang requirement adapter.
- Kiểm tra schema lồng trong `FlexibleDecision` và public OpenAPI nếu có ảnh hưởng;
  regenerate bằng script sẵn có, không sửa generated artifact bằng tay.
- Case chính: BUILD + budget/RAM; COMPARE; follow-up chỉ sửa RAM; agent đề xuất
  thay đổi chưa được user cho phép vẫn phải confirmation. Requirements không sửa task authority.

#### T2 handoff (2026-10-22)

- Runtime V2 proposals, resolution/catalog consumers, user receipt, and graph composition now use `RequirementDraft`; task methods are wired to `NativeTaskExtractor`.
- V2 fixtures that construct proposal payloads use schema v2; the legacy pending-reference fixture is projected to requirement-only data for this runtime test.
- Focused runtime/provider/follow-up gate: **129 passed** across explicit admission, flexible graph, catalog admission, clarification, task choice/amendment, and both adapters.
- Ruff on changed source/tests: **passed**; `git diff --check`: **passed**.
- `mypy src/ai_service` is not green yet: dataset/export callers are scheduled for T4, and the old combined graph is scheduled for T5; no errors were reported in T2 modules.
- PostgreSQL compatibility was not claimed or tested here; persisted receipt/checkpoint decoding is the T3 gate.
- Next: T3, add exact old-payload compatibility tests and preserve accepted/pending receipt semantics without rewriting hashes or checkpoint history.

### T3 — Compatibility (COMPLETED)

Áp dụng matrix T0 và invariant §3. Dùng boundary reader hiện có; chỉ thêm decoder
versioned nhỏ nếu cần. Thay đổi từng đường accepted/pending/recovery, test ngay.

- Pending requirements vẫn giữ source, lựa chọn và draft chưa merge.
- Pending task vẫn giữ task identity; không đổi thành requirement.
- Receipt/proposal cũ không bị biến thành consent mới sau chuyển đổi schema.
- Resume không gọi lại model/optimizer đã commit; exact accepted head thắng orphan.
- Không bump `FLEXIBLE_GRAPH_VERSION` chỉ để né test hoặc nhận tất cả version.
- Gate PostgreSQL chưa chạy được thì ghi UNVERIFIED, không thay bằng in-memory proof.

#### T3 handoff (2026-10-22)

- Added strict boundary decoders for stored V1 proposal decisions and explicit-user receipts; live `FlexibleDecision` and `UserRequirementReceipt` still accept only `RequirementDraft` v2.
- Legacy receipt task evidence is validated against the original request before projecting only requirement items; replay still checks the original run, message hash, base requirements hash, and full item match.
- Pending V1 requirement drafts remain typed as legacy `Draft` when reopened; the accepted-snapshot JSON, task evidence, candidate IDs, and content hash round-trip unchanged.
- No checkpoint was rewritten, accepted head/receipt hash/revision was changed, or graph version bumped.
- Unit compatibility/runtime gate: **141 passed**. Native PostgreSQL gates: **55 passed** across exact legacy artifact reopen, accepted-head, registration, pending requirement/task, managed publication/build, and native resume.
- `ruff check src tests integration_tests` and `git diff --check`: **passed**. Full mypy still reports only the planned T4 dataset/export and T5 legacy-graph errors.
- Next: T4, migrate dataset validation/export/evaluation and Qwen schema routing; do not train or replace active model configuration.

### T4 — Training và Qwen (COMPLETED)

Files: `training/{dataset,export,evaluation}.py`, `providers/qwen.py`;
`training/pilot-v1/` và tests tương ứng khi fixture thực sự bị ảnh hưởng.

- Task label → `TaskDraftBatch`; requirement label → `RequirementDraft`.
- Export dùng đúng builder của hai adapter. Qwen routing nhận schema mới, auxiliary
  head vẫn giữ routing base model hiện tại; không thay active model/provider env.
- Train/inference vẫn dùng cùng `prepare_qwen_request` đưa schema vào system prompt;
  tool schema vẫn qua native `tools`. Không nhét schema thêm lần nữa ở extractor.
- Test so sánh system/user messages và full JSON schema sau projection, không chỉ
  assert tên schema xuất hiện. Fake tokenizer chỉ chứng minh plumbing, không native-token parity.
- Record nào có cả tasks/items: tách thành hai sample cùng scenario/split sau review;
  không silently drop tasks, không auto-approve nhãn hoặc làm rò test split vào SFT.
- Schema/prompt đổi: regenerate export/hashes/manifest bằng tooling hiện có.
  Không overwrite artifact/adapter cũ; không tuyên bố adapter cũ đã tương thích.

#### T4 handoff (2026-10-22)

- Dataset validation, export and evaluation now use `RequirementDraft`; task labels remain `TaskDraftBatch`. No pilot labels were auto-approved or rewritten.
- Qwen adapter routing covers `RequirementDraft` and `TaskDraftBatch`; choice/amendment stays on base model. Native tool schemas remain in `tools`.
- Training and serving share `prepare_qwen_request`; added assertions compare the complete projected system/user messages and schema, not only its name.
- Focused T4 gate: **49 passed**; training/export/Qwen/schema regression suite: **48 passed**. `ruff check src tests integration_tests` and `git diff --check`: **passed**.
- `mypy src/ai_service` now reports only the legacy graph assignment scheduled for T5 (`graph/requirement_build.py:243`). No GPU/native tokenizer/vLLM or live provider run was performed.
- Next: T5, transfer legacy graph behavior coverage to V2 and remove obsolete combined-draft producer/imports without dropping behavior assertions.

### T5 — Legacy removal (COMPLETED)

- Chuyển coverage từ `graph/requirement_build.py` sang graph V2 trước khi xóa graph.
- Mapping bắt buộc trong handoff: old test/case → new test/case hoặc lý do thực sự trùng.
- Giữ case BUILD, reference/unit clarification, task choice/amendment, pending replace,
  explicit admission, accepted-head/recovery và publish; không xóa assertions để test pass.
- Các file `test_requirement_graph`, `test_react_composition`, `test_pending_*`,
  `test_task_*`, `test_quantity_clarification` và integration tương ứng cần kiểm tra.
- Xóa producer/import của combined `Draft` và graph cũ khi không còn caller.
  Compatibility DTO có bằng chứng cần đọc lịch sử được giữ riêng như §3.

#### T5 coverage map

| V1 test/case đã gỡ | V2 test/case giữ coverage |
| --- | --- |
| `test_requirement_graph_runs_optimizer_and_only_emits_verified_summary`; `test_size_bound_rejects_before_external_extraction`; `test_followup_catalog_load_receives_accumulated_requirements` | `tests/test_flexible_graph.py::test_flexible_build_uses_real_optimizer_and_trusted_task`, `test_state_size_bound_rejects_before_model_or_catalog_access`; the build test asserts lazy loader receives canonical accumulated requirements |
| `test_resume_after_explanation_failure_reuses_optimizer_checkpoint` | `integration_tests/test_flexible_graph_postgres.py::test_scoped_search_report_survives_reopen_without_reoptimizing`; native checkpoint control additionally covered by `integration_tests/test_native_resume_postgres.py::test_exact_native_resume_reopen_does_not_reexecute_committed_node` |
| `test_pending_sku_choice_survives_reopen_and_merges_entire_original_draft`; `test_pending_choice_rejects_stale_source_or_non_candidate_without_merge`; `test_missing_selection_preserves_pending_budget_and_candidates`; `test_graph_choice_revalidates_before_whole_draft_merge`; `test_free_text_choice_reuses_original_budget_and_pin`; `test_resume_after_catalog_failure_does_not_repeat_completed_choice_call` | `tests/test_flexible_reference_continuation.py`; PostgreSQL `test_typed_choice_after_postgres_reopen_still_requires_confirmation`, `test_new_waiting_preparation_revalidates_artifact_after_reopen` |
| `test_free_text_unit_choice_is_budgeted_and_original_draft_survives`; `test_unit_confirmation_merges_original_draft_once_and_binds_both_sources`; `test_pending_quantity_reopens_and_keeps_budget_until_atomic_confirmation` | `tests/test_flexible_unit_continuation.py`; PostgreSQL `integration_tests/test_flexible_managed_build_postgres.py::test_managed_confirmation_build_and_saved_explanation_preserve_snapshot` (UNIT/UNIT_FREE/UNIT_AMEND/UNIT_DISCARD cases) |
| `test_whole_pending_action_preserves_accepted_state_and_build`; `test_sku_mention_amendment_uses_fresh_catalog_and_preserves_budget`; `test_graph_amends_without_reextracting_original_and_reuses_checkpoint` | `tests/test_flexible_pending_replace.py`, `tests/test_flexible_amendment.py::test_reference_amendment_resolves_catalog_sku_without_merging_existing_state`; PostgreSQL V2 managed publication/idempotency tests cover accepted-head publication, while action binding/discard behavior is asserted at the V2 graph/publication boundary |
| `test_comparison_clarification_survives_native_turn_without_reextracting_tasks`; `test_graph_keeps_original_task_and_resumes_committed_mention_edit`; task cases in `test_requirement_flow_runs_react_for_read_task_without_optimizer` | `tests/test_flexible_task_selection.py`, `tests/test_flexible_task_amendment.py`; PostgreSQL `test_task_selection_reopen_preserves_source_and_selected_identity`, `test_registered_tasks_survive_reopen_without_extraction_or_lookup_repeat`, `test_managed_task_choice_publishes_comparison_not_choice_message` |
| `test_build_request_cannot_finish_as_generic_advice`; `test_requirement_flow_runs_react_for_read_task_without_optimizer`; `test_build_then_next_turn_keeps_requirements_from_accepted_root`; `test_initial_root_is_terminal_empty_and_readable_without_running_a_turn` | `tests/test_flexible_graph.py::test_advice_cannot_complete_build_or_claim_infeasibility_without_proof`, grounded read/build tests and task completion tests; PostgreSQL initial-root, accepted-snapshot, native-resume and managed-build suites |
| `test_pending_action_reopen_publish_and_idempotency`; `test_quantity_unit_reopen_atomic_merge_and_native_publish`; `test_managed_comparison_reopen_keeps_requirements_and_consumes_product_choice`; `test_postgres_pending_choice_reopen_atomic_merge_and_public_projection` | V2 typed-choice/reopen tests, managed-build UNIT cases, task-selection/registration tests; requirement pending-action semantics are asserted by `tests/test_flexible_pending_replace.py`, with SQL publication/idempotency covered separately by V2 managed-run tests |
| `test_submit_claim_execute_publish_and_follow_up` (trace persistence, idempotency/conflict, busy/owner, follow-up, HTTP status, history pagination, failure without publish) | `test_v2_request_admission_preserves_commands_and_idempotency` (now asserts persisted `trace_id`); `test_v2_managed_run_publishes_snapshot_message_and_head_once`; `test_native_runtime_claims_http_run_and_closes_provider_after_drain` (follow-up, message pages/cursor rejection, stale revision); `test_cancel_owner_idempotency_and_shared_thread_drained_before_release`; `test_failed_first_v2_run_releases_then_next_run_uses_root_after_reopen`; run-event API tests |

#### T5 handoff (2026-10-22)

- Removed `infrastructure/graph/requirement_build.py`; source/test search finds no remaining imports or producer references.
- Legacy `Draft` remains only for strict persisted V1 proposal/receipt/pending-resolution reads; current extractor, catalog, and graph inputs use `RequirementDraft`/`TaskDraftBatch`.
- Compatibility `Draft.items` is projected to a validated `RequirementDraft` only for the pending catalog-needed check; persisted payload/hash is untouched.
- Replaced graph-specific V1 tests with V2 behavior coverage; exact mapping is above. Added V2 checks for state-size rejection, accumulated lazy-catalog requirements, SKU amendment, and requirement pending discard.
- Focused unit gate: **75 passed**. Relevant PostgreSQL V2 suites: **48 passed**. `ruff check src tests integration_tests`, `mypy src/ai_service`, and `git diff --check`: **passed**.
- At the T5 gate, full unit suite and external provider/GPU/tokenizer tests had not run.
- No commit, push, or deploy was performed.

### T6 — Final audit và docs (COMPLETED)

- Full unit/static gates tại §5. Integration quan trọng phải chạy trên DB test riêng.
- `rg` không còn combined Draft/task prompt trong requirement producer; phân biệt
  tên `DraftItem/PendingDraft` hợp lệ, không rename hàng loạt vì trùng chữ Draft.
- Cập nhật `requirements.md`, `training.md`, architecture/source map nếu thực sự đổi;
  cập nhật tracker counts, trạng thái plan và `SESSION_CHECKPOINT.md`.
- Report riêng: code tests, PostgreSQL, native tokenizer/vLLM, live provider. Không
  test GPU/model/server thì nói chưa test, không chốt toàn dự án production-ready.

#### T6 handoff (2026-10-22)

- Full unit suite: **867 passed**.
- Relevant T5 PostgreSQL suites: **48 passed**; final full PostgreSQL integration suite: **93 passed** on the configured test database.
- `ruff check src tests integration_tests`, `mypy src`, `uv lock --check`, and `git diff --check`: **passed**.
- Updated architecture, requirements, AI status, README, session checkpoint, plan, and `ISSUE-148` tracker entry.
- `Draft` remains only for strict historical V1 reads; no active combined-draft graph/provider path remains.
- No live provider, GPU, tokenizer/vLLM, commit, push, or deployment was performed.

## 5. Commands và acceptance

Chạy từ `ai-service/`, dùng env test hiện có; không in DSN/secrets.

```sh
# Baseline / sau T1–T4; sửa tên test nếu có rename có chủ đích
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q tests/test_native_requirement_extractor.py tests/test_native_task_registration.py tests/test_explicit_user_admission.py tests/test_training_export.py tests/test_qwen_provider.py tests/test_qwen_training.py
# Gate cuối
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q integration_tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run ruff check src tests integration_tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run mypy src
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv lock --check
```

PostgreSQL gate tối thiểu: explicit user managed, flexible registration, reference/
unit pending continuation, managed publication/build và native recovery tests hiện có.
T0 ghi chính xác file/case cho reference/unit pending sau khi map sang V2; không dùng
graph legacy làm bằng chứng runtime mới. Không chạy integration vào DB server dùng chung.

Hoàn thành khi: contract/prompt/labels không trùng, V2/recovery/consent không regress,
legacy runtime được bỏ, docs đúng code. Không lấy test-count mục tiêu làm acceptance.

## 6. Handoff hiện tại

- Plan **T0–T6 complete**; `ISSUE-148` resolved. This does not mark UC-AI-001 fully complete.
- Core split: task extraction owns task registration; requirement extraction owns requirement items only.
- Removed `infrastructure/graph/requirement_build.py`; V1 `Draft` is confined to validated persisted-data compatibility reads.
- Verified: 867 unit and 93 PostgreSQL integration tests; Ruff, mypy, lock check and diff check pass.
- No live model/GPU/tokenizer test and no commit, push, or deploy.
- Worktree changes remain uncommitted; preserve them for review.
