# UC-CAT-004 — Lọc sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CAT-004` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40; Chương 5.1.3–5.1.4 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Lọc sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Danh sách sản phẩm có thể truy cập (không cần đăng nhập).

## Điều kiện sau

Danh sách được thu hẹp theo điều kiện lọc.

## Luồng chính

1. Người dùng chọn phân loại/danh mục, nhãn hàng và/hoặc khoảng giá.
2. Hệ thống áp dụng bộ lọc: danh mục khớp cả sản phẩm thuộc danh mục con (chọn "Linh kiện" thì ra cả "Card đồ họa"), thương hiệu khớp thương hiệu của sản phẩm, khoảng giá khớp khi ít nhất một variant đang bán có giá trong khoảng (sản phẩm có biến thể 1 triệu và 9 triệu thì khoảng 3 đến 5 triệu không khớp; có thể chỉ đưa một đầu). Các bộ lọc kết hợp được với nhau và với từ khóa; chọn lọc xong quay về trang đầu.
3. Hiển thị kết quả cùng tổng số sản phẩm khớp. Khi không có từ khóa, Catalog Service lọc; khi có từ khóa, search-service lọc cùng nghĩa (xem UC-CAT-003).

## Luồng thay thế / ngoại lệ

- Không có sản phẩm thỏa bộ lọc → danh sách rỗng.
- Khoảng giá sai (giá âm hoặc giá thấp nhất lớn hơn giá cao nhất) → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
