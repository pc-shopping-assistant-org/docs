# Build consultation

Guide này theo một cuộc hội thoại build PC. Nó minh họa cách agent/tools/requirements
kết hợp, không thay contract của [optimizer](pc-build-optimizer.md).

## Start with a requirement

> “Build PC 25 triệu để chơi game 1440p, RAM ít nhất 32GB.”

Application đăng ký BUILD task. Agent có thể hỏi thêm hoặc tạo requirement proposal:
budget, workload và RAM capacity có evidence từ user message.

Không lấy model confidence làm authority. Draft được normalize/resolve; chỉ một
complete supported draft mới merge atomic vào working requirements.

## Resolve a named part

> “Giữ đúng ASUS TUF RTX5070Ti OC.”

Đây là exact pin nếu user yêu cầu giữ đúng variant, không chỉ soft preference.
Resolver phải tìm canonical variant/SKU. Nhiều matches → offered options và WAITING_INPUT;
không chọn top-1. User reply được bind vào original pending artifact rồi recheck catalog.

“Ưu tiên RTX5070Ti” là soft preference khác pin. Scorer hiện chưa support sẽ trả
unsupported/clarification, không âm thầm biến thành hard binding.

## Build

Khi đủ supported requirements và canonical candidates:

1. Compiler map requirements và kiểm tra coverage.
2. `build_pc` gọi PCBuildApplicationService/optimizer.
3. Compatibility/scoring chọn builds trong supplied scope.
4. Independent satisfaction verifier kiểm tra original hard requirements.
5. Server render parts/spending/totals; model thêm evidence-linked qualitative explanation.

Hardware snapshot tải khi build/resolve cần, không mỗi lượt đọc thông tin.
Không có metadata tương thích thì không fabricate specs để hoàn thành task.

## Interpret the result

| Outcome | User-facing meaning |
| --- | --- |
| BUILT | Có cấu hình đã verify trong candidate scope |
| INFEASIBLE | Có proof không có nghiệm trong scope đã xét |
| SEARCH_INCOMPLETE | Chưa tìm được nghiệm; không chứng minh không tồn tại |
| Clarification/unsupported | Cần input/metadata/policy trước khi build |
| Dependency unavailable | Catalog/provider lỗi, không phải no-solution |

Không hứa “mọi game 1440p mượt” hoặc FPS từ optimization score.

## Change one requirement

> “Đổi CPU sang Intel, giữ nguyên RAM.”

Run mới load accepted state/history; chỉ thay requirement có source hợp lệ.
Content hash đổi invalidate dependent build/explanation; untouched requirements giữ nguyên.
Agent tự đề xuất hạ RAM cần immutable confirmation, không auto-merge.

Failed/cancelled/CAS-conflicting run không overwrite accepted build.
Lượt sau vẫn đọc state đã publish, không latest working/orphan checkpoint.

## Use an owned part

> “Tôi có nguồn này, dùng lại nó cho build.”

Canonical resource cần identity/specs đủ; selected owned spend=0, reference price vẫn giữ.
Nguồn vẫn chịu modeled compatibility. Resource ngoài catalog chưa resolve được phải
hỏi/báo unsupported; không fake metadata.

## Explain the previous build

> “Tại sao cấu hình trước dùng CPU đó?”

Dùng authorized accepted snapshot; historical costs không refresh bằng giá catalog mới.
Build stale có nhãn rõ. Saved explanation không satisfy một BUILD task mới.
Chọn arbitrary older run và full historical accessories còn backlog.

## Full setup

Full setup gồm core và tối đa một monitor/mouse/keyboard/headset.
Không tự chia ngân sách 80/20; hỏi khi accessory budget/selection chưa rõ.
Automatic ranking và full historical projection chưa hoàn chỉnh;
xem [Requirements](requirements.md#budget-scope).

**Next:** [HTTP V2](../05-api/stateful-chat-v2.md) · [Testing](testing.md).
