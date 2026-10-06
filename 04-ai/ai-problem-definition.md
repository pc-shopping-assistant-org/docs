# Định nghĩa Bài toán Trợ lý AI & Tối ưu hóa Cấu hình PC (AI Problem Definition)

Tài liệu này xác lập định nghĩa bài toán, mô hình hóa toán học chính thức và các ranh giới kiến trúc cho dịch vụ Trí tuệ Nhân tạo (`ai-service`) thuộc hệ thống Trợ lý Mua sắm & Xây dựng Cấu hình PC (`pc-shopping-assistant-org`).

---

## 1. Bối cảnh Nghiệp vụ & Mục tiêu Hệ thống

Người dùng mua sắm máy tính cá nhân (PC) thường gặp khó khăn lớn do:
1. **Kiến thức phần cứng phức tạp:** Có hàng trăm thế hệ linh kiện với các quy chuẩn chân cắm (socket), chuẩn bộ nhớ (DDR4/DDR5), kích thước (form factor) và công suất nguồn khác nhau.
2. **Không gian tìm kiếm bùng nổ:** Danh mục hàng ngàn linh kiện tạo ra hàng chục nghìn tỷ tổ hợp ($10^{11} - 10^{13}$), khiến khách hàng không biết lựa chọn nào tối ưu nhất cho mức ngân sách của mình.
3. **Mâu thuẫn nhu cầu:** Người dùng chơi game cần tối đa GPU; người làm đồ họa 3D/AI cần VRAM và CPU đa nhân; người làm việc văn phòng cần tiết kiệm chi phí; người dùng dài hạn cần khả năng nâng cấp về sau.

**Mục tiêu của Hệ thống AI:**
Xây dựng một trợ lý AI thông minh có khả năng:
- Lắng nghe, thấu hiểu nhu cầu tự nhiên của khách hàng qua hội thoại tiếng Việt/tiếng Anh.
- Tự động trích xuất các ràng buộc ngân sách, mục đích sử dụng và linh kiện đã sở hữu.
- Đề xuất chính xác các cấu hình PC tối ưu toán học, bảo đảm 100% tương thích cơ - điện, không bịa đặt thông số (Zero Fabrication), và giải thích minh bạch dựa trên số liệu thực chứng (`MetricEvidence`).

---

## 2. Mô hình hóa Toán học: Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints (MCKP-PCC)

> **Mô tả Học thuật Chuẩn mực (Formal Academic Descriptor):**  
> **"A Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints, solved using deterministic constrained search with Pareto pruning."**

Về mặt lý thuyết Khoa học Máy tính và Tối ưu hóa Tổ hợp (Operations Research), bài toán tự động cấu hình PC được định danh chính thức là **Biến thể Mở rộng của Multiple-Choice Knapsack Problem with Pairwise Compatibility Constraints (MCKP-PCC / MCKPC)** kết hợp với **Multi-Attribute Utility Theory (MAUT)**.

### 2.1. Không gian Tập hợp & Biến Quyết định
- **Tập hợp Nhóm Linh kiện Rời rạc ($K = 8$):**
  Một bộ PC hoàn chỉnh bắt buộc phải có đủ 8 thành phần:
  $$N_1 = \text{CPU}, \, N_2 = \text{Mainboard}, \, N_3 = \text{RAM}, \, N_4 = \text{GPU}, \, N_5 = \text{Storage}, \, N_6 = \text{PSU}, \, N_7 = \text{Case}, \, N_8 = \text{Cooler}$$
  Mỗi nhóm $k \in \{1, \dots, K\}$ chứa danh sách các ứng viên khả thi $N_k = \{1, 2, \dots, |N_k|\}$.
- **Biến Quyết định Nhị phân:**
  $$x_{kj} \in \{0, 1\} \quad \forall k \in \{1, \dots, K\}, \, j \in N_k$$
  Trong đó $x_{kj} = 1$ nếu linh kiện thứ $j$ thuộc nhóm $k$ được lựa chọn trong cấu hình, ngược lại $x_{kj} = 0$.

### 2.2. Các Ràng buộc Bắt buộc (Hard Constraints)

1. **Ràng buộc Multiple-Choice (Chọn duy nhất 1 linh kiện cho mỗi nhóm):**
   $$\sum_{j \in N_k} x_{kj} = 1 \quad \forall k \in \{1, \dots, K\}$$
   *(Bao gồm cả phương án Đồ họa Tích hợp iGPU hoặc Tản nhiệt kèm theo CPU giá 0 VNĐ nếu CPU hỗ trợ).*

2. **Ràng buộc Ngân sách (Knapsack Capacity Constraint):**
   $$\sum_{k=1}^{K} \sum_{j \in N_k} c_{kj} x_{kj} \le B_{\text{target}}$$
   Trong đó $c_{kj}$ là chi phí thực chi (`spending`) của linh kiện. Nếu linh kiện thuộc danh sách đã sở hữu (`owned_parts`) và được đánh dấu `exclude_from_budget`, $c_{kj} = 0$.

3. **Ràng buộc Đồ thị Xung đột (Conflict Graph Constraints):**
   Định nghĩa đồ thị xung đột $G = (V, E)$ với tập đỉnh $V = \bigcup_{k=1}^K N_k$ và tập cạnh xung đột $E$. Nếu linh kiện $u \in N_a$ và linh kiện $v \in N_b$ vi phạm bất biến cơ học/vật lý:
   $$x_u + x_v \le 1 \quad \forall (u, v) \in E$$
   Các cạnh xung đột đại diện cho:
   - Lệch Socket giữa CPU và Bo mạch chủ: $\text{NormStr}(\text{cpu.socket}) \ne \text{NormStr}(\text{mb.socket})$.
   - Lệch chuẩn RAM giữa Bo mạch chủ và RAM: $\text{NormStr}(\text{mb.ram\_type}) \ne \text{NormStr}(\text{ram.ram\_type})$.
   - Kích thước Bo mạch chủ vượt quá khả năng hỗ trợ của Vỏ Case (kiểm tra phân cấp Rank và thành viên rõ ràng `supported_form_factors`).
   - Chiều dài Card đồ họa vượt quá không gian tối đa của Case: $\text{gpu.gpu\_length\_mm} > \text{case.max\_gpu\_length\_mm}$.
   - Chiều cao Tản nhiệt CPU cấn nắp kính Case: $\text{cooler.cooler\_height\_mm} > \text{case.max\_cooler\_height\_mm}$.
   - Tản nhiệt rời không hỗ trợ Socket của CPU: $\text{NormStr}(\text{cpu.socket}) \notin \text{cooler.supported\_sockets}$.

4. **Ràng buộc Ghép cặp Điện toán Động (Dynamic Coupled Power Constraint):**
   Công suất bộ nguồn (PSU) không độc lập mà phụ thuộc phi tuyến tính vào tải điện tức thời của CPU và GPU:
   $$\sum_{j \in N_{\text{PSU}}} \text{wattage}_j \cdot x_{\text{PSU}, j} \ge \text{round\_up\_psu}\Big(\big(P_{\text{cpu\_peak}}(\mathbf{x}) + P_{\text{gpu\_peak}}(\mathbf{x}) + 65.0\big) \times 1.10\Big)$$
   Và cơ chế chống tràn tải an toàn (Overflow Guard): Nếu nhu cầu vượt quá $1200\text{W}$, ném ngoại lệ `ValueError`.

### 2.3. Hàm Mục tiêu Đa Thuộc tính (MAUT Multi-Attribute Utility)
Tối đa hóa điểm hữu dụng tổng quát của cấu hình:
$$\max_{\mathbf{x}} \quad U(\mathbf{x}) = \sum_{m=1}^{M} W_m \cdot S_m(\mathbf{x})$$
Trong đó:
- $\sum_{m=1}^M W_m = 1.0$ (bộ trọng số được kiểm tra tự động lúc khởi động).
- $S_m(\mathbf{x}) \in [0.0, 100.0]$ là điểm số chuẩn hóa của từng chiều kỹ thuật:
  - Hiệu năng GPU ($S_{\text{gpu\_perf}}$) và CPU ($S_{\text{cpu\_perf}}$).
  - Dung lượng VRAM, RAM, Storage.
  - Chất lượng bộ nguồn ($S_{\text{psu\_quality}}$).
  - Hiệu năng trên giá thành ($S_{\text{cost\_eff}} = \text{performance\_per\_cost}$).
  - Tiềm năng nâng cấp: Độ bền nền tảng ($S_{\text{platform}}$), khe RAM ($S_{\text{ram\_slots}}$), dư địa nguồn ($S_{\text{psu\_headroom}}$).

---

## 3. Ranh giới Kiến trúc: Phân tách Xác định vs Xác suất

Do bài toán MCKPC thuộc lớp bài toán **NP-hard**, việc cố gắng giải bài toán này bằng LLM (mô hình ngôn ngữ xác suất) là sai lầm về mặt bản chất vì LLM không thể bảo đảm các ràng buộc cứng. Do đó, hệ thống áp dụng nguyên tắc phân ranh giới nghiêm ngặt:

```text
┌────────────────────────────────────────────────────────────────────────┐
│               TẦNG XÁC SUẤT (PROBABILISTIC INTERFACE)                  │
│  - Tiếp nhận yêu cầu tự nhiên của khách hàng qua hội thoại.            │
│  - Trích xuất Requirement Extraction -> PCBuildConstraints.            │
│  - Quản lý hội thoại đa lượt, giải thích đề xuất dựa trên số liệu.     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Gọi Tool: optimize_pc_build
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                LÕI TỐI ƯU XÁC ĐỊNH (DETERMINISTIC CORE)                │
│  - 100% Pure Python, giải thuật toán học hình thức, không gọi LLM/mạng.│
│  - Khung ngân sách thích ứng (Adaptive Budget Envelopes).              │
│  - Cắt tỉa Pareto đa chiều bảo toàn Feasibility.                       │
│  - Nhánh - Cận (Branch-and-Bound) bảo toàn nghiệm 0 VNĐ.               │
│  - Thẩm định cơ - điện 2 lớp & Chấm điểm MAUT 18 chính sách.           │
│  - Tie-breaking key 29 thuộc tính đảm bảo 100% tái lập.                │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Quản trị Tri thức Phần cứng 3 Tầng (3-Tier Knowledge Governance)

Để tránh hiện tượng pha trộn giữa quy luật vật lý và quy chuẩn kỹ thuật có thể hiệu chỉnh:
- **Tầng 1 - Physical Ground Truth:** Bất biến cơ học và tiêu chuẩn chân cắm (Socket, RAM type, Clearance, Form factor explicit membership, CPU integrated capabilities). Triết lý: *Thiếu dữ liệu $\to$ `UNKNOWN`*.
- **Tầng 2 - Engineering Policy (`eng-power-sizing-v1`):** Công thức tải đỉnh duy trì, phụ cấp dòng đột biến GPU mili-giây, bậc thang thương mại 9 kích thước chuẩn (gồm 600W), công thức nguồn tối thiểu & khuyến nghị, chống tràn tải $1200\text{W}$.
- **Tầng 3 - Optimization Policy (`opt-*`):** Khung ngân sách theo 6 hồ sơ (`opt-budget-envelope-v1`), chiều cắt tỉa Pareto (`opt-pareto-dominance-v1`), 18 chính sách chấm điểm MAUT (`opt-maut-scoring-v1`).

---

## 5. Tiêu chuẩn Đánh giá & Độ tin cậy (Evaluation & Reproducibility)

Hệ thống được kiểm chứng qua 45 bài kiểm thử thuộc tính (Property-based tests):
1. **Determinism & Order Invariance:** Bất kể catalog đầu vào bị xáo trộn (`shuffle`) ngẫu nhiên thế nào, cấu hình tối ưu trả về luôn là duy nhất.
2. **Feasibility Preservation:** CPU có iGPU hoặc stock cooler không bao giờ bị loại bởi CPU rẻ hơn hoặc xung cao hơn nhưng thiếu năng lực tích hợp.
3. **Zero Spec Fabrication:** Tuyệt đối không tạo linh kiện ảo khi thiếu số liệu thực tế grounded.
4. **Performance:** Thời gian thực thi toàn bộ luồng tối ưu hóa $< 300\text{ms}$, sẵn sàng phục vụ luồng truyền dữ liệu thời gian thực (SSE).
