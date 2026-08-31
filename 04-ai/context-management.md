# Context management

`ConversationManager` hiện giữ history trong process dưới dạng deque giới hạn
bởi `AI_CONVERSATION_MAX_MESSAGES` (mặc định 20). Mỗi message chỉ có `role`
(`user` hoặc `assistant`) và content có giới hạn độ dài.

Chat dùng tối đa sáu message gần nhất để tạo prompt grounded. Restart process
sẽ mất history; chưa có claim multi-instance hoặc durable conversation. Khi cần
scale, thay implementation này bằng Redis/database store mà không đổi HTTP
contract.
