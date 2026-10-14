# State contract reference

Canonical requirement contracts and legacy consultation/patch contracts coexist in source.
They are not two writable sources of truth or interchangeable HTTP request schemas.

## Current requirement contracts

Source: [requirements/contracts.py](../../ai-service/src/ai_service/capabilities/assistant/requirements/contracts.py).

| Model | Fields / invariant |
| --- | --- |
| Requirement | Stable id, subject, predicate, EQ/GTE/LTE, typed value, HARD/SOFT, bound evidence |
| QuantityValue | Strict nonnegative integer amount + canonical unit |
| TextValue | Nonblank text |
| ReferenceValue | Canonical variant UUID |
| Resource | Canonical available variant + source evidence |
| Binding | Existing requirement ID → variant ID + evidence refs |
| CanonicalRequirementState | goals/requirements/resources/bindings/unresolved; unique matching identities |
| RequirementPatch | Explicit SET/CLEAR lists by stable identity; no duplicate/conflicting operations |

Every CLEAR needs bound evidence. Value/source/identity/authority validation precedes
atomic merge. Requirements hash excludes compatibility revision but includes content/
semantics/stable IDs/evidence. [Requirement concepts](requirements.md) define meaning.

Public V2 turn commands are in [HTTP V2](../05-api/stateful-chat-v2.md);
canonical patch is internal application contract, not arbitrary client mutation API.

## Legacy P0 patch

Source: [stateful_contracts.py](../../ai-service/src/ai_service/capabilities/assistant/stateful_contracts.py).
TurnPatchV1 schema_version1 uses discriminated SET/CLEAR and sparse groups.
Serialization preserves absent fields; raw parsing rejects duplicate JSON keys and
non-finite numbers. A parsed dict cannot prove raw duplicate-key safety.

| Input | Meaning |
| --- | --- |
| Absent field/group/slot, empty group | No-op |
| SET with typed value | Replace field/binding |
| CLEAR without value | Unknown constraint/remove binding |
| Null, malformed SET/CLEAR | Reject |

No arbitrary paths, owner/checkpoint or authority metadata. Validate patch and resulting
state atomically. User/system locks cannot be opened by model inference.

### Legacy constraint fields

| Key | Type |
| --- | --- |
| target_budget_vnd | Strict integer VND>=0; no implicit budget |
| use_case/target_resolution | Canonical enum |
| target_fps | Domain range30–1000, not benchmark promise |
| preferred_gpu_brand/preferred_cpu_brand/form_factor_preference | Nonblank text; mapping/resolution separate |

CLEAR required budget/workload asks clarification, not optimizer defaults.
Provider wire schema maps explicitly; null does not become absent/CLEAR.

### Legacy owned/pinned bindings

Core slots: CPU/MAINBOARD/RAM/GPU/PSU/CASE/COOLER/STORAGE, one selected binding/slot.
Sparse SET replaces, CLEAR removes, absent preserves. No owned/pinned overlap.

Pinned variant spends reference price. Owned has strict exclude_from_budget=true and
spending0; price/specs/stock are canonical snapshots, never client-supplied.
Resolved binding keeps category/kind, SKU/spec snapshot, reference/spending and evidence.

Pins survive pruning and cannot silently substitute iGPU/stock cooler.
Available resource requires explicit selected binding to become optimizer owned.

## Identity and native refs

RS256 access JWT with configured JWKS/issuer/audience/time claims, accountId owner,
access type and ACTIVE status. UUID/sub alone is not permission.
Client cannot choose thread/checkpoint or stop evidence.

Internal CheckpointRef has exact thread/namespace/checkpoint. READY revision0 may have
validated initial root (extension0003); populated legacy no-head requires explicit policy,
not blind adoption. [State/recovery](context-management.md#initial-accepted-root).

## Public snapshots

Public consultation/build/answer allowlist facts/bindings/spending and stale/historical
status. No internal stage markers, raw provenance, worker/proof/lease or native refs.
Integrated choices have no fake commerce SKU; history does not refresh prices.

BUILD_PC/FULL_SETUP, consent and unsupported semantics live in [requirements](requirements.md).
Deletion/retention/debug policy does not imply a running cleanup/replay adapter.

## Version compatibility

HTTP V1 fields are not V2 aliases. Native bases and pending artifacts require supported
graph/schema versions; incompatible shapes migrate or fail clearly, not reinterpret defaults.
Hash integrity does not prove semantic truth or source authenticity.

**Related:** [HTTP reference](../05-api/stateful-chat-v2.md) · [Database](../03-data/ai-stateful-schema.md).
