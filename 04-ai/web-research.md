# Web research

Web tools bổ sung thông tin ngoài catalog. Chúng không thay catalog price/stock,
không tự ghi specs vào DB và không chứng minh một cấu hình BUILD/COMPARE đã hoàn tất.

## Research strategy — manufacturer first

Mục tiêu là trả lời có bằng chứng, không phải tăng số tool hoặc gom top search results.

```text
Câu hỏi / canonical build → xác định model + mục cần kiểm chứng
  → nguồn hãng: thông số, support, BIOS, kích thước, đầu nối
  → nguồn kiểm thử theo chủ đề: hiệu năng, điện, nhiệt/ồn, workload
  → đọc trang + giữ provenance → đối chiếu model/điều kiện → tổng hợp + phần còn thiếu
```

| Policy | Contract |
| --- | --- |
| Official first | Resolve hãng từ canonical brand hoặc alias đã cấu hình; không đoán domain từ LLM. Không resolve được → `UNKNOWN`. |
| Independent second | Registry chọn domain theo focus; PSU electrical test khác CPU benchmark hoặc productivity. Nguồn hãng không thay independent test. |
| Scope enforcement | Search có target domains; lọc cả URL kết quả và URL sau redirect. Không tự fallback toàn web. |
| Evidence | Lưu policy version/hash, từng tier/query/domain/status; chỉ page đã đọc tạo evidence. Official/READABLE không đồng nghĩa fact đúng. |
| Synthesis | Đối chiếu exact model/revision và điều kiện đo. Không đủ → nêu thiếu; catalog giữ price/stock, optimizer giữ compatibility. |

Implementation slice: registry có cấu hình → staged search/read dùng ports hiện có →
typed provenance → regression tests → cập nhật status. Không thêm framework, scoring
hoặc parser benchmark trong slice này. `search_web` vẫn là low-level discovery;
hardware/build research dùng pipeline scoped, không lấy generic search làm mặc định.

Acceptance: hãng được tra trước review; specs dừng khi có nguồn hãng đọc được;
review vẫn tra independent source; hãng lạ không bị đoán; URL ngoài scope bị loại;
nguồn lỗi không làm mất nguồn còn lại; current/saved build giữ đúng linh kiện;
budget và native resume không bị bypass. Live search/read chỉ chứng minh retrieval,
không thay thế kiểm chứng factuality bằng model thật.

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

## Research tools

Existing compatibility/review/issues/PSU/spec queries dùng chung presets và source
policy. Build-guide helper chỉ discovery/reference, không thay optimizer. Không
expose lại tám helper thành tám agent tools.

Các tool này tự **search → chọn số nguồn hữu hạn → đọc → trả pages/evidence**.
`search_web`/`read_web_page` vẫn dùng được cho khám phá và đọc sâu tiếp.

| Tool | Câu hỏi phù hợp |
| --- | --- |
| research_hardware | “Nguồn này ripple/protection ra sao?”, “Main VRM có nóng không?”, “SSD có tụt tốc sustained không?” |
| research_compatibility | “CPU này cần BIOS nào trên main đó?”, “Tản có cấn RAM không?” |
| research_workload | “Game/app yêu cầu gì?”, “Có benchmark đúng GPU, resolution, preset, upscaling này không?” |
| research_pc_build | “Nhận xét cấu hình vừa build: hiệu năng, main/RAM/SSD, nguồn và nhiệt/ồn” |
| research_driver | “Tìm trang BIOS/driver/chipset/RGB cho đúng model này” — chỉ đọc trang chính hãng |

`research_workload`:

- `BENCHMARK`: chọn `benchmark_kind=GAMING` hoặc `PRODUCTIVITY`. Nguồn/measurement
  conditions theo loại; productivity không bị hỏi resolution/DLSS của game.
- `REQUIREMENTS`: publisher docs từ registry → Steam listing nếu cần. Không dùng
  review sites, không tự giả định resolution/OS. Hãng game chưa đăng ký → Steam,
  không tự gán publisher domain.

`research_driver(component_name, software_type, operating_system?, version?)` dùng
VGA_DRIVER/BIOS_UPDATE/CHIPSET_DRIVER/RGB_CONTROL. Hãng chưa resolve →
SOURCE_UNRESOLVED và không I/O; không mở review/general tier hay download mirror.
Reader chỉ nhận HTML/XHTML/plain text, không consume binary installer body.
Đọc được trang support không chứng minh có driver phù hợp/phiên bản mới nhất.

Independent registry theo chủ đề: performance (TechPowerUp/TechSpot/ComputerBase/
GamersNexus/Tom’s), productivity (Puget/Phoronix/TechPowerUp), PSU (Hardware Busters/
Cybenetics/Tom’s/TechPowerUp), storage (StorageReview/TechPowerUp/Tom’s).
Thêm domain không đồng nghĩa thêm parser số liệu. TechSpot/Phoronix hiện bị
Cloudflare403 trên reader local; chưa có browser/fetch bypass.

Build research lấy tên từ verified current-run `build_ref`, hoặc accepted saved
snapshot khi bỏ trống ref. Agent không tự truyền một cấu hình khác vào để đánh giá.
Tool không scan lại toàn bộ hardware catalog hoặc đổi requirements. Từng part
được tra theo vai trò:

| Part | Research focus |
| --- | --- |
| CPU / GPU | Performance, benchmark, power |
| Mainboard | VRM thermal, BIOS/CPU support, connectivity |
| RAM | Latency/bandwidth, XMP/EXPO stability |
| Storage | Sustained performance, endurance, controller/NAND, nhiệt |
| PSU | Electrical tests, ripple, protections, transient response |
| Cooler | Thermal/noise |
| Case | Airflow, nhiệt/ồn, clearance |

Standalone research đọc <=2 nguồn/tier. Full-build research đọc <=1 nguồn/tier/part, <=8 parts;
URL trùng trong cùng invocation chỉ fetch một lần. Mỗi page trả <=2000 ký tự và
next_offset; agent có thể đọc sâu tiếp. `ResearchSourceStatus` và giới hạn được
định nghĩa tập trung trong `research_contracts.py`.

**Source coverage:** READABLE = đọc được; NO_RESULTS = query không có kết quả;
UNREADABLE = có URL nhưng không đọc được; UNAVAILABLE = search dependency lỗi.
SOURCE_UNRESOLVED = không xác định được nguồn được phép để bắt đầu lookup.
Đây chưa phải bằng chứng nguồn có đúng model/điều kiện cần tìm. Agent vẫn phải chọn
excerpts phù hợp; thiếu dữ kiện phải nói rõ. Partial failure không xóa nguồn đã đọc.

Registry trong `capabilities/web_search/source_policy.py` được inject từ
`AI_WEB_RESEARCH_SOURCES` (JSON); không nhận domain từ model. Các field bỏ trống dùng
default; mỗi map được cung cấp sẽ **thay cả map**, không merge ngầm. Keys hãng/alias
dùng chữ thường đã chuẩn hóa; `reviews` dùng focus enum, `GENERAL` làm default.
`publishers` map tên workload/game/app tới domains; `requirement_stores` mặc định
Steam. Tier STORE_LISTING phân biệt store với OFFICIAL/INDEPENDENT_REVIEW.
`allow_general_fallback=false` mặc định; bật lên chỉ search toàn web khi chưa có
nguồn scoped đọc được, ghi rõ tier `GENERAL_WEB`; driver/requirements không mở
general fallback dù cấu hình bật. Domain chưa đăng ký cần bổ sung
registry; không tự coi domain mới là hãng/nguồn kiểm thử.

`ResearchResult` giữ policy version/hash; từng section có `official_source_status`
(RESOLVED/PARTIAL/UNKNOWN: resolve **domain**, không phải xác minh fact) và
`search_steps` với tier/query/target_domains/status/result_urls. Ưu tiên title chứa
model tokens để chọn trang; đây không phải exact revision matching.

Đánh giá build dùng `review` (summary/pros/cons/verdict) và exact `web_excerpts`.
Server render quote/citation và bảng source coverage; phần review là diễn giải theo
nguồn. Không có số chấm điểm/bottleneck/FPS tự sinh. Catalog giữ giá/tồn kho; optimizer
giữ compatibility constraints. Research không tự xác nhận toàn bộ build tương thích.

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
Runtime bọc từng search/read bằng budgeted ports; một batch không chỉ tính là một
outbound request. Default allowance của run mới là48 TOOL_IO (gồm logical tool admission
và I/O); budget đã persist của run cũ không bị reset.

Gates và live source coverage nằm trong [Status](stateful-implementation-status.md).
Đọc được nguồn không chứng minh exact revision, live LLM quality hay structured FPS.

**Next:** [Research a question](search-qa.md) · [Tool reference](../05-api/tool-contracts.md).
