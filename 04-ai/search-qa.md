# Research a question

Guide này dùng search/read và research tools để trả lời với evidence.
[Web research](web-research.md) giải thích parser/fact contracts.

## Example question

> “RTX4070Super chơi Black Myth Wukong 1440p được bao nhiêu FPS?”

1. Agent gọi `research_workload` mode BENCHMARK, benchmark_kind GAMING với thông tin đã biết.
2. Tool tra hãng rồi nguồn kiểm thử scoped; snippet không làm answer.
3. Dùng pages trả về; gọi `read_web_page` đọc tiếp segment nếu cần. `search_web` dành discovery rộng hơn.
4. Kiểm tra đúng model/game/resolution/preset/upscaling và bảng/quote nguồn.
5. Trả supported typed fact nếu contract/parser hỗ trợ; nếu không, exact labelled
   excerpt/citation hoặc insufficient evidence, không tự dựng số FPS.

**Giới hạn hiện tại:** curated facts cover dimensions, chưa có benchmark DTO/parser
hoàn chỉnh. Đọc được bài benchmark không tự biến nó thành verified structured FPS.

`research_workload` thực hiện search/read trong một tool call. Productivity dùng
benchmark_kind PRODUCTIVITY; requirements dùng mode REQUIREMENTS (publisher→Steam,
không review sites). Bỏ trống thông tin chưa biết; result báo
missing_conditions, không mặc định1080p/Ultra/DLSS.

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

Để nhận xét cả build, gọi `research_pc_build` với build_ref vừa nhận. Tool tra từng
core part; agent đọc thêm nếu cần rồi trả review với excerpts và nêu các khoảng
trống trong source coverage. Nếu user hỏi về PSU/SSD/main riêng, dùng
`research_hardware` với focus tương ứng thay vì một query benchmark GPU chung.
Các research tool tra nguồn hãng trước rồi nguồn kiểm thử theo chủ đề; agent kiểm
tra model/revision/điều kiện trong page đã đọc. Cùng tên nhưng khác đời không được
gộp thông số. `UNKNOWN` official domain phải được nêu rõ, không đoán hãng.

## When no source is readable

Driver/BIOS: `research_driver` chỉ đọc trang support chính hãng, OS/version optional.
Hãng không resolve → SOURCE_UNRESOLVED; trang403 không chứng minh driver không tồn tại.
Không tự tải binary/installer hoặc mở download mirror.

Phân biệt empty search với HTTP/challenge/unreadable source.
Typed dependency/missing-evidence outcome phải dựa trên actual tool results,
không suy “không có benchmark” từ một trang lỗi hoặc một query.

**Next:** [Tool reference](../05-api/tool-contracts.md) · [Add a tool](guides/add-tool.md).
