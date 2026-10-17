# Đánh giá model trước và sau fine-tuning

## Câu hỏi cần trả lời

Model sau train có hiểu yêu cầu và dùng tools tốt hơn **cùng model trước train**,
trên những scenario chưa được dùng để train/chọn checkpoint không?

Phạm vi và tiến độ: [Training plan](../04-ai/training-plan.md).
Pilot hiện còn DRAFT; chưa có kết quả thực nghiệm hay baseline score.

## Runner hiện có

[Offline workflow](../../ai-service/training/README.md) hướng dẫn export input và
chấm captured responses. Mặc định validation; test phải chọn rõ `--split test`.
Không inference, repair, training hoặc đọc credentials trong evaluator.

Report gồm raw_contract_valid, validated và mẫu số theo task, kết quả từng case,
response lỗi/thiếu, request/dataset/response/lock hashes và model/run config.
Unknown/duplicate IDs hoặc request_hash lệch bị từ chối để tránh chấm nhầm input.
PASS chỉ là qua kiểm tra máy; matches_authored_target là tham khảo, không là
task accuracy. Semantic review vẫn REQUIRED; conversation-level runner chưa có.
Qwen inference runner thu response từ vLLM thật rồi gọi evaluator; paired
comparison kiểm tra cùng base revision, dataset/split, source/config/decoding và
input hashes. Không lấy gold làm prediction hoặc tự promote. [Runbook](../04-ai/training.md).

## Hai mức đánh giá

| Mức | Kiểm tra | Giới hạn |
| --- | --- | --- |
| Model call | Typed extraction/action, tool args, source evidence, clarification và final candidate | Đúng schema chưa chứng minh hiểu ý user |
| Conversation | Chạy qua graph/application với snapshots cố định, xem task và state cuối | Dùng fixture không chứng minh live web/catalog/provider quality |

Không dùng training loss thay chất lượng hội thoại. Không chấm đúng/sai bằng
việc câu trả lời giống hệt một chuỗi text hoặc một tool sequence vàng.

## Rubric

| Tiêu chí | Cách chấm |
| --- | --- |
| Contract validity | Tỉ lệ output parse được đúng task/action/native tool protocol; raw invalid và sau repair báo riêng |
| Requirement fidelity | Giữ đúng amount/unit/operator/strength/owned/pinned/SET/CLEAR; không thêm/xóa yêu cầu không có source hoặc consent |
| Tool use | Tool thuộc allowed subset, args hợp lệ và giúp giải quyết task; chấp nhận lựa chọn khác nếu vẫn đúng policy/evidence |
| Clarification | Hỏi thông tin thực sự thiếu; không hỏi lại điều context đã biết; không suy consent từ câu không liên quan |
| Grounding/completion | Refs/quotes có trong input; BUILT có receipt/verifier; INFEASIBLE khác SEARCH_INCOMPLETE; không tự tạo price/FPS |
| Conversation success | User task đạt đúng điều kiện hoàn thành; state mới giữ các yêu cầu không đổi và publish qua application |
| Efficiency | Model/tool calls, latency và provider-reported usage nếu có; không quy các proxy này thành billing guarantee |

Các validator deterministic chấm phần machine-checkable. Reviewer chấm intent,
relevance và chất lượng diễn giải theo rubric. Giữ kết quả fail cùng nguyên nhân;
không loại case model làm sai khỏi mẫu số.

## Thiết kế thực nghiệm

1. Duyệt nhãn trước; giữ cùng scenario/paraphrase family trong một split. Rà gần
   trùng bằng reviewer, không chỉ dựa vào sample IDs.
2. Chốt base model/revision/tokenizer/chat template, prompts/tool schemas và snapshot
   versions. Chạy baseline với cùng input mà model sau train sẽ nhận.
3. Chỉ dùng train để cập nhật weights; dùng validation để chỉnh config/chọn checkpoint.
   Không đọc test labels để sửa prompt/dataset. Nếu đã dùng test để tune thì phải
   tạo holdout mới và ghi rõ lần test cũ đã bị tiêu thụ.
4. Đánh giá before/after trên cùng held-out scenarios, cùng tool backend snapshots,
   decoding/limits/retry policy và hardware/serving setup. Báo initial failures và
   chi phí repair, không chỉ output cuối đã được sửa.
5. OpenAI/Gemini có thể là baseline vận hành bổ sung, không là đối chứng nhân quả
   thay cho chính base model trước fine-tune.

Pilot51 mẫu/50 scenario đủ để kiểm tra data path và rubric; không đủ để tự tuyên bố
cải thiện rộng. Mở rộng theo lỗi baseline và báo mẫu số/số lượng từng nhóm; không
chỉ công bố một điểm trung bình che nhóm yếu.

## Artifacts cần giữ

Dataset/split hashes; base/adapter/tokenizer revisions; code/prompt/schema versions;
training config/seed; decoding/retry limits; kết quả từng sample/scenario; report
theo nhóm và ví dụ lỗi. Snapshot giá/tồn kho là dữ liệu của thời điểm thử nghiệm,
không thành thông tin sản phẩm hiện hành.

## Khi nào được tích hợp?

Owner chốt ngưỡng chất lượng và giới hạn tài nguyên sau baseline, trước chọn release.
Kết quả phải cải thiện mục tiêu đã chọn, không làm hỏng core requirement/authority/
evidence checks, và tương thích protocol trong graph thật. Bất kỳ lỗi required
correctness nào phải được sửa hoặc ngăn promote; không thay app validators bằng
model score. Tích hợp chủ động, có rollback, không tự promote từ job training.
