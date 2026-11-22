---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #f8fafc
color: #0f172a
style: |
  section {
    font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    padding: 35px 50px;
    font-size: 1.05rem;
    line-height: 1.5;
  }
  h1 {
    color: #1e3a8a;
    font-size: 1.75rem;
    margin-bottom: 12px;
  }
  h2 {
    color: #1e40af;
    border-bottom: 2px solid #3b82f6;
    margin-bottom: 14px;
    padding-bottom: 4px;
    font-size: 1.3rem;
  }
  h3 {
    color: #0369a1;
    margin-bottom: 8px;
    font-size: 1.1rem;
  }
  footer {
    font-size: 0.55rem;
    color: #64748b;
  }
  code {
    background: #e2e8f0;
    color: #0f172a;
    font-size: 0.9em;
    padding: 2px 4px;
    border-radius: 3px;
  }
  table {
    font-size: 0.82rem;
    width: 100%;
    border-collapse: collapse;
    margin-top: 6px;
  }
  th, td {
    border: 1px solid #cbd5e1;
    padding: 6px 10px;
  }
  th {
    background: #e2e8f0;
    color: #1e293b;
    text-align: left;
  }
---

# BÁO CÁO ĐỒ ÁN TỐT NGHIỆP
## Nghiên Cứu & Xây Dựng Hệ Thống AI Tư Vấn Mua Sắm Và Tối Ưu Cấu Hình Máy Tính
**Phương pháp:** Kết hợp mô hình ngôn ngữ lớn (LangGraph ReAct) và Thuật toán tối ưu hóa ràng buộc (MCKP-PCC)

---

## 1. Bài Toán Tư Vấn & Xây Dựng Cấu Hình PC

* **Bài toán thực tế:**
  * Người dùng cần xây dựng cấu hình máy tính phù hợp với ngân sách và mục đích sử dụng (chơi game, đồ họa, văn phòng).
  * Việc lựa chọn linh kiện đòi hỏi kiến thức kỹ thuật về tính tương thích: chân cắm CPU/Mainboard, chuẩn RAM, kích thước vật lý (chiều dài card đồ họa, chiều cao tản nhiệt so với vỏ case) và công suất nguồn điện.
* **Đặc thù kỹ thuật:**
  * Catalog gồm khoảng **2.355** sản phẩm phân vào 8 nhóm linh kiện cốt lõi, tạo ra $10^{11} \sim 10^{13}$ tổ hợp cấu hình tiềm năng.
* **Hạn chế khi chỉ sử dụng mô hình ngôn ngữ lớn (LLM):**
  * LLM xử lý ngôn ngữ tự nhiên tốt nhưng dễ sinh thông tin sai lệch về kích thước mm hoặc chân cắm.
  * LLM không có khả năng tính toán số học chính xác trên danh mục giá linh kiện thực tế.
  * Việc phụ thuộc hoàn toàn vào LLM khó đảm bảo cấu hình đề xuất luôn lắp ráp vừa vặn và hoạt động ổn định.

---

## 2. Hướng Giải Quyết & Phân Chia Trách Nhiệm

Hệ thống được chia thành hai phần xử lý riêng biệt nhằm kết hợp thế mạnh của từng thành phần:

```
[ Người dùng đặt câu hỏi ] ──► [ Mô hình ngôn ngữ lớn (LLM) ]
                                    │
                                    ├── Hiểu ngữ cảnh hội thoại, trích xuất nhu cầu
                                    └── Đề xuất gọi các công cụ (Tool Calls)
                                    │
                                    ▼
                               [ Bộ xử lý xác định bằng code ]
                                    │
                                    ├── Tra cứu danh mục sản phẩm và giá thật
                                    ├── Kiểm tra quy tắc tương thích cơ - điện
                                    └── Thuật toán tối ưu hóa cấu hình (MCKP-PCC)
                                    │
                                    ▼
[ Người dùng nhận kết quả ] ◄── [ Cấu hình hợp lệ & câu trả lời đã kiểm tra ]
```

* **LLM (LangGraph ReAct):** Đảm nhiệm việc giao tiếp, hiểu ý định của người dùng và giải thích kết quả.
* **Xử lý bằng code (Deterministic):** Quản lý dữ liệu kho hàng, kiểm tra tính tương thích và giải bài toán tối ưu.

---

## 3. Kiến Trúc Tổng Thể 7 Components

```
                                [ Giao diện Web / Frontend ]
                                             │
               ┌─────────────────────────────┴─────────────────────────────┐
               │ 1. API Controller: Nhận yêu cầu (202 Accepted) & stream SSE│
               └─────────────────────────────┬─────────────────────────────┘
                                             │
               ┌─────────────────────────────┴─────────────────────────────┐
               │ 2. Run Coordinator: Quản lý phiên & lưu trạng thái Postgres│
               └─────────────────────────────┬─────────────────────────────┘
                                             │
               ┌─────────────────────────────┴─────────────────────────────┐
               │ 3. Managed Executor: Quản lý vòng đời tiến trình ngầm     │
               └─────────────────────────────┬─────────────────────────────┘
                                             │
               ┌─────────────────────────────┴─────────────────────────────┐
               │ 4. LangGraph ReAct Engine: Điều phối vòng lặp suy luận    │
               └──────────────┬─────────────────────────────┬──────────────┘
                              │                             │
       ┌──────────────────────┴──────────┐   ┌──────────────┴──────────────┐
       │ 5. Requirement Compiler         │   │ 6. Tool Dispatcher          │
       │ Chuẩn hóa ràng buộc ngân sách   │   │ Lấy dữ liệu kho hàng & web  │
       └──────────────────────┬──────────┘   └──────────────┬──────────────┘
                              │                             │
                              └──────────────┬──────────────┘
                                             │
               ┌─────────────────────────────┴─────────────────────────────┐
               │ 7. PC Builder Optimizer: Thuật toán tối ưu cấu hình MCKP  │
               └───────────────────────────────────────────────────────────┘
```

---

## 4. Xử Lý Hội Thoại & Quản Lý Trạng Thái (Components 1, 2, 3, 4)

* **Xử lý yêu cầu bất đồng bộ (Components 1 & 3):**
  * Khi nhận tin nhắn, API lưu yêu cầu vào database và trả về `202 Accepted` ngay lập tức.
  * Luồng gửi sự kiện (SSE) chỉ đọc nhật ký từ database, không gắn chặt với tiến trình xử lý AI.
  * Nếu người dùng gặp sự cố mạng hoặc tải lại trang (F5), tiến trình AI vẫn chạy đến khi hoàn tất và kết quả được lưu lại để tải sau.
* **Quản lý trạng thái hội thoại (Component 2):**
  * Sử dụng cơ chế khóa trên PostgreSQL để đảm bảo mỗi hội thoại chỉ có một lượt xử lý tại một thời điểm.
  * Phân biệt trạng thái chính thức (đã hoàn tất thành công) và các trạng thái thử nghiệm trung gian của mô hình; nếu lượt xử lý gặp lỗi hoặc bị hủy, trạng thái chính thức trước đó vẫn được giữ nguyên.
* **Vòng lặp ReAct có kiểm soát (Component 4):**
  * Điều phối **12 công cụ chuyên biệt** (`search_catalog`, `compare_products`, `check_build_compatibility`, `build_pc`, nhóm `research_*`...), hỗ trợ gọi song song theo batch.
  * Giới hạn số lượt gọi mô hình, công cụ và tự tổng hợp từ bằng chứng sẵn có khi chạm ngưỡng `max_tool_calls`, ghi nhận kết quả vào `ledger` gắn `canonical_hash`.

---

## 5. Xử Lý Dữ Liệu & Kiểm Tra Thông Số (Components 5 & 6)

* **Chuẩn hóa yêu cầu người dùng (Component 5 - Requirement Compiler):**
  * Tự động nhận diện và chuẩn hóa cách diễn đạt thông dụng trong tiếng Việt: "25 củ", "25tr" $\rightarrow$ `25.000.000 VND`; "32 ghi ram" $\rightarrow$ `32 GB`.
  * Phân biệt rõ thông tin người dùng đã xác nhận (lưu vào yêu cầu chính thức) và gợi ý của hệ thống cần người dùng xác nhận lại.
* **Kết nối dữ liệu kho hàng (Component 6 - Tool Dispatcher):**
  * Kết nối trực tiếp với backend thương mại để lấy danh mục sản phẩm, mã SKU, giá bán niêm yết và số lượng tồn kho thực tế.
* **Tra cứu và kiểm tra thông số kỹ thuật:**
  * Xây dựng các bộ parser bóc tách thông số phần cứng từ các trang thông tin uy tín (TechPowerUp, Tom's Hardware, trang thông số chính hãng ASUS).
  * Quy định rõ: Mọi con số về kích thước vật lý xuất hiện trong câu trả lời phải đối chiếu được với dữ liệu đã tra cứu trong phiên làm việc; đường dẫn nguồn tham khảo do server tự chèn dựa trên URL thực tế.

---

## 6. Mô Hình Hóa Bài Toán Tối Ưu Cấu Hình PC (MCKP-PCC)

Bài toán xây dựng cấu hình máy tính được mô hình hóa thành biến thể **Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints (MCKP-PCC)**:

$$\max \quad U(x) = \sum_{k=1}^{K} \sum_{i \in S_k} u_{ik} \cdot x_{ik}$$

* **Ràng buộc ngân sách:**
$$\sum_{k=1}^{K} \sum_{i \in S_k} c_{ik} \cdot x_{ik} \le B \quad (c_{ik}: \text{giá linh kiện}, B: \text{ngân sách người dùng})$$
* **Ràng buộc phân lớp linh kiện (8 nhóm bắt buộc, $K=8$):**
$$\sum_{i \in S_k} x_{ik} = 1 \quad \forall k \in \{1, 2, \dots, 8\}, \quad x_{ik} \in \{0, 1\}$$
  * $S_1$: CPU, $S_2$: Mainboard, $S_3$: RAM, $S_4$: GPU, $S_5$: Ổ cứng, $S_6$: Nguồn, $S_7$: Vỏ case, $S_8$: Tản nhiệt.
* **Ràng buộc tương thích cặp đôi (Compatibility Constraints):**
$$x_{ik} + x_{jl} \le 1 \quad \forall (u_{ik}, u_{jl}) \in E_{\text{Conflicts}}$$
Hai linh kiện có xung đột cơ học hoặc điện năng sẽ không được phép cùng xuất hiện trong một cấu hình.

---

## 7. Ràng Buộc Tương Thích Cơ - Điện (Physical Rule Engine)

Các ràng buộc trong tập $E_{\text{Conflicts}}$ được kiểm tra xác định bằng thuật toán (áp dụng đồng nhất cho cả Optimizer, API và ReAct tool `check_build_compatibility`):

| Hạng mục kiểm tra | Điều kiện tương thích | Ý nghĩa thực tế |
| :--- | :--- | :--- |
| **Chân cắm & RAM** | $\text{Socket}(\text{CPU}) = \text{Socket}(\text{MB})$, $\text{Gen}(\text{MB}) = \text{Gen}(\text{RAM})$ | Khớp socket (LGA1700, AM5…) và chuẩn DDR4/DDR5. |
| **Số khe RAM** | $\text{KitModules}(\text{RAM}) \le \text{RamSlots}(\text{MB})$ | Không gắn kit 4 thanh lên mainboard chỉ có 2 khe. |
| **Kích thước & M.2** | $\text{FF}(\text{MB}) \in \text{SupportedFF}(\text{Case})$, $\text{NVMe} \Rightarrow \text{M2Slots} > 0$ | Mainboard vừa vỏ case; SSD NVMe phải có khe M.2. |
| **Chiều dài GPU** | $\text{Length}(\text{GPU}) \le \text{MaxGPULength}(\text{Case})$ | Card đồ họa (mm) không cấn quạt mặt trước case. |
| **Tản nhiệt & Case** | $\text{Height} \le \text{MaxHeight}$, $\text{Rad} \le \text{MaxRad}$ | Đủ khoảng hở cho tản khí hoặc két nước AIO (mm). |
| **Tản nhiệt & CPU** | $\text{Socket}(\text{CPU}) \in \text{CoolerSockets}$, $\text{TDP}_{\text{Cooler}} \ge \text{TDP}_{\text{CPU}}$ | Đúng ngàm socket và đủ công suất giải nhiệt cho CPU. |
| **Công suất nguồn** | $\text{Wattage}(\text{PSU}) \ge \text{SustainedPeak} \times 1.10$ (+ transient GPU) | Đảm bảo không sập nguồn khi tải đỉnh và xung dòng. |

---

## 8. Phương Pháp Giải Thuật Toán 3 Bước

Để tìm cấu hình tối ưu trên ~2.355 SKU theo thời gian thực, hệ thống kết hợp:

* **Bước 1: Lọc bảo toàn bằng Pareto Pruning**
  * Loại các ứng viên bị trội hoàn toàn trong từng nhóm linh kiện, đồng thời **bảo toàn tính khả thi** (`iGPU`, `stock_cooler`, `kit_modules`, `radiator_mm`, giao tiếp `NVMe/SATA`).
* **Bước 2: Tìm kiếm Branch & Bound + Algebraic Decomposition**
  * Tách riêng cặp `(Case, Cooler)` theo từng bộ `(CPU, MB, GPU)` để giảm hệ số nhân $|Case| \times |Cooler|$, kết hợp **cắt nhánh theo tổng giá tối thiểu phần còn lại** và **2-pass Envelope Search**.
* **Bước 3: Chấm điểm MAUT theo 12 Profile cấu hình JSON (`profiles.json`)**
  * Xuất đồng thời 3 phương án (`PERFORMANCE`, `BALANCED`, `UPGRADE_FRIENDLY`) với ngưỡng bão hòa riêng theo profile (RAM 16/32/64GB, SSD 512GB/1TB/2TB), phạt bottleneck Gaming, thưởng CUDA/Multi-core, hỗ trợ **Multi-profile Blending** và **Soft Preferences**.

---

## 9. Tích Hợp Giao Diện Web & Giám Sát Hệ Thống (Observability)

* **Trải nghiệm Web Frontend (`Next.js`):**
  * **Trang `/assistant` & Floating Chat Bubble:** Liên kết sản phẩm cùng tab, gom thẻ sản phẩm vào một **Carousel** ngang, chuyển cấu hình sang `/build-pc?build=...`.
  * **Trang `/build-pc` ("AI tự tối ưu"):** Cho phép người dùng chọn 12 nhu cầu chi tiết, pin cố định linh kiện ưa thích (`pinned_slots`) và tự động điền các slot còn lại tương thích 100%.
* **Giám sát phân tán (OpenTelemetry + Grafana LGTM):**
  * **Logs (Loki) & Traces (Tempo):** Gắn `trace_id = run_id` và truyền W3C `traceparent` xuyên suốt `api-gateway` $\rightarrow$ `ai-service` $\rightarrow$ `catalog-service`/`search-service`.
  * **Metrics (Prometheus) & An toàn dữ liệu:** Theo dõi `ai_step_total` và `ai_step_duration_ms` p95; tuyệt đối không ghi prompt, token hay exception body nhạy cảm vào log (chỉ ghi `error_type` + `error_location`).

---

## 10. Luồng Xử Lý Thực Tế: Ví Dụ Yêu Cầu Build PC 25 Triệu

```
[ Người dùng ]: "Tư vấn cấu hình PC gaming khoảng 25 triệu"
      │
      ▼
1. API Controller ────────► Lưu yêu cầu, tạo run_id, mở luồng SSE stream.
      │
      ▼
2. Requirement Compiler ──► Chuẩn hóa: Ngân sách = 25.000.000 VND; Nhu cầu = Chơi game.
      │
      ▼
3. Tool Dispatcher ───────► Lấy danh mục linh kiện đang mở bán từ kho backend.
      │
      ▼
4. PC Builder Optimizer
      ├── Kiểm tra Rule Engine: Lọc các linh kiện khớp socket và kích thước.
      ├── Pareto Pruning: Lược bớt linh kiện có tỷ lệ hiệu năng/giá thấp.
      ├── Branch & Bound: Tìm các tổ hợp linh kiện nằm trong phạm vi 25 triệu.
      └── Đánh giá MAUT: Chọn cấu hình có hiệu năng chơi game cao nhất trong tầm giá.
      │
      ▼
5. LangGraph ReAct ───────► LLM nhận danh sách linh kiện đã được kiểm tra tính hợp lệ.
      │
      ▼
6. Client nhận kết quả ───► Hiển thị bảng cấu hình rõ ràng, đúng giá niêm yết và vừa vặn.
```

---

## 11. Đánh Giá Thực Nghiệm & Hiện Trạng Triển Khai

Báo cáo phân định minh bạch giữa phần đã kiểm thử thực tế và hướng phát triển tiếp theo:

* **Những phần đã hoàn thành và kiểm thử tự động:**
  * **Bộ kiểm thử tự động:** `ai-service` đạt **1.062 test cases** (unit + integration Postgres, kiểm tra Clean Architecture, ReAct state, Optimizer & Observability), cùng unit tests cho `web-frontend` (`pc-builder`, `assistant`) và `infra` (`40 tests`).
  * **Kiểm tra tương thích trên dữ liệu danh mục:** Ánh xạ và kiểm chứng trực tiếp trên bộ seed **2.355 sản phẩm** với đầy đủ thông số tương thích & `core_count` / `tdp_watts`.
  * **Trích xuất thông số web:** Kiểm thử trực tiếp trên các tệp HTML thật tải về từ ASUS, TechPowerUp và Tom's Hardware.
* **Hướng phát triển tiếp theo:**
  * **Làm giàu metadata nâng cao:** Bổ sung thêm thông số chi tiết như tier VRM bo mạch chủ và độ ồn dBA của Case/Cooler để chấm điểm sâu hơn cho cấu hình workstation êm ái.
  * **Tự chủ mô hình nguồn mở:** Đang thử nghiệm với Gemini API và đã chuẩn bị pipeline huấn luyện Qwen3-8B phục vụ triển khai nội bộ.

---

## 12. Tổng Kết Đồ Án

1. **Phương pháp kết hợp thực tế:**  
   Giải quyết bài toán tư vấn cấu hình bằng cách phân định rõ: Mô hình ngôn ngữ lớn làm việc giao tiếp, hiểu nhu cầu; thuật toán xác định chịu trách nhiệm về tính tương thích vật lý và ngân sách.
2. **Đảm bảo tính khả thi cơ - điện:**  
   Mô hình hóa bài toán thành MCKP-PCC với các quy tắc kiểm tra kích thước và chân cắm giúp loại bỏ tình trạng đề xuất cấu hình không lắp ráp được.
3. **Thiết kế hệ thống có tính chịu lỗi:**  
   Quản lý trạng thái bằng checkpoint và xử lý bất đồng bộ giúp phiên làm việc của người dùng không bị mất khi gặp sự cố gián đoạn mạng.

---

# CẢM ƠN QUÝ THẦY CÔ VÀ HỘI ĐỒNG ĐÃ LẮNG NGHE!
### Em xin sẵn sàng nhận câu hỏi đóng góp và nhận xét.
