# Tầng 2 — Engineering policy

> **Phân loại Quản trị:** Tầng 2 — Chính sách Kỹ thuật Thực nghiệm (Engineering Policy)  
> **Mã Chính sách:** `eng-power-sizing-v1`  
> **Phiên bản:** 1.0.0  
> **Ngày hiệu lực:** 2026-10-06  
> **Phạm vi:** Heuristics versioned của dự án, không phải chứng nhận ATX hoặc
> số đo tiêu thụ thực tế. Source: `capabilities/pc_builder/optimizer.py`.
> Optimizer enforce iGPU transient=0; reuse configuration ghi
> `power_sizing_version=eng-power-sizing-v1`. ISSUE-101 đã đóng bằng core tests.

---

## 2.1. Công thức Tính toán Tải Đỉnh Duy trì (Sustained Peak Load)

Công suất tải đỉnh duy trì của dàn máy được ước tính qua tổng tiêu thụ năng lượng các thành phần:

$$P_{\text{base}} = 65.0\text{W} \quad (\text{Mainboard: 30W, RAM: 10W, NVMe: 10W, Fan/RGB: 15W})$$
$$P_{\text{cpu\_peak}} = \text{TDP}_{\text{cpu}} \times \begin{cases} 1.20 & \text{nếu } \text{TDP}_{\text{cpu}} \ge 105\text{W} \\ 1.10 & \text{nếu } \text{TDP}_{\text{cpu}} < 105\text{W} \end{cases}$$
$$P_{\text{gpu\_peak}} = \text{TDP}_{\text{gpu}}$$
$$P_{\text{sustained}} = P_{\text{cpu\_peak}} + P_{\text{gpu\_peak}} + P_{\text{base}}$$

---

## 2.2. Phụ cấp Dòng Đột biến (Transient Spike Allowance)

Các kiến trúc GPU hiện đại (NVIDIA Ada Lovelace / Ampere, AMD RDNA 2/3) có hiện tượng quá dòng mili-giây rất lớn. Phụ cấp đột biến được quy định theo ngưỡng tiêu thụ:

$$P_{\text{transient}} = \begin{cases} 
0.0\text{W} & \text{nếu GPU tích hợp (iGPU)} \\
\text{TDP}_{\text{gpu}} \times 0.30 & \text{nếu } \text{TDP}_{\text{gpu}} \ge 280\text{W} \quad (\text{RTX 4080/4090, RX 7900 XTX}) \\
\text{TDP}_{\text{gpu}} \times 0.20 & \text{nếu } \text{TDP}_{\text{gpu}} \ge 180\text{W} \quad (\text{RTX 4070/4070 Ti, RX 7800 XT}) \\
\text{TDP}_{\text{gpu}} \times 0.12 & \text{nếu } \text{TDP}_{\text{gpu}} < 180\text{W} \quad (\text{RTX 4060/4060 Ti, RX 7600})
\end{cases}$$

---

## 2.3. Quy chuẩn Công suất Nguồn (PSU Capacity Sizing)

Hệ thống tính toán hai chỉ số công suất nguồn phục vụ kiểm tra tương thích và khuyến nghị:

1. **Công suất Nguồn Tối thiểu Bắt buộc (Minimum Capacity):**
   Policy thêm 10% margin cho estimated sustained load, không chứng nhận nguồn thực tế:
   $$\text{Target}_{\text{min}} = P_{\text{sustained}} \times 1.10$$
   $$\text{Minimum PSU} = \text{round\_up\_psu}(\text{Target}_{\text{min}})$$
2. **Công suất Nguồn Khuyến nghị Tối ưu (Recommended Capacity):**
   Heuristic recommendation thêm transient allowance và 50W buffer, không guarantee hấp thụ mọi excursion:
   $$\text{Target}_{\text{rec}} = P_{\text{sustained}} + P_{\text{transient}} + 50.0\text{W}$$
   $$\text{Recommended PSU} = \text{round\_up\_psu}(\text{Target}_{\text{rec}})$$

---

## 2.4. Bậc thang Công suất Thương mại Chuẩn & Xử lý Tràn tải (Overflow Guard)

Thuật toán làm tròn lên cấp nguồn hỗ trợ trong policy V1 (`round_up_psu`);
1200W là trần bảng cấu hình của dự án, không phải công suất lớn nhất trên thị trường:

$$\text{STANDARD\_PSU\_SIZES} = (450, 500, 550, 600, 650, 750, 850, 1000, 1200) \quad [\text{Watts}]$$

> **Cơ chế Chống Tràn Tải (Overflow Guard):**  
> Nếu công suất yêu cầu vượt quá $1200\text{W}$, hệ thống lập tức ném ngoại lệ kỹ thuật:  
> `ValueError` (diagnostic string không phải stable HTTP error key).
> Nghiêm cấm việc ép về 1200W gây sập nguồn hoặc nguy cơ hỏa hoạn.

---

## 2.5. Ánh xạ Chất lượng Nguồn (PSU Tier Mapping) & Fail-Safe

Chất lượng bộ nguồn được lượng hóa trên thang điểm 100:

| Bậc Nguồn (PSU Tier) | Điểm số Chuẩn hóa | Đặc tả Kỹ thuật                                                  |
| :------------------- | :---------------- | :--------------------------------------------------------------- |
| **Tier A**           | `100.0`           | Full-bridge LLC, tụ Nhật 105°C, Full Modular, Gold/Platinum      |
| **Tier B**           | `85.0`            | Half-bridge LLC / DC-to-DC, linh kiện chất lượng cao             |
| **Tier C**           | `70.0`            | Double Forward / DC-to-DC, Bronze tiêu chuẩn an toàn              |
| **Tier D**           | `50.0`            | Nguồn cấp thấp văn phòng cơ bản                                  |
| **Không xác định**   | `None`            | **Fail-Safe:** Không gán điểm ngầm 50.0; không prune trong so sánh |
