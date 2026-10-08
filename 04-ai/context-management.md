# Context management

`ConversationManager` hiện giữ history trong process dưới dạng deque giới hạn
bởi `AI_CONVERSATION_MAX_MESSAGES` (mặc định 20). Mỗi message chỉ có `role`
(`user` hoặc `assistant`) và content có giới hạn độ dài.

Chat dùng tối đa sáu message gần nhất để tạo prompt grounded. Restart process
sẽ mất history; chưa có claim multi-instance hoặc durable conversation. Khi cần
scale, thay implementation này theo
[stateful chat plan](stateful-chat-implementation-plan.md) và
[B0 contracts](stateful-chat-contracts.md), không tự coi RAM là durable state.
V1 stateful chat đã chốt login-only; BUILD_PC mặc định chỉ case PC, FULL_SETUP
thêm màn hình/chuột/phím/tai nghe (tối đa một cái/type), không tự chia ngân sách.
Owned không tính tiền, pinned vẫn tính tiền. Retention chat/run/checkpoint 90 ngày,
orphan/debug checkpoint 7 ngày; xóa conversation xóa dữ liệu liên quan;
debug/replay chỉ internal và không publish kết quả thật. Async ownership store,
PostgreSQL saver và runtime routes vẫn chưa triển khai. B0 schemas không thay
history store hiện tại; native checkpoint gate phải pass trước B1 completion.
