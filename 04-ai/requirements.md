# Requirements

Requirement state biểu diễn **điều user muốn**, không chỉ fields đã có của optimizer.
Model tạo draft; application resolve, merge và compile thành optimizer input.

Pipeline nằm trong proposal branch của ReAct, không bắt mọi read question đi qua nó:

```text
User message → Requirement draft → Reference/unit resolver
             → Atomic working merge → Canonical state
             → Versioned compiler → Optimizer → Satisfaction verifier
```

Catalog acquisition theo nhu cầu: ngân sách/workload, capacity, unit và CLEAR có
thể resolve/confirm trước khi gọi hardware backend. SKU/resource identity cần
canonical catalog; BUILD tải candidates sau khi prerequisite không phụ thuộc
catalog đã đủ. Sau working merge, graph kiểm tra lại điều kiện build.
Chưa tải catalog không phải bằng chứng `METADATA_INSUFFICIENT` hay variant bị thiếu;
graph và publication dùng chung policy này.

## Distinguish the meaning

| User says | Meaning | Current support |
| --- | --- | --- |
| RAM ít nhất 32GB | HARD capacity/GTE | Supported mapping khi metadata đủ |
| SSD đúng 1TB | HARD media/capacity/EQ | Supported mapping khi unit/media rõ |
| Ưu tiên RTX5070Ti | SOFT model preference | Bounded utility trên tên variant canonical; không pin SKU |
| Giữ đúng ASUS TUF RTX5070Ti OC | Exact paid SKU pin | Canonical variant binding bắt buộc |
| Tôi đã có nguồn này | Available resource | Chỉ thành selected owned khi yêu cầu sử dụng đã resolve |

Không ép tên linh kiện thành PINNED. Không nhận SOFT rồi bỏ qua ranking.
Owned spending bằng 0; pinned vẫn tính tiền và chịu budget/compatibility.

## Canonical state

Source model: [contracts.py](../../ai-service/src/ai_service/capabilities/assistant/requirements/contracts.py).

| Collection | Contains |
| --- | --- |
| `goals` | Budget/workload/setup goals |
| `requirements` | Typed subject/predicate/operator/value/strength |
| `available_resources` | Canonical parts user có |
| `resolved_bindings` | Requirement → variant identity + evidence |
| `unresolved` | Những phần chưa đủ thông tin |

Requirements có stable server-bound identity và source evidence. Value là quantity,
text hoặc canonical reference; không arbitrary expression/path/plugin DSL.

`requirements_hash` identifies content/semantics/IDs/evidence, không bookkeeping
revision/timestamps. Conversation revision dùng CAS; canonical `revision` trong
compatibility DTO không được dùng thay content equality.

## Draft and resolution

Current extractors have separate strict contracts: `TaskDraftBatch` contains
registered task candidates; `RequirementDraft` contains requirement items only.
The requirement schema rejects `tasks`. Historical combined `Draft` is retained
only to validate persisted V1 artifacts at compatibility boundaries; do not use it
for a current provider, catalog port, or graph input.

`RequirementDraft` giữ đề xuất và exact message span; extractor không tự tạo canonical SKU UUID.
Resolver kiểm tra message evidence, units, catalog identity/category/visibility.

- Product ID dành detail/compare; variant ID/SKU dành purchased/owned/pinned parts.
- Top-1 search hoặc model confidence không chứng minh uniqueness.
- Ambiguous/unknown variant giữ pending candidates; không đoán specs.
- TB/TiB, EQ/GTE, kit/module hoặc unit chưa rõ phải hỏi.
- CLEAR không cần tìm lại tên, nhưng vẫn cần bound source evidence.

Source span chứng minh text tồn tại, không tự chứng minh user intent.

## Atomic merge

| Operation | Effect |
| --- | --- |
| Absent | Giữ nguyên |
| SET | Thay typed value/binding được chỉ định |
| CLEAR | Gỡ requirement/resource với bound evidence |
| Null/malformed/unsupported | Reject hoặc typed clarification; không silent coercion |

Một operation lỗi thì không apply phần còn lại. Không nhận owner/checkpoint,
trusted source/locks từ model. Working merge không thay accepted snapshot/head.

Ví dụ user sửa SSD nhưng không nói RAM: giữ RAM. Khi draft còn ambiguous, giữ toàn bộ
artifact chưa merge; không apply budget trước rồi làm mất phần pin chưa resolve.

## Consent

Application phân biệt explicit user change với agent-authored proposal.
`propose_requirements` là lần diễn giải user message duy nhất. Model gửi items phẳng
và quote; application tính offset, resolve đơn vị/SKU và validate trước working merge.
Không gọi lại requirement extractor để diễn giải cùng câu. Receipt
`source-bound-draft-v2` bind run, message, base hash và draft; publication replay kiểm
tra lại receipt. Receipt `explicit-draft-match-v1` chỉ còn để đọc checkpoint cũ.
Quote hợp lệ không chứng minh mọi ý nghĩa model gán là đúng; unsupported/ambiguous
vẫn phải hỏi lại hoặc từ chối, không tự điền yêu cầu.

Agent-origin/inferred changes cần confirmation bound:

- `proposal_id`, `proposal_hash`;
- target publication revision;
- `base_requirements_hash`.

“OK” không xác nhận proposal khác hoặc nội dung đã bị sửa. Publication replay receipts
từ exact accepted/confirmed base, không tin terminal working state đơn thuần.

## Clarification and amendments

Pending artifact giữ original draft/task/source và offered options. Follow-up typed/
free-text choices được application validate và canonical recheck trước tiếp tục.

- Reference reply chọn offered variant; task reply chọn offered product.
- Unit reply xác nhận quantity/unit, không mất số gốc.
- Explicit edit/remove sửa unmerged item; untouched items giữ source/binding.
- REPLACE/DISCARD chỉ tác động pending artifact được bind, không tự xóa accepted requirements.
- DISCARD publish acknowledgement, không task completion, không model/tool call.

Pending agent draft resolve xong vẫn cần consent nếu nội dung requirements thay đổi.
Commands và binding shapes: [HTTP V2](../05-api/stateful-chat-v2.md).

## Compiler

`compile_requirements` là finite, versioned mapping từ canonical state tới existing
optimizer. Mỗi requirement phải có status: APPLIED, NEEDS_CLARIFICATION, UNSUPPORTED
hoặc CONFLICT. Không nhận requirement rồi bỏ ngầm.

Hard capabilities filter candidates trước pruning và kiểm tra selected owned/pinned.
Available resource không tự khóa slot. Compiler `requirements-v2` hỗ trợ SOFT
brand/model, RAM/storage capacity và storage media; predicate khác vẫn unsupported.
Metadata thiếu không tự biến thành no-solution proof.

Soft policy `equal-soft-utility-v1`: mỗi preference có trọng số bằng nhau; điểm cuối
= 90% utility phần cứng + 10% tỷ lệ preference thỏa. Không có preference thì giữ
nguyên scoring cũ. Unknown/unmatched được 0 điểm, không loại build; verifier ghi rõ
preference chưa thỏa. Category có preference match không bị Pareto prune mất ứng viên.
`model` chỉ match tên variant canonical đã chuẩn hóa, không suy ra benchmark hay pin SKU.

Compiler output/mapping/hash là provenance, không source of truth thay original state.

## Satisfaction verifier

Verifier đọc canonical requirements và actual build/evidence độc lập compiler projection.
Coverage/hash/version phải khớp; hard unmet/unknown không publish feasible success.
Supported soft unmet phải được disclose khi support được thêm.

Content hash đổi → invalidate dependent optimization/explanation, giữ historical build
có stale label. Reuse chỉ khi status COMPLETED, hashes/versions và validated result khớp.

## Budget scope

BUILD_PC: tám core slots. FULL_SETUP: core + monitor/mouse/keyboard/headset, tối đa
một mỗi loại. Không implicit 80/20. Resolved accessory spending trừ trước core cap;
chưa rõ budget/selection thì hỏi.

V2 dùng cùng canonical requirement pipeline, không bật lại runtime V1:

| Subject | Predicate/operator/value | Ý nghĩa |
| --- | --- | --- |
| SETUP | scope / EQ / TEXT FULL_SETUP | Cho phép thêm phụ kiện |
| SETUP | accessory_budget / LTE / QUANTITY VND | Cap phụ kiện do user cung cấp |
| MONITOR/MOUSE/KEYBOARD/HEADSET | identity / EQ / REFERENCE | Pin SKU, vẫn tính tiền |
| MONITOR/MOUSE/KEYBOARD/HEADSET | use_resource / EQ / REFERENCE | Reuse resource đã khai báo, chi phí 0 |
| MONITOR/MOUSE/KEYBOARD/HEADSET | selection / EQ / TEXT RECOMMEND | Chọn từ catalog, cần cap rõ ràng |
| MONITOR/MOUSE/KEYBOARD/HEADSET | brand / EQ / TEXT | HARD filter hoặc SOFT preference |

Draft identity vẫn là TEXT mention; resolver tìm UUID thật trước merge. Chưa rõ scope,
loại phụ kiện, cap hay SKU thì clarification; không tự thêm cả bốn loại hoặc chia 80/20.
Policy `explicit-cap-match-price-v1` lọc hard requirements/stock, tối đa hóa số soft
matches, rồi ưu tiên tổng giá thấp và UUID để tie-break. Không gọi giá thấp là chất
lượng tốt. Đây là staged selection rồi optimize core, **không** joint global optimum;
allocation tự chọn thất bại chỉ được báo SEARCH_INCOMPLETE, không chứng minh mọi setup vô nghiệm.
Monitor resolution/refresh-rate và accessory quality scoring chưa hỗ trợ: trả unsupported,
không tự suy diễn từ tên. Public snapshot lưu đủ core/phụ kiện, giá và ownership gốc;
history dùng lại snapshot, không tái dựng bằng catalog hiện tại.

**Next:** [Build consultation](guided-selection.md) · [Extend requirements](guides/extend-requirements.md).
