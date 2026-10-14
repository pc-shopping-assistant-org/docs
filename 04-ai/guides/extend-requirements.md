# Extend requirements

Thêm requirement bằng finite typed mapping, không thêm field hardcode theo một mẫu câu
hoặc generic DSL engine. [Requirements](../requirements.md) giải thích semantics.

## 1. Define the meaning

Chốt subject/predicate/operator/unit/strength và source evidence.
Ví dụ một capacity constraint khác một model preference; exact pin khác owned resource.

Xác định supported semantics và behavior khi input mơ hồ/metadata thiếu.
Không silently relax/drop requirement để optimizer trả được build.

## 2. Update extraction and resolution

Model chỉ tạo draft; canonical IDs do resolver/catalog quyết định.
Quantity normalization cần explicit unit; ambiguous reference cần offered options.

Nếu requirement mới cần metadata, cập nhật catalog DTO/mapping contract và canonical
snapshot trước. Không tạo default specs trong prompt/model output.

## 3. Update atomic state rules

Reuse CanonicalRequirementState/RequirementPatch trong
`capabilities/assistant/requirements/contracts.py`.
Giữ stable identities, absent/SET/CLEAR, source/consent và duplicate-operation rejection.
Một operation lỗi không apply các operations khác.

Đổi contract phải version/migrate hoặc reject legacy checkpoints rõ ràng.

## 4. Compile

Thêm mapping trong `requirements/compiler.py`.
Mỗi requirement có APPLIED/NEEDS_CLARIFICATION/UNSUPPORTED/CONFLICT; coverage đầy đủ.
Hard filters áp dụng trước pruning, gồm selected owned/pinned.

SOFT chỉ APPLIED khi scorer thực sự hỗ trợ. Schema nhận SOFT không chứng minh
runtime đã rank theo preference.

## 5. Verify independently

Thêm check trong `requirements/verifier.py` đọc original requirement và actual result.
Không chỉ assert compiler output hoặc tin optimizer success.

Test compiler cố tình sai/drop mapping vẫn bị verifier chặn publication.
Hash/version change phải invalidate dependent receipts/builds.

## 6. Check search semantics

Candidate filter/pruning/policy mới có thể ảnh hưởng completeness proof.
Valid build vẫn là feasible evidence; no-result chỉ INFEASIBLE khi sound scoped proof.
Không có proof thì SEARCH_INCOMPLETE, không global catalog absence.

## 7. Verify the user flow

Test extraction/resolution → merge → compile → optimizer → verifier → grounded publish,
plus important rejection: unsupported, ambiguity, no consent, stale artifact và atomic failure.
Native test nếu thay persisted state/reuse/version boundary.

Cập nhật requirement/API/data docs liên quan và tracker; dùng [Testing](../testing.md).
Không thêm solver/framework mới chỉ để support một predicate.

**Next:** [Optimizer](../pc-build-optimizer.md) · [Tool extension](add-tool.md).
