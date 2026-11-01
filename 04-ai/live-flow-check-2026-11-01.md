# Kiểm tra ba hành trình AI — 2026-11-01

Sau audit, owner yêu cầu publish/rerun infra: AI `b69fab1` / release `dfb0179`,
FE `a0c1d78` / release `72f58d3`, backend submodule pin `9e5859a`. Không nâng
version; rollout được yêu cầu sau image publication, không theo dõi kết quả deploy.
Các kết quả runtime dưới đây là trước rollout, không chứng minh bản mới đã chạy trên server.

Source local, PostgreSQL local/native checkpointer, Gemini thật và catalog HTTP
trên server. Principal đăng nhập là fixture; không phải browser hoặc production
deployment verification. Không sửa catalog hoặc deploy trong lần kiểm tra.

| Hành trình | Kết quả thực tế |
| --- | --- |
| Giải thích Logitech G431 | COMPLETED; lấy giá catalog, ghi rõ thiếu thông số |
| So sánh G431 / G Pro X | COMPLETED sau sửa canonical evidence selection |
| Build PC 25 triệu gaming Full HD | Chưa pass live: Gemini timeout cả hai execution attempts trước optimizer |

Lỗi so sánh đã tái hiện: Gemini chọn `explanation_refs` nhưng không lặp lại `refs`.
Code cũ không đưa chúng vào canonical selection, hết vòng repair. Test regression
trước sửa: 4 failed; sau sửa: cả calls-only và explanation-refs-only đều qua.
Không dùng prose trong `text` làm catalog facts.

Gemini 3.1 Flash Lite cũng trả 503 trong phiên này; managed recovery đã chạy lại
đúng run. Đây là lỗi upstream, khác lỗi validation trên. Không coi việc retry có
chạy là bằng chứng hành trình build thành công.

Kiểm tra xác định: 24 ca giải thích/so sánh fresh và khi build pending đều chạy mà
optimizer/hardware loader được đặt chế độ gọi là fail; accepted requirements và
pending artifact được giữ nguyên. Bao gồm câu hỏi không đính kèm khi đang chờ đơn
vị hoặc chọn SKU. Hai ca bổ sung xác minh chỉ tải hardware sau lựa chọn SKU thật,
không tải khi sửa dung lượng; không tự merge trước confirmation. Native PostgreSQL kiểm tra hỏi sản phẩm giữa
proposal và confirmation, rồi build và đọc lại snapshot. FE có test mất response admission, mất SSE và
mất mạng kéo dài, không tạo request ID hoặc SSE subscription mới.

Build tương thích nhưng thiếu ranking metadata được công bố `UNRANKED`, objective
và score null. Các thông số vật lý/điện vẫn bắt buộc; thiếu chúng khác thiếu benchmark.
Catalog enrichment vẫn hoãn ở ISSUE-168. Source chưa push/deploy.

Final local gate: `uv run pytest -q tests integration_tests` **1081 passed**;
Ruff/mypy212/lock167 pass. FE `yarn test:run` **233 passed**; typecheck/lint,
OpenAPI check và production build pass. Chưa kiểm chứng bản sửa trong browser.

HTTP snapshot100 trên server vẫn503. Image catalog đang chạy revision `b1b6927`,
ancestor của backend `13d25bb`; source cũ gọi media bằng toàn bộ IDs trong một GET.
Bản sửa batching100 đã có trong backend13d25bb nhưng chưa nằm trong image đang
chạy. Không tự rollout để biến kiểm tra source thành thay đổi production.

## Completion audit / lần kiểm tra tiếp

| Yêu cầu | Bằng chứng | Kết luận |
| --- | --- | --- |
| Đọc sản phẩm độc lập build | 24 ca đọc; optimizer/hardware loader gọi là fail | PASS core |
| Giữ accepted state | Cùng các ca trên giữ nguyên cả historical public build, requirements và pending artifact | PASS core |
| Build fail rồi tiếp tục đọc | Native HTTP/SQL/executor: FAILED_TERMINAL → giải thích/so sánh COMPLETED trên cùng conversation/revision | PASS native |
| NET_CHANGED không tạo trùng | FE mất headers/body/SSE + native admission retry trước/sau publish | PASS local |
| Build không có điểm benchmark | Real optimizer, verifier, publication, PostgreSQL reopen | PASS native; UNRANKED |
| Build với model thật | Cả Gemini3.1 Flash Lite và3.8 Flash trả503 ngay model call đầu, kể cả hardware fixture được ghi rõ là fixture | Chưa verify được |

REST probe tối thiểu tới Gemini3.1 Flash Lite, không tools/history, chỉ “Reply
only: OK”, cũng trả503 UNAVAILABLE/high demand. Vì vậy chưa có bằng chứng để
quy lỗi này cho schema tools hoặc optimizer. Không đổi model server hay tăng retry.
Live build gate còn mở; không dùng test fixtures để claim real-catalog readiness.

**Goal: BLOCKED tại live verification.** Lần recheck sau audit vẫn nhận503 từ cả
Gemini minimal REST probe và snapshot100. Cùng trở ngại lặp lại qua ba goal turns;
không còn thay đổi core cần làm để vượt hai dependency failures này. Tiếp tục khi
provider nhận request được và catalog đã chạy bản có media batching/snapshot200.
Sau đó chạy lại build → đọc snapshot → giải thích/so sánh trên cùng conversation.
Chưa claim full end-to-end, chưa push/deploy hoặc tự điền metadata thiếu.
