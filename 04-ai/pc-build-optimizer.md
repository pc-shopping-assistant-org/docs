# PC optimizer

Optimizer chọn cấu hình từ canonical candidates trong budget và modeled compatibility.
Đây là deterministic core, không LLM agent và không network/DB client.
Source: [pc_builder](../../ai-service/src/ai_service/capabilities/pc_builder/).
Theo một user flow ở [Build consultation](guided-selection.md).

## 1. Mathematical model

Core có tám slots CPU, mainboard, RAM, GPU, storage, PSU, case, cooler.
Chọn một candidate mỗi slot, bao gồm CPU-grounded synthetic iGPU/stock cooler
nếu metadata đủ. FULL_SETUP accessories được application xử lý ngoài core này.

Với candidate set N_k, biến nhị phân x_kj và effective spending c_kj:

```text
Σ_j x_kj = 1                         cho mỗi slot k
Σ_k Σ_j c_kj × x_kj ≤ purchase_budget
x_u + x_v ≤ 1                       cho mỗi cặp incompatible (u, v)
PSU.wattage ≥ required_capacity(chosen CPU/GPU/platform)
maximize Σ_m weight_m × normalized_metric_m(build)
```

Đây là Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints
(MCKP-PCC) cùng dynamic power constraint; scoring theo MAUT.
Reference price khác purchase spending: selected owned=0, pinned=reference price.
Số tổ hợp là tích candidate counts, không gán một quy mô catalog/latency cố định.

## 2. Input/compiler boundary

build_pc nhận canonical requirements qua trusted context. Compiler versioned trả
optimizer input và exhaustive mapping report. Hard capabilities filter candidates
trước pruning, gồm kiểm tra selected owned/pinned. Exact pin không bị substitute.
Unknown/unsupported/conflict không phải INFEASIBLE; chỉ valid supported execution
không có nghiệm mới trả typed no-feasible-build outcome.

Available resource không tự khóa slot. Explicit selected binding mới compile
thành owned_parts. Engine không tự suy ý định hay tự bỏ requirement.
[Requirement/verification contract](requirements.md).

## 3. Search and pruning

### Candidate pools / envelopes

CandidatePool giữ preferred và all_affordable. Envelope chỉ ưu tiên thứ tự duyệt,
không hard filter linh kiện nằm ngoài tỷ lệ dự kiến. Phải giữ đường tìm kiếm
all_affordable; không dùng envelope để tự chia ngân sách core/phụ kiện.

### Pareto dominance

So sánh theo profile/objective, giá và feasibility-relevant dimensions.
Không prune khác socket/RAM/form-factor, không prune dựa trên missing metrics.
CPU dominance phải bảo toàn optional iGPU/stock-cooler capabilities, performance/
power/clearance evidence; CPU thiếu năng lực không loại CPU cho phép nghiệm 0đ.
Mainboard không prune chỉ theo giá khi chưa có đủ dimensions chất lượng.
Candidate giữ nếu còn giá trị trên ít nhất một objective.

### Branch-and-bound / zero-cost choices

Duyệt tổ hợp, cắt early conflicts và branches vượt budget. Sau append synthetic
candidates, sort lại bằng effective spending và stable identity; không break ở
candidate đắt rồi bỏ qua zero-cost candidate phía sau.
Selected owned/pinned phải được giữ trong candidate pools/pruning.

### Compatibility/power

Chỉ modeled COMPATIBLE build được rank; UNKNOWN không thành pass. Checks gồm
CPU/mainboard socket, RAM generation, case supported_form_factors explicit membership,
GPU length, cooler height/socket và PSU capacity. iGPU bỏ GPU-length check nhưng
vẫn cần CPU evidence. Missing CPU/GPU TDP hoặc clearance không dùng guessed specs.

Case support thiếu/rỗng/giá trị trắng → UNKNOWN, không suy từ case.form_factor.
Pruning chỉ thay case khi support list đã biết và bao phủ toàn bộ list của case bị loại.
Nếu không tìm được build và gặp case thiếu support trong nhánh còn ngân sách,
raise CaseSupportMetadataError (`CASE_SUPPORT_METADATA_REQUIRED`), không INFEASIBLE.
Nếu vẫn có build hợp lệ, trả build từ các candidate đã xác minh; ghi case thiếu specs
vào rejected_candidates. Không khẳng định tối ưu trên cả candidate chưa xác minh.
Reuse hash ghi policy `case_compatibility_version=explicit-support-v1`.

Power estimation là versioned heuristic, không đo tải thực tế.
[Physical checks](knowledge/01-physical-ground-truth.md) và
[engineering policy](knowledge/02-engineering-policies.md) là nơi giữ formulas.
Power policy `eng-power-sizing-v1`: iGPU transient=0, GPU rời giữ ngưỡng TDP;
reuse configuration ghi power_sizing_version. Không replay bằng policy hiện tại
thay cho policy snapshot lịch sử.

## 4. Scoring, recommendation and identity

MAUT normalize metrics và weights cho sáu profiles × ba objectives PERFORMANCE,
BALANCED, UPGRADE_FRIENDLY. ScoreBreakdown gồm raw_value, normalized_score,
weight và contribution. Metric có positive weight nhưng thiếu evidence làm build
invalid, không gán điểm trung bình ngầm.

Scoring dimensions hiện gồm `cost_efficiency` và các upgrade metrics
`platform_longevity`, `ram_slots`, `psu_headroom`. Không có `budget_saving` riêng.
Weights/normalization và công thức baseline ở
[optimization policy](knowledge/03-optimization-policies.md); cập nhật policy
version khi đổi chúng.

OptimizationResult trả ranked builds theo objective; recommendation policy ở
application chọn objective, không nhét recommended_build mặc định vào core.
Tie-break theo score/price/stable component identities. Missing IDs dùng canonical
functional fingerprint; synthetic identity derive từ CPU. Commerce-facing SKU vẫn
phải canonical variant ID; fingerprint không tạo fake commerce identity.

## 5. Verification and replay

Independent satisfaction verifier đọc canonical requirements và result/evidence,
không chỉ compiler projection. Mapping coverage/hash phải match, hard unmet/unknown
không publish feasible success; supported soft unmet được disclose.
Facts/financial totals server render từ validated result; prose không sửa build.

Provenance snapshot lưu catalog payload/hash, ordered normalized candidates,
effective spending, constraints revision, compiler/engine/scoring/recommendation
versions, configs/weights/tie-break và typed result/hash. Replay dùng snapshot +
matching artifacts; không live-catalog/current-config fallback, không publish.

Acceptance: pruning-on/off equivalence trên fixtures, shuffle determinism,
CPU optional capabilities, zero-cost ordering, pinned/owned spending, missing
metrics/overflow rejection và faulty-compiler omission rejection. Native recovery/
publication không được suy từ optimizer unit tests.
[Status/evidence](stateful-implementation-status.md) ghi commands và phạm vi proof.

Quyết định lịch sử: [ADR-004](../02-architecture/decisions/ADR-004-pc-optimizer.md).
