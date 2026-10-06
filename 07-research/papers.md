# Tài Liệu Nghiên Cứu & Cơ Sở Học Thuật (Academic Research Papers)

Danh mục các công trình nghiên cứu khoa học, bài báo học thuật và sách chuyên khảo làm nền tảng lý thuyết cho hệ thống `ai-service` và mô hình tối ưu hóa cấu hình PC (`pc-shopping-assistant-org`).

---

## 1. Tối Ưu Hóa Tổ Hợp & Biến Thể Bài Toán Balo (Knapsack Problems)

1. **Multiple-Choice Knapsack Problem (MCKP):**
   - **Kellerer, H., Pferschy, U., & Pisinger, D. (2004).** *Knapsack Problems*. Springer Berlin, Heidelberg.
     - *Ý nghĩa:* Giáo trình kinh điển cung cấp định nghĩa toán học, độ phức tạp NP-hard và các giải thuật nhánh - cận (Branch-and-Bound) cho bài toán Multiple-Choice Knapsack Problem (MCKP).
   - **Pisinger, D. (1995).** *A minimal algorithm for the multiple-choice knapsack problem*. Mathematical Programming, 70(1-3), 189-209.
     - *Ý nghĩa:* Kỹ thuật giảm trừ không gian trạng thái và thuật toán tối ưu hóa nhanh cho MCKP.

2. **Knapsack with Conflicts (KPC / MCKPC):**
   - **Pferschy, U., & Schauer, J. (2009).** *The knapsack problem with conflict graphs*. Journal of Graph Algorithms and Applications, 13(2), 233-249.
     - *Ý nghĩa:* Cơ sở lý thuyết cho việc mô hình hóa các ràng buộc không tương thích (incompatibility/conflicts) dưới dạng đồ thị xung đột $G = (V, E)$ kết hợp với bài toán Balo.
   - **Bettinelli, A., Cordeau, J. F., & Malaguti, E. (2017).** *A branch-and-cut-and-price algorithm for the multi-dimensional knapsack problem with conflict graph*. INFORMS Journal on Computing, 29(3), 457-473.
     - *Ý nghĩa:* Chiến lược xử lý các ràng buộc xung đột đa chiều và kỹ thuật cắt tỉa nhánh sớm.

---

## 2. Lý Thuyết Hữu Dụng Đa Thuộc Tính (Multi-Attribute Utility Theory - MAUT)

1. **Nền Tảng MAUT & Ra Quyết Định Đa Mục Tiêu:**
   - **Keeney, R. L., & Raiffa, H. (1993).** *Decisions with multiple objectives: preferences and value trade-offs*. Cambridge University Press.
     - *Ý nghĩa:* Cơ sở lý thuyết nền tảng cho phương pháp chuẩn hóa điểm số $S_i \in [0.0, 100.0]$ và tổng hợp tuyến tính theo vector trọng số $\sum W_i = 1.0$ trong hàm mục tiêu của hệ thống.
   - **Dyer, J. S. (2005).** *MAUT—Multiattribute utility theory*. In Multiple criteria decision analysis: State of the art surveys (pp. 265-292). Springer, Boston, MA.
     - *Ý nghĩa:* Hướng dẫn chuẩn hóa thang đo, kiểm soát tính độc lập thuộc tính (additive independence) trong các bài toán đánh giá kỹ thuật.

---

## 3. Tối Ưu Đa Mục Tiêu & Cắt Tỉa Pareto (Pareto Optimization)

1. **Nguyên Lý Tối Ưu Pareto:**
   - **Deb, K. (2001).** *Multi-objective optimization using evolutionary algorithms*. John Wiley & Sons.
     - *Ý nghĩa:* Định nghĩa hình thức về quan hệ thống trị Pareto (Pareto Dominance relation), tập biên Pareto (Pareto Frontier) và ứng dụng trong lọc ứng viên.
   - **Kung, H. T., Luccio, F., & Preparata, F. P. (1975).** *On finding the maxima of a set of vectors*. Journal of the ACM (JACM), 22(4), 469-476.
     - *Ý nghĩa:* Thuật toán tìm tập không bị thống trị (non-dominated set) hiệu quả làm cơ sở cho hàm `pareto_prune`.

---

## 4. Kiến Trúc AI Agent, Grounding & Tích Hợp Hệ Thống

1. **Phân Tách Hệ Thống Nhận Thức & Xác Định (Dual-Process AI Architectures):**
   - **Kahneman, D. (2011).** *Thinking, Fast and Slow*. Farrar, Straus and Giroux.
     - *Ý nghĩa:* Cảm hứng cho kiến trúc System 1 (LLM Agent xử lý ngôn ngữ tự nhiên linh hoạt) kết hợp System 2 (Deterministic Core giải quyết tính toán logic hình thức và tối ưu hóa tổ hợp chính xác).
   - **Schick, T., et al. (2024).** *Toolformer: Language models can teach themselves to use tools*. Advances in Neural Information Processing Systems (NeurIPS), 36.
     - *Ý nghĩa:* Cơ chế LLM Agent gọi công cụ chuyên biệt (Tool Calling) để vượt qua giới hạn tính toán số học của mô hình ngôn ngữ.
   - **Gou, Z., et al. (2024).** *CRAG - Comprehensive Retrieval-Augmented Generation for Robust Knowledge Grounding*. arXiv preprint arXiv:2401.15884.
     - *Ý nghĩa:* Nguyên tắc neo dữ liệu thực chứng (Factual Grounding via MetricEvidence) nhằm triệt tiêu hoàn toàn ảo giác (hallucination) khi giải thích cấu hình máy tính.
