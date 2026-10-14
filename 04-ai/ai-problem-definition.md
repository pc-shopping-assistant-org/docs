# Introduction

AI service là backend tư vấn của gearPC. Người dùng không cần biết tên SKU:
họ có thể hỏi theo nhu cầu, so sánh sản phẩm hoặc yêu cầu một cấu hình PC.

Ví dụ:

> “Build PC 25 triệu để chơi game, RAM ít nhất 32GB. Tôi đã có nguồn.”

Service cần hiểu yêu cầu, tìm đúng sản phẩm trong catalog, kiểm tra ngân sách và
tương thích, rồi giải thích lựa chọn. Lượt sau user có thể sửa một yêu cầu mà
không phải nhập lại toàn bộ cấu hình.

## Design philosophy

**LLM quyết định cần làm gì tiếp; application quyết định điều gì được chấp nhận.**

- Agent có thể tìm kiếm, đọc dữ liệu, hỏi lại hoặc đề xuất thay đổi.
- Requirements được resolve và merge bằng application rules, không tin trực tiếp model output.
- Optimizer tính cấu hình từ candidates thật; model không tự dựng giá/spec/compatibility.
- State được lưu trước/sau các bước để phục hồi và tiếp tục hội thoại.
- Câu trả lời phải có evidence và đáp ứng task đã đăng ký.

Pydantic kiểm tra hình dạng dữ liệu. Nó không chứng minh model hiểu đúng user hoặc
mọi khẳng định trong prose đều đúng.

## Capabilities

| Người dùng cần | Cách xử lý |
| --- | --- |
| Tìm/hiểu sản phẩm | Catalog search/detail + grounded answer |
| So sánh | Canonical evidence của 2–5 products |
| Build/điều chỉnh PC | Requirements → deterministic optimizer → verifier |
| Hỏi về cấu hình đã tạo | Accepted build snapshot; không lấy giá mới thay lịch sử |
| Tra cứu web | Search → read → exact excerpts hoặc structured facts |
| Chưa rõ yêu cầu/sản phẩm | Clarification và continuation ở lượt sau |

Build PC mặc định là case PC. Full setup thêm màn hình/chuột/phím/tai nghe,
tối đa một mỗi loại; tự động chọn phụ kiện/soft scoring còn backlog, không phải
capability hoàn chỉnh. Không tự chia ngân sách 80/20.

## Scope

Stateful chat yêu cầu login. Memory nằm trong một conversation, không xuyên phiên/
conversation bằng Mem0. Agent chưa expose cart/order/payment mutation.

Compatibility checks chỉ bao phủ rules/metadata đã model, không là chứng nhận
mọi tổ hợp phần cứng. Không tạo FPS benchmark từ workload/profile hay scoring.
Model/provider/catalog thật có verification riêng; core fixtures không thay thế nó.

**Next:** [Architecture](../02-architecture/ai-architecture.md) → [First steps](getting-started.md).
