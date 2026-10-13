# AI problem definition

## Scope

Trợ lý giúp khách tìm, so sánh, hiểu sản phẩm và xây dựng cấu hình PC từ catalog
thật qua hội thoại nhiều lượt. Ngôn ngữ đầu vào có thể mô tả capacity, budget,
workload, preference hoặc exact SKU; không thiết kế state theo từng mẫu câu.

V1 login-only, BUILD_PC mặc định chỉ case PC; FULL_SETUP thêm màn hình/chuột/phím/
tai nghe, tối đa một loại một cái. Owned không tính purchase spending; pinned vẫn
tính tiền. Không tự chia ngân sách core/phụ kiện. Ambiguous/unsupported yêu cầu
phải được phản hồi, không silently drop hoặc relax.

## Bài toán

- User intent/reference/unit có thể mơ hồ; typed extraction không tự chứng minh intent.
- Product khác variant; model không được đoán UUID/giá/stock/specs.
- Tổ hợp linh kiện phải thỏa ngân sách, capability và modeled compatibility.
- Soft preferences ảnh hưởng ranking, không tự biến thành hard pin.
- Multi-turn phải giữ accepted state, history và previous build qua reload/restart.
- Failure/retry không duplicate publication hoặc mở concurrent execution trên thread.

## Giải pháp

LLM tạo requirement draft và chọn bounded read/build tools. Deterministic services
resolve references/units, merge canonical requirements, compile thành optimizer
input và independently verify kết quả. LLM không ráp build hay quyết định ownership.

```text
Draft → Resolver → Atomic Merge → Canonical State → Compiler
→ Deterministic Optimizer → Satisfaction Verifier → Grounded Explanation
```

Optimizer core được model hóa thành Multiple-Choice Knapsack với pairwise
compatibility constraints và MAUT scoring. Formulation/algorithm nằm một nơi tại
[PC build optimizer](pc-build-optimizer.md), không lặp lại trong overview.

## Giới hạn và đánh giá

COMPATIBLE chỉ áp dụng checks/metadata đã model, không certification tất cả hardware.
Performance goals/FPS không phải benchmark guarantee; thiếu evidence không bịa số.
Không claim latency hay “100% correctness” từ test counts. Core acceptance gồm
paraphrase/unit/merge coverage, fault-injected compiler, valid/infeasible builds,
accepted-vs-orphan recovery, stop/fencing/publication races và ownership.

[Architecture](../02-architecture/ai-architecture.md) ·
[Tools](agent-tools.md) · [State/recovery](context-management.md) ·
[Evidence](stateful-implementation-status.md)
