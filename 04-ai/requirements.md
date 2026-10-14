# Requirements

Requirement state biểu diễn **điều user muốn**, không chỉ fields đã có của optimizer.
Model tạo draft; application resolve, merge và compile thành optimizer input.

Pipeline nằm trong proposal branch của ReAct, không bắt mọi read question đi qua nó:

```text
User message → Requirement draft → Reference/unit resolver
             → Atomic working merge → Canonical state
             → Versioned compiler → Optimizer → Satisfaction verifier
```

## Distinguish the meaning

| User says | Meaning | Current support |
| --- | --- | --- |
| RAM ít nhất 32GB | HARD capacity/GTE | Supported mapping khi metadata đủ |
| SSD đúng 1TB | HARD media/capacity/EQ | Supported mapping khi unit/media rõ |
| Ưu tiên RTX5070Ti | SOFT preference | Scorer chưa support → explicit unsupported/clarify |
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

Draft giữ đề xuất và exact message span; extractor không tự tạo canonical SKU UUID.
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
Một independent extractor có thể kiểm tra draft thực sự được user message hỗ trợ;
resolved matching receipt mới cho working merge. Đây vẫn là model-based semantic
assessment, không deterministic guarantee về intent.

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
Available resource không tự khóa slot. Soft scorer chưa implemented thì unsupported.
Metadata thiếu không tự biến thành no-solution proof.

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

Full automatic accessory selection, historical full-setup projection và soft ranking
còn [roadmap](stateful-chat-implementation-plan.md), không claim support đầy đủ từ schema.

**Next:** [Build consultation](guided-selection.md) · [Extend requirements](guides/extend-requirements.md).
