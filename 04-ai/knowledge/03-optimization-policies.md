# Optimization policy reference

Trang này mô tả **current implementation**, không benchmark hoặc user requirements.
Source: [optimizer.py](../../../ai-service/src/ai_service/capabilities/pc_builder/optimizer.py),
[pruning.py](../../../ai-service/src/ai_service/capabilities/pc_builder/pruning.py).

## Budget envelopes

Sáu workload profiles có preferred/absolute budget envelopes để ưu tiên search order.
Đường all_affordable phải còn; envelope không hard-filter hoặc tự chia core/accessory budget.
Numeric tables lấy từ source/versioned snapshot, không duy trì một copy manual khác trong docs.

## Pareto pruning

Dominance cần price/metrics và feasibility-relevant compatibility không kém.
Không prune với missing comparison metrics hoặc khác physical interface.

CPU optional iGPU/stock-cooler capability phải được bảo toàn. Case support thay thế
phải explicit và cover support list bị loại. Mainboard không prune chỉ theo price khi
chưa có quality dimensions. Selected owned/pinned không được loại.

## MAUT scoring

Một build có normalized dimension scores, weights và contributions.
Sáu profiles × ba objectives PERFORMANCE/BALANCED/UPGRADE_FRIENDLY có weight configurations.
Positive-weight metric thiếu evidence → invalid score, không midpoint default.

Current source có `cost_efficiency`, khác khái niệm ngân sách chưa dùng.
Cost efficiency lấy CPU/GPU normalized performance trên effective spending; không FPS guarantee.

## Upgrade metrics — current source

| Metric | Current behavior |
| --- | --- |
| platform_longevity | Project socket-score mapping; weighted unknown socket rejects |
| ram_slots | >=4 slots score100, otherwise50 khi metadata có |
| psu_headroom | clamp(((W - sustained_peak) / W) / 0.50 ×100) |

Các score là project preferences, không dự báo tuổi thọ platform thực tế.

## Cost efficiency

`cost_efficiency` là dimension hiện được source tính:

```text
raw = (GPU normalized performance + CPU normalized performance)
      / max(1, spending in millions)
score = clamp(raw / 12 × 100, 0, 100)
```

Đây là hiệu năng CPU/GPU trên số tiền chi, không phải `budget_saving`; optimizer
không có dimension scoring riêng cho phần ngân sách còn dư.

Các công thức trên là scoring baseline đã chốt theo implementation hiện tại.
Thay đổi công thức cần cập nhật policy version và kiểm chứng ranking tương ứng.

## Stable ranking

Tie-break theo score, spending và stable component identities.
Missing IDs dùng functional fingerprint; synthetic IDs derive từ parent CPU.
Stability chỉ trong matching input/config/version/artifacts, không guarantee cross-version result.

Version/hash/config provenance phải giữ khi thay search/pruning/scoring.
No-result cần [sound scoped proof](../pc-build-optimizer.md), không model assertion.

**Related:** [Requirements](../requirements.md) · [Engineering policy](02-engineering-policies.md).
