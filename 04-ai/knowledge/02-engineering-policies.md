# Engineering policy reference

Policy `eng-power-sizing-v1` là power-sizing heuristic của dự án, không actual
measurement hoặc chứng nhận PSU/ATX. Source:
[optimizer.py](../../../ai-service/src/ai_service/capabilities/pc_builder/optimizer.py).

## Estimated load

Với CPU/GPU đã chọn có TDP metadata:

```text
cpu_peak = cpu_tdp × (1.20 nếu >=105W, ngược lại 1.10)
gpu_peak = gpu_tdp
sustained = cpu_peak + gpu_peak + 65W platform allowance
```

65W là fixed project allowance, không đo từng mainboard/fan/RAM.
Selected CPU/GPU thiếu TDP bị reject; không thêm guessed specs trong adapter.

## Transient allowance

| GPU | Factor × gpu_peak |
| --- | --- |
| Integrated | 0 |
| Discrete, TDP >=280W | 0.30 |
| Discrete, TDP >=180W | 0.20 |
| Discrete, lower TDP | 0.12 |

Factors là versioned estimates, không guarantee xử lý mọi real excursion.

## Supported PSU sizing

```text
minimum = round_up(sustained × 1.10)
recommended = round_up(sustained + transient + 50W)
ladder = 450, 500, 550, 600, 650, 750, 850, 1000, 1200W
```

Vượt ladder → diagnostic ValueError, không clamp về 1200W.
1200W là cap của project policy, không maximum PSU trên thị trường.
Minimum và recommendation có semantics khác nhau; không lấy recommendation làm actual power draw.

## PSU quality input

Tier mapping project dùng A=100, B=85, C=70, D=50; unknown tier → unknown metric.
Tier label không tự chứng minh topology/components/real safety của nguồn.
Weighted unknown metric không được chấm default trung bình để pass scoring.

## Versioning

Power estimate và reuse configuration giữ policy version. Đổi estimate/constants
phải có tests và invalidation; historical replay dùng snapshot/policy artifacts gốc.

**Related:** [Scoring policy](03-optimization-policies.md) · [Optimizer](../pc-build-optimizer.md).
