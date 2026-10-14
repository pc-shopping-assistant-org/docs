# Physical compatibility reference

Các checks này bao phủ modeled metadata, không chứng nhận mọi khả năng lắp ráp.
Nguồn: [compatibility.py](../../../ai-service/src/ai_service/capabilities/pc_builder/compatibility.py).
Catalog thiếu data không được suy specs từ tên.

## Modeled checks

| Pair | Required condition | Missing data |
| --- | --- | --- |
| CPU/mainboard | Normalized socket matches | UNKNOWN |
| RAM/mainboard | Normalized RAM generation matches | UNKNOWN |
| Mainboard/case | Explicit supported_form_factors contains board form factor | UNKNOWN |
| Discrete GPU/case | GPU length <= case clearance | UNKNOWN |
| Cooler/case | Cooler height <= case clearance | UNKNOWN |
| Cooler/CPU | CPU socket supported by cooler | See gap below |

Có known data nhưng không thỏa rule → INCOMPATIBLE. UNKNOWN không là PASS.
Normalization trim/uppercase và bỏ space/hyphen; không suy Micro-ATX support chỉ vì
case khai báo ATX. Empty/blank support list không fallback form-factor rank.

## Integrated choices

Synthetic iGPU/stock cooler chỉ là internal choices grounded vào parent CPU,
không fake commerce SKU và không thay selected owned/pinned parts.

| Choice | Required evidence | Additional spending |
| --- | --- | --- |
| iGPU | Capability, graphics score và power metadata | 0 VND |
| Stock cooler | Included cooler, height/score và thermal metadata | 0 VND; see gap below |

Identity derive từ stable parent CPU identity; public output phải label integrated,
không tạo purchased variant ID.

## Known coverage limits

Chưa model BIOS/chipset, DIMM/SO-DIMM hoặc radiator fit.
RAM-slot count là scoring, không compatibility proof.
Power capacity theo [engineering reference](02-engineering-policies.md).

Existing implementation gaps phải giữ rõ: cooler socket còn fallback `cooler.socket`
khi thiếu supported_sockets; stock cooler còn cho phép thiếu TDP. Không mô tả desired
strictness như enforcement đã có.

**Related:** [Optimizer](../pc-build-optimizer.md) · [Hardware rules](../hardware-knowledge.md).
