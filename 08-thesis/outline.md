# Đề Cương Luận Văn Tốt Nghiệp / Báo Cáo Khoa Học (Thesis Outline)

**Đề tài:** Nghiên cứu và Xây dựng Hệ thống Trợ lý AI Tư vấn Mua sắm & Tối ưu hóa Cấu hình Máy tính Cá nhân Dựa trên Biến thể Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints (MCKP-PCC) và Lý thuyết Hữu dụng Đa thuộc tính (MAUT).

> **Phương pháp Luận Cốt lõi (Core Academic Descriptor):**  
> **"A Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints, solved using deterministic constrained search with Pareto pruning."**

---

## Chương 1: Giới Thiệu & Tổng Quan Đề Tài

### 1.1. Đặt Vấn Đề Thực Tiễn
- Sự bùng nổ của thị trường linh kiện máy tính và thương mại điện tử chuyên ngành phần cứng.
- Khó khăn của người dùng phổ thông trước ma trận thông số kỹ thuật (Socket, RAM generation, Form Factor, Clearance, TDP, Transient Spikes).
- Thách thức về tính bùng nổ tổ hợp ($10^{11} - 10^{13}$ cấu hình tiềm năng) và nguy cơ ảo giác/tính bất định của các giải pháp thuần Large Language Model (LLM).

### 1.2. Mục Tiêu & Phạm Vi Nghiên Cứu
- **Mục tiêu tổng quát:** Xây dựng hệ thống Trợ lý Mua sắm PC thông minh kết hợp giao tiếp ngôn ngữ tự nhiên linh hoạt với lõi tối ưu hóa toán học xác định chính xác 100%.
- **Mục tiêu cụ thể:**
  1. Mô hình hóa hình thức bài toán cấu hình PC thành biến thể bài toán tối ưu tổ hợp MCKPC.
  2. Phát triển giải thuật tối ưu hóa thời gian thực ($< 300\text{ms}$) sử dụng kết hợp Cắt tỉa Pareto bảo toàn tính khả thi và Tìm kiếm Nhánh - Cận.
  3. Xây dựng Khung quản trị tri thức phần cứng 3 tầng (Physical, Engineering, Optimization).
  4. Đảm bảo tính tái lập 100% (Determinism & Order Invariance) và minh bạch số liệu (`MetricEvidence`).

### 1.3. Đóng Góp Chính của Đề Tài
- Định danh và chứng minh mô hình toán học MCKPC cho bài toán PC Builder.
- Đề xuất kỹ thuật bảo toàn năng lực tùy chọn (`preserves_cpu_optional_capabilities`) trong cắt tỉa Pareto để bảo vệ nghiệm biên 0 VNĐ.
- Thiết kế kiến trúc 2 tầng (Dual-Process Architecture): Tầng Giao tiếp Xác suất (PydanticAI Agent) kết hợp Lõi Tối ưu Xác định (Pure Python Core).
- Bộ kiểm thử thuộc tính (Property-based tests) kiểm chứng tính đúng đắn toán học và tương thích cơ - điện.

---

## Chương 2: Cơ Sở Lý Thuyết & Các Nghiên Cứu Liên Quan

### 2.1. Bài Toán Balo Tổ Hợp & Biến Thể MCKPC
- Bài toán Balo 0-1 (0-1 Knapsack Problem) và độ phức tạp NP-hard.
- Multiple-Choice Knapsack Problem (MCKP): Khái niệm phân hoạch tập lớp rời nhau.
- Multiple-Choice Knapsack Problem with Conflicts (MCKPC): Đồ thị xung đột $G = (V, E)$ biểu diễn các ràng buộc không tương thích vật lý.
- Ràng buộc ghép cặp phi tuyến tính động (Dynamic Coupled Constraints trong bài toán bộ nguồn PSU).

### 2.2. Lý Thuyết Hữu Dụng Đa Thuộc Tính (MAUT)
- Nguyên lý cơ bản của MAUT và hàm hữu dụng tuyến tính cộng dồn.
- Phương pháp chuẩn hóa miền điểm $S_i \in [0.0, 100.0]$.
- Xây dựng vector trọng số chuẩn hóa $\sum W_i = 1.0$ cho 18 chính sách đa mục tiêu.

### 2.3. Nguyên Lý Tối Ưu Pareto & Giảm Trừ Không Gian Trạng Thái
- Quan hệ thống trị Pareto (Pareto Dominance Relation) và tập nghiệm không bị thống trị (Pareto Frontier).
- Ứng dụng cắt tỉa Pareto đa chiều để giảm trừ độ phức tạp trước khi duyệt tổ hợp.

### 2.4. Mô Hình Ngôn Ngữ Lớn & Kiến Trúc AI Agent
- Ưu điểm của LLM trong hiểu ngôn ngữ tự nhiên và trích xuất ý định (Intent Extraction).
- Hạn chế cố hữu của LLM: Ảo giác thông số, tính bất định, tính toán số học yếu.
- Kiến trúc Dual-Process AI: Tách biệt System 1 (LLM Agent) và System 2 (Deterministic Solver).
- Kỹ thuật neo dữ liệu thực chứng (Factual Grounding) và Server-Sent Events (SSE).

---

## Chương 3: Phân Tích Bài Toán & Thiết Kế Kiến Trúc Hệ Thống

### 3.1. Mô Hình Hóa Toán Học Hình Thức (Formal Mathematical Formulation)
- Định nghĩa các tập lớp linh kiện $N_1, \dots, N_8$.
- Hệ phương trình ràng buộc Multiple-Choice, Ngân sách tổng, và Cạnh xung đột tương thích.
- Mô hình tải điện duy trì kết hợp dòng quá độ mili-giây (`eng-power-sizing-v1`).
- Hàm mục tiêu đa mục tiêu MAUT.

### 3.2. Kiến Trúc Hệ Thống Tổng Thể (Hexagonal / Clean Architecture)
- Tầng Giao diện (Interface Adapters): FastAPI, SSE Streamer.
- Tầng Ứng dụng (Application Core): PydanticAI Agent, Tool Scoping, Context Management.
- Tầng Cốt lõi (Deterministic PC Optimizer Core).
- Tầng Hạ tầng (Infrastructure Adapters): REST Client kết nối Spring Boot, Qdrant Vector Retriever.

### 3.3. Khung Quản Trị Tri Thức Phần Cứng 3 Tầng (3-Tier Knowledge Governance)
- **Tầng 1 (Physical Ground Truth):** Socket, RAM generation, Clearances, Case form factor explicit membership, CPU grounded facts.
- **Tầng 2 (Engineering Policy):** Công thức tải điện, phụ cấp xung đột biến, 9 kích thước nguồn thương mại, cơ chế chống tràn tải.
- **Tầng 3 (Optimization Policy):** Khung ngân sách thích ứng, chiều Pareto, 18 chính sách MAUT, phân biệt `performance_per_cost` và `budget_saving`.

---

## Chương 4: Thiết Kế & Cài Đặt Thuật Toán Tối Ưu Hóa

### 4.1. Khung Ngân Sách Thích Ứng 2 Tầng (Adaptive Two-Tier Envelopes)
- Cấu trúc `CandidatePool` (`preferred` vs `all_affordable`).
- Cơ chế mở rộng tự động (Adaptive Fallback) bảo toàn nghiệm tối ưu toàn cục.

### 4.2. Cắt Tỉa Pareto Đa Chiều & Thuật Toán Bảo Toàn Feasibility
- Cài đặt hàm `preserves_cpu_optional_capabilities`.
- Nguyên tắc fail-safe khi thiếu dữ liệu thông số (`None`).
- Thuật toán `pareto_prune_all_objectives` hợp nhất các ứng viên qua 3 mục tiêu.

### 4.3. Tìm Kiếm Nhánh - Cận với Bảo Toàn Nghiệm 0 VNĐ & Linh Kiện Sở Hữu
- Khóa slot và hạch toán ngân sách cho linh kiện người dùng có sẵn (`owned_parts`).
- Cơ chế sắp xếp toàn cục theo giá thực chi bảo vệ ứng viên iGPU / Stock cooler 0 VNĐ.
- Kỹ thuật phát hiện xung đột sớm (Early Conflict Detection) theo thứ tự nhân quả.

### 4.4. Thẩm Định Cơ - Điện & Phân Định Hòa Tuyệt Đối (Deterministic Tie-Break)
- Cài đặt kiểm tra kích thước vỏ case hai lớp (Rank Hierarchy + Explicit Membership).
- Tính toán tải nguồn ATX 3.0 và chống tràn tải $>1200\text{W}$.
- Sinh fingerprint 29 thuộc tính chức năng và khóa phân định hòa ổn định.

---

## Chương 5: Thử Nghiệm, Đánh Giá & Kết Quả Thực Nghiệm

### 5.1. Môi Trường Thử Nghiệm & Dữ Liệu Thực Nghiệm
- Cấu hình môi trường Python 3.12, UV, Pytest, Mypy, Ruff.
- Tập dữ liệu danh mục linh kiện phong phú (Realistic Hardware Catalog).

### 5.2. Kết Quả Kiểm Chứng Thuộc Tính (Property-Based Testing)
- 45 kịch bản kiểm thử thuộc tính chứng minh toán học trong `test_pc_optimizer.py`.
- Kiểm chứng tính bất biến trước xáo trộn danh mục (Order Invariance / Determinism).
- Kiểm chứng tính an toàn của pruning (Optimum Pruning ON == Optimum Pruning OFF).
- Kiểm chứng các giới hạn an toàn điện áp và chống bịa đặt linh kiện ảo.

### 5.3. Đánh Giá Hiệu Năng & Độ Trễ (Latency & Resource Utilization)
- Thời gian thực thi trung bình của thuật toán tối ưu hóa: **$50\text{ms} - 150\text{ms}$** (nhanh hơn gấp $50 \times$ so với gọi LLM).
- Mức tiêu thụ bộ nhớ và khả năng mở rộng (Scalability).

### 5.4. Đánh Giá Chất Lượng Đề Xuất & Tính Minh Bạch
- So sánh cấu hình đề xuất giữa Deterministic Engine và chuyên gia con người.
- Phân tích độ chính xác của `ScoreBreakdown` và chứng cứ định lượng `MetricEvidence`.

---

## Chương 6: Kết Luận & Hướng Phát Triển Tương Lai

### 6.1. Kết Luận
- Tổng kết các kết quả đạt được: Hoàn thiện mô hình toán học MCKPC, kiến trúc phần mềm sạch, thuật toán tối ưu hóa thời gian thực và khung quản trị tri thức 3 tầng.
- Ý nghĩa khoa học và thực tiễn của đề tài trong chuyển đổi số thương mại điện tử.

### 6.2. Hướng Phát Triển Tương Lai
- Mở rộng đồ thị xung đột cho các chuẩn tản nhiệt nước AIO đa kích thước (240mm, 280mm, 360mm).
- Tích hợp thêm các bài đo chuyên sâu về độ ồn (dBA) và luồng gió tản nhiệt (Airflow Simulation).
- Huấn luyện mô hình embedding chuyên ngành phần cứng tiếng Việt để tối ưu hơn nữa khả năng trích xuất yêu cầu của LLM Agent.
