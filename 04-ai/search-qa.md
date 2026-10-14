# Research a question

Guide này dùng hai web tools để tra cứu, đọc nguồn rồi trả lời với evidence.
[Web research](web-research.md) giải thích parser/fact contracts.

## Example question

> “RTX4070Super chơi Black Myth Wukong 1440p được bao nhiêu FPS?”

1. Agent gọi `search_web` với model/game/resolution.
2. Chọn nguồn benchmark phù hợp, không lấy snippet làm answer.
3. Gọi `read_web_page`; đọc tiếp segment nếu phần cần thiết chưa xuất hiện.
4. Kiểm tra đúng model/game/resolution/preset/upscaling và bảng/quote nguồn.
5. Trả supported typed fact nếu contract/parser hỗ trợ; nếu không, exact labelled
   excerpt/citation hoặc insufficient evidence, không tự dựng số FPS.

**Giới hạn hiện tại:** curated facts cover dimensions, chưa có benchmark DTO/parser
hoàn chỉnh. Đọc được bài benchmark không tự biến nó thành verified structured FPS.

## Example static specification

> “Thông số kích thước của model GPU này?”

Supported template có thể trả typed dimensions với model/unit/source/locator/quote.
Không match template → content-only. Missing/conflicting facts → UNKNOWN/CONFLICT,
không publish numeric answer.

Một dimensions tuple không tự chứng minh card vừa case; cần axis và modeled/catalog
compatibility evidence.

## Mixed request

> “Build PC 25 triệu và tìm benchmark của GPU được chọn.”

BUILD và research là hai tasks. Optimizer build có thể hoàn thành và được lưu,
research còn unresolved. Application không đánh dấu tất cả completed chỉ vì có build,
không xóa build hợp lệ chỉ vì web source không đọc được.

## When no source is readable

Phân biệt empty search với HTTP/challenge/unreadable source.
Typed dependency/missing-evidence outcome phải dựa trên actual tool results,
không suy “không có benchmark” từ một trang lỗi hoặc một query.

**Next:** [Tool reference](../05-api/tool-contracts.md) · [Add a tool](guides/add-tool.md).
