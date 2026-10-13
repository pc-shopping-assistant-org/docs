# Hardware compatibility

Chỉ kiểm tra các rule đã model hóa, không chứng nhận toàn bộ khả năng lắp ráp.
Metadata lấy từ catalog canonical; không suy specs thiếu từ tên sản phẩm.

## Rules

| Rule | PASS | Thiếu dữ liệu |
| --- | --- | --- |
| CPU ↔ mainboard | Socket chuẩn hóa trùng nhau | UNKNOWN |
| RAM ↔ mainboard | ram_type chuẩn hóa trùng nhau | UNKNOWN |
| Mainboard ↔ case | Form factor nằm trong supported_form_factors của case | UNKNOWN |
| GPU ↔ case | gpu_length_mm ≤ max_gpu_length_mm; bỏ qua iGPU | UNKNOWN |
| Cooler ↔ case | cooler_height_mm ≤ max_cooler_height_mm | UNKNOWN |
| Cooler ↔ CPU | CPU socket nằm trong supported_sockets | UNKNOWN |

Có dữ liệu nhưng không thỏa rule → INCOMPATIBLE. UNKNOWN không được coi là PASS.
Chuẩn hóa: trim, uppercase, bỏ dấu cách và dấu gạch nối; ví dụ am-5 → AM5.
Không suy case hỗ trợ Micro-ATX chỉ vì đã khai báo ATX.
Danh sách hỗ trợ thiếu/rỗng hoặc chứa giá trị trắng → UNKNOWN; không fallback rank.

## iGPU và stock cooler

Chỉ tạo phương án tích hợp khi đủ metadata từ CPU:

| Option | Metadata bắt buộc | Giá mua thêm |
| --- | --- | --- |
| iGPU | has_integrated_graphics=true; integrated_graphics_score và integrated_graphics_power_watts có giá trị | 0 VND |
| Stock cooler | includes_stock_cooler=true; stock_cooler_height_mm, stock_cooler_tdp_watts và stock_cooler_score có giá trị | 0 VND |

UUIDv5 dùng namespace cố định, seed stable_component_id(cpu) + :igpu hoặc :stock_cooler.
Đây là internal synthetic identity, không phải SKU catalog; không thay owned/pinned part.

## Giới hạn

Chưa kiểm tra BIOS/chipset, RAM DIMM/SO-DIMM và radiator.
Số khe RAM thuộc scoring nâng cấp, không phải compatibility.
PSU sizing theo [engineering policy](02-engineering-policies.md).

## Lệch implementation

- Cooler socket: code còn chấp nhận fallback cooler.socket khi thiếu supported_sockets.
- Stock cooler: code còn cho phép thiếu TDP.

Các lệch trên cần xử lý trong code; tài liệu này không khẳng định đã enforce.
