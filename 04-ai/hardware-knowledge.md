# Hardware rules and policies

Compatibility, power estimation và ranking là ba loại rules khác nhau.
Không gọi heuristic/policy là physical ground truth.

| Layer | Purpose | Reference |
| --- | --- | --- |
| Physical/model constraints | Socket, DDR, form factor, clearances và evidence requirements | [Physical checks](knowledge/01-physical-ground-truth.md) |
| Engineering policy | Estimated power, margins, supported PSU sizing ladder | [Engineering policy](knowledge/02-engineering-policies.md) |
| Optimization policy | Search ordering, pruning, scoring và tie-break | [Optimization policy](knowledge/03-optimization-policies.md) |

## Physical checks

Thiếu metadata → UNKNOWN, không COMPATIBLE. Explicit case support không được suy
chỉ từ form-factor rank. Synthetic iGPU/stock cooler phải grounded vào CPU evidence,
không tạo fake purchased SKU.

## Engineering policy

TDP/power/margins là versioned estimates, không đo actual load hoặc certification PSU.
Policy cap là giới hạn của dự án, không giới hạn thị trường.
Numeric formulas ở policy reference, không copy vào agent/flow pages.

## Optimization policy

Envelope ưu tiên search order, không user hard budget split. Pruning không được làm
mất capability/compatibility; missing metrics không tạo dominance.
Weights/upgradability scores là project policy, không benchmark promise.

## Change a rule

Đổi modeled compatibility hoặc policy version phải cập nhật source, tests và
provenance/reuse hashes. Historical builds giữ policy snapshot; không replay bằng
policy hiện tại rồi coi là kết quả gốc.

**Next:** [Optimizer](pc-build-optimizer.md) · [Requirements](requirements.md).
