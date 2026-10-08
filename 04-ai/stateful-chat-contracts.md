# Stateful chat — B0 contract baseline

Status: COMPLETED — P0 contract baseline, 2026-10-07; runtime remains pending.
Architecture remains plan revision 8;
revision 18 approves canonical requirement state → versioned compiler → existing optimizer → satisfaction verifier, alongside prior review gates and approved
V1 budget/retention policies and phased work.
Scope: UC-AI-001/003 and the approved PC-builder extension.

Review pause 2026-10-09: see [implementation status](stateful-implementation-status.md).
Owner reported native foundation and initial-root experiment PASS. Root production
initialization/CAS and the P0 revision-zero contract below remain unchanged.

This document describes the new contracts, NOT live HTTP endpoints or durable
state already running. Existing chat requests/responses remain unchanged.
Source: `ai-service/src/ai_service/capabilities/assistant/stateful_contracts.py`.
The approved requirement-centric model is a P3 extension, not the implemented P0
baseline. New state/draft/merge schemas and legacy checkpoint migration must be
versioned and tested before runtime replacement; no completion status changes here.

## Acceptance before implementation

| ID     | Contract / rejection                                                                                                                | Verification / remaining work                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| B0-C01 | Sparse patch: absent preserves; SET has typed value; CLEAR has no value; explicit null rejected                                     | Schema + P1 atomic merge/provenance/lock tests pass; B2 runtime integration pending             |
| B0-C02 | Only approved constraint keys/core slots; no phase/source/checkpoint/owner fields from client or LLM                                | extra=forbid and rejection tests                                                              |
| B0-C03 | Owned ref has variant ID and strict exclude flag; pinned ref cannot contain price/specs/exclude flag                                | Schema + P1 final-state conflict tests pass; backend resolution/category/stock remain B2/B3    |
| B0-C04 | Turn requires conversation ID, request ID, non-negative integer expected revision and non-blank message                             | Unit tests; request hash/idempotency transaction belongs to B4                                |
| B0-C05 | Internal accepted ref has exact thread/checkpoint/namespace; revision zero has no accepted ref                                      | Unit tests; native lineage validation and CAS publication are NOT implemented by this DTO     |
| B0-C06 | Retryable vs terminal run failures are distinct; typed stop evidence requires identity/generation/UTC time/drained writes/proof ref | Unit tests; parsing evidence does NOT prove process death or release a thread                 |
| B0-C07 | Owner comes from verified RS256 access JWT, not user body/header/UUID                                                               | Auth/owner tests pass; native foundation owner PASS, ISSUE-091 resolved; live JWKS not verified |
| B0-C08 | Login-only; BUILD_PC/FULL_SETUP; one accessory/type; owned free, pinned paid; approved retention/internal replay                     | Policy DTO/merge tests pass; ISSUE-079/080/081 resolved; cleanup/runtime pending                 |
| B0-C09 | Public DTO allowlist, correlated SSE envelope, owned spending and publication revision                                            | public_contracts.py + core tests; route/journal/publish remains P2–P5                         |
| B0-C10 | Versioned optimizer provenance, canonical hash, explicit input/config/results and synthetic evidence                               | provenance.py + real optimizer snapshot/restore/hash rejection; replay adapter remains P3/P4 |
| B1-G01 | Native new turn starts from accepted A despite latest orphan B                                                                      | Original gate and production adapter extension owner-reported PASS 2026-10-09                  |
| B1-G02 | First turn, reducers, old publication reset, terminal/pending orphan and pool reopen preserve lineage                               | Original gate owner PASS; app DB CAS/finalization and execution recovery remain required       |

## Patch wire contract

`TurnPatchV1` requires integer `schema_version=1`. Canonical serialization uses
`to_payload()` (`exclude_unset=True`), not a default model dump that inserts null.
An empty group is a no-op, not clear-all. JSON duplicate keys and non-finite
numbers are rejected by `parse_turn_patch` before model validation. A dict whose
parser already discarded duplicate keys cannot retroactively prove their absence.

SET money uses strict integer VND >= 0; this is a shape constraint, not approval
of any minimum spending/budget policy. FPS reuses the current 30–1000 domain
range. Use-case/resolution reuse canonical enums. Brand/form-factor values are
strict non-empty strings; normalization/allowed catalogs are not inferred here.

Owned/pinned use canonical variant IDs only. V1 owned always has spending zero
and exclude_from_budget=true; pinned remains paid. The schema rejects false and
integer boolean substitutes. Missing metadata or final owned/pinned overlap is resolved or
rejected in B2/B3, never by inventing specs or treating pinned as owned.

No merge execution, readiness defaults, optimizer wiring, provenance snapshot,
authorization or checkpoint publication is implemented by these schema classes.
Typed replay contracts now live in `provenance.py`; runtime capture/catalog adapters
remain P3 work. Do not treat accepting a patch shape as accepting a build.

## Structured output wording

The canonical schema is an application contract. Direct chat-model structured
output can use it only if the pinned integration/provider supports the schema
subset and sparse semantics. Otherwise a provider wire DTO must map explicitly
to it, with contract tests. Optional canonical fields may appear nullable in JSON
Schema, but explicit null is rejected at runtime: do not silently turn provider
null into absent/CLEAR. No provider method/strict option is approved by this
schema-only work. ProviderStrategy/ToolStrategy/create_agent remain out of scope.

## Identity / access boundary

Verified against current identity/common-lib source:

- Only RS256 with the configured identity JWKS/issuer and audience
  `pc-shopping-api`; expiration/time validation and required claims are mandatory.
- Identity access token `type=access`; refresh token `type=REFRESH` is rejected.
- `accountId` is the UUID identity claim. `sub` is email, NOT an account UUID.
- Account status must be ACTIVE (current resource servers compare case-insensitively).
- Conversation owner checks happen before state/message/run/checkpoint access.
  No owner field or arbitrary checkpoint selector is accepted in TurnRequestV1.
- Internal refs/evidence never become public DTOs or client-provided proof.

No new endpoint is exposed and existing routes are not claimed secure by this
document. V1 login-only was approved by the owner on 2026-10-07; guest is deferred.
Runtime JWT/ownership enforcement still belongs to B1 and is not implemented here.

## Approved V1 budget scope

Owner finalized this policy on 2026-10-07, superseding the earlier universal
total-setup wording:

- BUILD_PC (default): budget covers only the PC case/core build.
- FULL_SETUP: budget covers PC plus monitor, mouse, keyboard and headset.
- V1 allows at most one of each accessory type.
- Never allocate 80/20 or any implicit ratio. Ask the user if accessories are
  required but their budget is unclear; do not invent a minimum budget or prices.
- Owned means already possessed, spending=0. Pinned must remain selected and
  still counts toward spending. Do not convert pinned into owned to fit budget.

The existing optimizer only models eight core slots. Do not forward the entire
setup cap as its core cap when accessories consume money or claim accessories
were optimized. Multi-device/quantity peripheral DTOs, allocation/recommendation
policy DTOs are implemented; optimizer/accessory runtime mapping remains P3.
ISSUE-080's requirement is
resolved, not its runtime implementation. Never silently reduce FULL_SETUP to core.

## Approved V1 retention and replay

- Chat/run/checkpoint retention: 90 days.
- Orphan/debug checkpoint retention: 7 days.
- User deletion of a conversation deletes all related data, including messages,
  runs, checkpoint data and associated replay/provenance payloads.
- Debug/replay is internal only; ordinary users have no debug/replay access.
- Replay cannot publish a real conversation result, assistant message or
  accepted head. Internal access is not permission to bypass this rule.

ISSUE-081's policy is resolved. Cleanup/deletion and authorization remain P2/P4/P5
implementation work; stop/drain running executions before deletion. Checkpoints
needed by accepted/recoverable lineage must not be misclassified as orphan.

## B1 execution gate

Owner approved using local `ai_db` in the existing backend PostgreSQL compose,
not a separate test database. See AI-service README for safe existing-volume
provisioning. The gate creates native saver tables and random experiment threads;
it does not drop/reset the DB and must not run against production data:

```bash
# AI_TEST_POSTGRES_DSN points to local ai_db; actual credentials stay out of git.
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q \
  integration_tests/test_accepted_head_postgres.py
```

The gate intentionally does not skip when its DSN/dependencies are missing.
Default unit discovery is `tests/`; the B1 integration command is a separate,
mandatory acceptance gate, not replaced by a green unit suite.

Selected semantics: native new input with explicit accepted checkpoint config.
The owner reported the original corrected native gate passing. It checks accepted
state vs terminal/pending orphan, invocation counts, marker reset and native
ancestor chain after closing/reopening the saver. No application head is selected
from latest, copied values or a new execution thread.

Update 2026-10-09 (owner-reported): migration, saver bootstrap and the full
`integration_tests` directory passed after the dotenv fix. This covers the
production adapter extension, native owner/scoped-constraint persistence,
resource reopen and call-reservation race/reopen gates. ISSUE-091 is resolved;
the agent cannot independently reach local PostgreSQL in this sandbox. Initial
root recovery, run admission/finalization and live JWT/JWKS/provider verification
are not covered. Earlier pending gate entries above are superseded by this evidence.

Detailed next-step review: [ReAct and tool architecture](stateful-react-tools-design.md).

## P1 deterministic core evidence (2026-10-07)

`ai-service/src/ai_service/capabilities/assistant/conversation_core.py` defines versioned unknown
state, atomic merge, trusted application provenance/confirmation, owned/pinned
conflict checks and explicit completion markers. Reuse requires COMPLETED,
validated result, matching input hash and versions; changed requirements reset
markers while preserving a stale historical successful build.

Nine core scenarios pass, including real optimizer outcomes and total-setup
budget subtraction after accessory spending is resolved. Full local suite:
210 passed; mypy 85 files, Ruff and lock check pass. This does not implement
hash/provenance snapshot generation, accessory allocation, auth, graph persistence,
thread admission or publish/CAS. Those remain P2–P5 work; no durable claims.

## P0 delivery

Public routes/HTTP statuses/error semantics/SSE and scope/clarification behavior:
[Stateful chat V1 API contract](../05-api/stateful-chat-v1.md).
Application DB keys/checks/indexes/transaction and saver ownership:
[AI schema contract](../03-data/ai-stateful-schema.md). These are contracts, not
live routes/migrations. Existing HTTP behavior is unchanged.

Models: `stateful_contracts.py` for sparse scope/accessory refs, `conversation_core.py`
for validated state/merge, `public_contracts.py` for allowlisted public views and
typed events, `provenance.py` for internal snapshots. No new dependency/runtime layer.
Full regression/static evidence is maintained in USECASE_IMPLEMENTATION.md.
