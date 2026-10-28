# UC-ADM-PAY-003 — Tìm kiếm giao dịch thanh toán

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PAY-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm giao dịch thanh toán theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Có dữ liệu thanh toán.

## Điều kiện sau

Các giao dịch phù hợp được hiển thị.

## Luồng chính

1. Nhập mã giao dịch, mã đơn, khách hàng, trạng thái hoặc khoảng thời gian tạo.
2. Hệ thống tìm kiếm. Nếu nhập tên khách thì hệ thống hỏi Identity Service lấy danh sách khách phù hợp rồi lọc theo đó (kết hợp với mã khách nếu có cả hai). Không khách nào khớp tên thì trả danh sách rỗng.
3. Hiển thị kết quả theo số trang (mỗi trang 1–100, mặc định 50), mới nhất trước, kèm tổng số.

## Luồng thay thế / ngoại lệ

- Số trang âm, kích thước trang ngoài 1–100, hoặc thời điểm bắt đầu không trước thời điểm kết thúc → từ chối.
- Identity Service không trả lời khi tìm theo tên khách → báo lỗi.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
