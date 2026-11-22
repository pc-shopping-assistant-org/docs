# Bộ Kịch Bản Kiểm Thử Thủ Công End-to-End (200 Test Cases)

Thư mục này tách bộ **245 kịch bản kiểm thử (`SC-001` → `SC-245`)** thành **13 file chuyên biệt** theo từng năng lực của **ReAct Agent**, **PC Build Optimizer**, **Web Frontend**, và **Grafana Observability**.

Mỗi test case đều ghi rõ: **Tiền điều kiện**, **Prompt/Thao tác từng lượt (copy-paste được ngay)**, **Luồng ReAct/Tool kỳ vọng**, và **Tiêu chí đạt (Pass Criteria)**.

## Mục lục 12 bộ test case

| File                                                                 | Nhóm  | Phạm vi kiểm thử                                                             | Mã test             | Số lượng |
| -------------------------------------------------------------------- | ----- | ---------------------------------------------------------------------------- | ------------------- | -------: |
| [01-search-catalog.md](./01-search-catalog.md)                       | **A** | Search Catalog, lọc khoảng giá, spec & semantic query (`search_catalog`)     | `SC-001` → `SC-020` |       20 |
| [02-product-details.md](./02-product-details.md)                     | **B** | Tra cứu chi tiết sản phẩm & spec (`get_product_details`)                     | `SC-021` → `SC-036` |       16 |
| [03-product-comparison.md](./03-product-comparison.md)               | **C** | So sánh nhiều sản phẩm & đối chiếu catalog (`compare_products`)              | `SC-037` → `SC-052` |       16 |
| [04-web-research.md](./04-web-research.md)                           | **D** | Web Search & Hardware Research (`research_*`, `search_web`, `read_web_page`) | `SC-053` → `SC-072` |       20 |
| [05-pc-build-profiles.md](./05-pc-build-profiles.md)                 | **E** | 12 `UseCaseProfile`, Multi-Profile Blending & Guardrails (`build_pc`)        | `SC-073` → `SC-096` |       24 |
| [06-optimizer-constraints.md](./06-optimizer-constraints.md)         | **F** | `BuildObjective`, Soft/Hard Prefs, Owned/Pinned Parts & Budget Edges         | `SC-097` → `SC-116` |       20 |
| [07-compatibility-checks.md](./07-compatibility-checks.md)           | **G** | Kiểm tra tương thích cơ–điện (`check_build_compatibility`)                   | `SC-117` → `SC-132` |       16 |
| [08-clarification-amendment.md](./08-clarification-amendment.md)     | **H** | Clarification, Unit Disambiguation, Pending Resolution & Amendment           | `SC-133` → `SC-150` |       18 |
| [09-multi-task-dialogue.md](./09-multi-task-dialogue.md)             | **I** | Multi-Task Registration, Dialogue Continuation & `RESPOND`                   | `SC-151` → `SC-164` |       14 |
| [10-grounding-security-limits.md](./10-grounding-security-limits.md) | **J** | Evidence Grounding, Prompt Injection, Tool Budget & Error Recovery           | `SC-165` → `SC-178` |       14 |
| [11-web-frontend-ux.md](./11-web-frontend-ux.md)                     | **K** | Web Frontend UX (`/assistant`, `/build-pc`, Floating Bubble, `vi`/`en`)      | `SC-179` → `SC-190` |       12 |
| [12-observability-tracing.md](./12-observability-tracing.md)         | **L** | Observability (Loki Logs, Tempo W3C Trace, Prometheus Metrics)               | `SC-191` → `SC-200` |       10 |
| [13-long-conversations.md](./13-long-conversations.md)               | **M** | Hội thoại dài 8–12 lượt End-to-End (Stress, Checkpoint, Injection, Full UX)  | `SC-201` → `SC-245` |       45 |
| **Tổng cộng**                                                        |       |                                                                              |                     |  **245** |

## Quy ước thực thi nhanh

1. Mở `/assistant` (hoặc Floating AI Bubble) ở trạng thái phiên mới cho mỗi mã `SC-xxx` độc lập.
2. Copy từng lượt prompt theo thứ tự; chờ SSE stream hoàn tất (`COMPLETED` / `WAITING_INPUT`) rồi mới gửi lượt kế tiếp.
3. Sau khi chạy xong mỗi nhóm, kiểm tra `trace_id` trong Grafana Dashboard **`PC Shopping - AI Runs`** để xác nhận không có lỗi ẩn (`FAILED`) hoặc rò rỉ dữ liệu nhạy cảm.
