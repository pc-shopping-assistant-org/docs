# Web research

Web tools bổ sung thông tin ngoài catalog. Chúng không thay catalog price/stock,
không tự ghi specs vào DB và không chứng minh một cấu hình BUILD/COMPARE đã hoàn tất.

## Search, then read

```text
search_web → URLs/title/snippet → agent chọn nguồn → read_web_page
                                                   │
                          ┌────────────────────────┴──────────────────┐
                          ▼                                           ▼
                 Supported template                         General extractor
                 Typed structured facts                     Text/tables + metadata
```

`search_web` dùng DuckDuckGo adapter. Snippet chỉ dùng discovery, không citation/fact evidence.
Challenge/HTTP error/không nhận diện layout là unavailable, không giả empty search.
Query presets là helpers cho review/benchmark/specs/game requirements/PSU/etc.,
không phải tám tools riêng trong registry.

`read_web_page` tải HTML và dùng Trafilatura giữ nội dung/bảng. Curated parsers xử lý
templates đã hỗ trợ; parser không match thì fallback content, không đoán structured fact.

## Read segments

Args: `url`, `offset`, `max_chars`. Offset tính bằng ký tự Python.
Response giữ source/final URL, full extracted-content hash, returned segment và
`next_offset/total_chars`. Evidence ref binds source/offset/segment thực sự đã đọc.

Không coi phần chưa đọc là evidence. Đọc tiếp fetch lại trang; hash có thể đổi.
Đây không phải immutable page cache. Curated parser đọc DOM và chỉ expose facts
thực sự trích xuất, không tự suy từ đoạn prose được trả.

## Extraction versus fact status

| Level | Values |
| --- | --- |
| Page readability | READABLE / UNREADABLE / EMPTY |
| Parser result | STRUCTURED / CONTENT_ONLY / FAILED |
| Each fact | SUPPORTED / UNKNOWN / CONFLICT |

STRUCTURED nghĩa parser đọc được typed data, không nghĩa nguồn là chân lý.
SUPPORTED cần model/value/unit và source evidence phù hợp. UNKNOWN/CONFLICT không
có publishable numeric value.

Benchmark design cần game/resolution/preset/upscaling/test conditions; static specs
cần đúng model/value/unit. Benchmark DTO/parsers còn backlog — hiện structured facts
chỉ cover dimensions, không xuất FPS từ schema này.

## Supported templates

ASUS, TechPowerUp và Tom’s dimensions parsers nằm trong `infrastructure/search/`.
Unsupported sites vẫn có thể đọc content qua extractor chung.

Tom’s yêu cầu explicit model/header/column binding, không tạo “Model N”.
Cùng normalized model có differing measurements → CONFLICT; giữ row quotes/locators,
không publish số đo. Equivalent cm/mm không tạo false conflict.

Dimensions giữ thứ tự nguồn công bố, không tự gán length/width/height hoặc suy fit.
Muốn kết luận compatibility phải có modeled/catalog evidence tương ứng.

## Evidence and answer

- Content-only: selected `web_excerpts` là exact continuous quote trong read segment.
- Server render quote/source và nhãn chưa xác thực thông số/conditions; không publish
  arbitrary model prose như structured facts.
- Structured fact: `fact:` identity binds DTO/source/document/parser/locator/quote.
- Citations lấy final URL từ canonical result, không model-authored URL.
- Mixing catalog/build + web giữ canonical facts và thêm labelled excerpts.
- UNKNOWN/CONFLICT chỉ hỗ trợ unresolved missing-fact outcome, không positive fact answer.

Exact quote matching chứng minh nguồn có đoạn đó, không chứng minh correctness/relevance.
Thiếu evidence cho FPS → báo thiếu, không fabricate benchmark.

## Failure and recovery

Search/read reserve TOOL_IO attempts. Typed result vào checkpoint ledger; native resume
sau committed tool work reuse result, không refetch chỉ để explain lại.
Lỗi/empty/source unavailable có typed outcomes, không đổi thành “không có dữ liệu trên web”.

**Next:** [Research a question](search-qa.md) · [Tool reference](../05-api/tool-contracts.md).
