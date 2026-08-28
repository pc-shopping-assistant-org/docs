# PC Shopping Assistant Documentation

Tài liệu của dự án được chia theo câu hỏi cần trả lời:

- `01-overview/`: dự án giải quyết vấn đề gì và phạm vi đến đâu.
- `01-business/`: người dùng làm gì, hệ thống phải làm gì và luật nào bắt buộc đúng.
- `02-architecture/`: các thành phần kỹ thuật và cách triển khai.
- `03-data/`: product model, database và metadata.
- `04-ai/`: agent, tools, context, RAG và model strategy.
- `05-api/`: contract giữa frontend, backend và AI service.
- `06-evaluation/`: test cases, metrics và kết quả đánh giá.
- `07-research/`: paper và related work.
- `08-thesis/`: outline và nội dung phục vụ luận văn.

## Source of truth

- Luật nghiệp vụ nằm trong `01-business/business-rules.md`.
- Luồng người dùng nằm trong `01-business/workflows/`.
- Schema dữ liệu nằm trong `03-data/`.
- API contract nằm trong `05-api/`.

Khi code và tài liệu mâu thuẫn, phải ghi nhận quyết định thay đổi trong tài liệu tương ứng thay vì âm thầm đổi một phía.
