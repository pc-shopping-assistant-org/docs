# P0 — Frozen contract baseline

Baseline 2026-10-07, source: `capabilities/assistant/stateful_contracts.py`.
Đây là contract legacy P0, không phải canonical requirement model mới.
Target/migration: [agent](agent-tools.md), [context](context-management.md).
Verification: [status](stateful-implementation-status.md).

## 1. Patch

TurnPatchV1 có schema_version=1; extra=forbid, typed discriminated SET/CLEAR.
Serialization dùng to_payload()/exclude_unset=True, không chèn null bằng default dump.
parse_turn_patch reject duplicate JSON keys và non-finite numbers trước Pydantic;
dict đã mất duplicate keys không chứng minh raw JSON hợp lệ.

| Input | Semantics |
| --- | --- |
| Absent field/group/slot hoặc empty group | No-op |
| SET với typed value | Thay toàn bộ field/binding |
| CLEAR không value | Unknown constraint hoặc gỡ binding |
| null, SET thiếu/null value, CLEAR có value | Reject |

Không nhận arbitrary paths, owner/run/checkpoint, phase/marker/source/lock metadata.
Validate patch **và final state** trước một atomic update.
SET/CLEAR locked USER field cần explicit instruction/confirmation; SYSTEM lock không tự mở.
Application cấp provenance sau source validation; extraction schema không tự cấp authority.
Lưu patch/evidence để không mất CLEAR intent.

| Constraint key | Type/bounds |
| --- | --- |
| target_budget_vnd | Strict integer VND >=0; không implicit minimum/default budget |
| use_case / target_resolution | Canonical enums |
| target_fps | Domain range 30–1000 |
| preferred_gpu_brand / preferred_cpu_brand / form_factor_preference | Strict nonblank string; canonical resolution riêng |

Không coercion string/boolean thành budget. CLEAR budget/use case cần clarification,
không kích hoạt PCBuildConstraints defaults.
Provider wire schema phải map explicit về contract; null không thành absent/CLEAR.
Exact method/strict options thuộc [model strategy](model-strategy.md).

```json
{
  "schema_version": 1,
  "constraints": {
    "target_budget_vnd": {"op": "SET", "value": 25000000},
    "preferred_gpu_brand": {"op": "CLEAR"}
  }
}
```

## 2. Owned/pinned refs

Core slots: CPU, MAINBOARD, RAM, GPU, PSU, CASE, COOLER, STORAGE; tối đa một binding/slot.
owned_parts/pinned_parts là sparse enum maps: SET thay binding, CLEAR gỡ, absent giữ nguyên.
Không owned/pinned overlap; chuyển loại bằng CLEAR+SET trong cùng atomic patch.

| DTO | Fields/invariant |
| --- | --- |
| PinnedPartRefV1 | variant_id UUID; category map key khớp catalog; paid |
| OwnedPartRefV1 | variant_id UUID; strict exclude_from_budget=true; spending=0 |
| ResolvedPartBindingV1 | category/kind, variant_id/SKU, ComponentSpec snapshot, catalog_price/spending_price, exclude flag, source/evidence |

Không nhận client price/stock/specs hoặc exclude=false/integer boolean cho owned.
Variant khác product ID/tên; purchased row thiếu canonical ID reject.
Resolver verify identity/category/visibility/stock; outside-catalog unknown hỏi lại,
không đoán ComponentSpec. Pin inactive/out-of-stock không substitute im lặng.

Giữ ComponentSpec.price làm giá tham chiếu, spending riêng.
OptimizerInputV1 gồm validated constraints, normalized catalog và objective.
Owned map OwnedComponent; pinned map hard pins giữ trước pruning, không giả owned
hoặc synthetic iGPU/stock cooler để thay pin.

## 3. Request, identity và checkpoint

TurnRequestV1: conversation_id UUID, request_id, strict nonnegative expected_revision,
nonblank message. Payload hash/idempotency transaction thuộc application.

Identity: RS256 với configured JWKS/issuer, audience pc-shopping-api, required time claims.
Token type=access; refresh rejected. accountId là owner UUID; sub là email.
Account phải ACTIVE. Owner lookup trước mọi state/message/run/checkpoint access.
UUID không credential; client không cấp owner hoặc checkpoint selector.

Checkpoint ref nội bộ giữ exact thread/checkpoint/namespace.
Frozen P0 baseline: revision=0 không accepted ref. Extension 0003 hiện cho phép
accepted initial root ở revision=0; public ConversationView có readiness.
[Initial-root target](context-management.md#initial-accepted-root--target-extension)
thay invariant này chỉ qua versioned migration.
Parsing stop evidence không chứng minh process death hoặc release thread.

## 4. V1 business policies

- Login-only; guest ngoài V1.
- BUILD_PC: core only. FULL_SETUP: core + monitor/mouse/keyboard/headset, tối đa một/type.
- Owned spending=0; pinned paid. Không implicit 80/20; budget/phụ kiện unclear thì hỏi.
- Eight-slot optimizer không tự optimize accessories; trừ resolved accessory spending
  trước core cap, không silently giảm FULL_SETUP thành core.
- Retention 90 ngày; orphan/debug 7 ngày nếu unprotected. User delete purge related
  messages/runs/checkpoints/provenance sau stop/drain.
- Debug/replay internal-only, không publish assistant result hoặc accepted head.

Cleanup/job/recovery implementation không được suy ra từ policy DTO.

## 5. Baseline acceptance IDs

| ID | Contract/rejection |
| --- | --- |
| B0-C01 | Sparse absent/SET/CLEAR/null và atomic merge |
| B0-C02 | Allowlisted keys/slots; client không sửa authority fields |
| B0-C03 | Owned/pinned strict refs và final-state conflict |
| B0-C04 | Required turn IDs/revision/message; payload mismatch |
| B0-C05 | Exact internal ref; published revisions require ref; revision-zero initial root |
| B0-C06 | Retryable/terminal khác nhau; typed stop proof identity/generation/UTC/drain |
| B0-C07 | Verified identity JWT + owner scope |
| B0-C08 | Login/budget/accessory/retention/replay policies |
| B0-C09 | Public allowlist, correlated SSE, spending/revision |
| B0-C10 | Versioned immutable optimizer provenance/config/result/hash |
| B1-G01 | New turn từ accepted A khi latest là orphan B |
| B1-G02 | First turn/reducers/marker reset/pending orphan/reopen/lineage |

Public DTO/SSE: [API](../05-api/stateful-chat-v1.md).
Tables/provenance: [DB](../03-data/ai-stateful-schema.md).
Native gate command/env: [README](../../ai-service/README.md).
Contract-only acceptance không chứng minh complete live runtime.
