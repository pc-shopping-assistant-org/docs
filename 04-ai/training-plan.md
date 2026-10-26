# Dataset & fine-tuning cho trợ lý gearPC

## Chúng ta muốn cải thiện điều gì?

Model cần hiểu yêu cầu tiếng Việt, chọn action/tool đúng, hỏi lại khi thiếu thông
tin và dùng evidence để trả lời. Thành công là **hoàn thành yêu cầu tốt hơn**,
không phải trả lời dài hơn hoặc training loss thấp hơn.

Model không học thuộc giá/tồn kho hay thay optimizer. LangGraph/application vẫn
giữ state, quyền merge, tool policy, grounding và publish như [kiến trúc hiện tại](../02-architecture/ai-architecture.md).

Đã chốt **Qwen/Qwen3-8B + SFT/QLoRA**, pin model/tokenizer revision. Code baseline,
trainer, paired evaluation và opt-in Qwen Provider đã có. Lệnh chạy và ranh giới
trách nhiệm: [Runbook](training.md). Chưa chạy GPU job hoặc duyệt51 nhãn pilot.

## Một hành trình để hình dung

| Khách nói | Model cần làm | Ai quyết định state/kết quả? |
| --- | --- | --- |
| “Build 25 triệu, RAM ít nhất 32GB.” | Đề xuất budget cap + capacity requirement, không tự chọn SKU | Application resolve/merge vào working state |
| “Tôi có sẵn card rồi.” | Hỏi model GPU nếu context chưa có | Application giữ requirements cũ |
| “ASUS Dual RTX 4060.” | Tra đúng catalog candidate; không đoán UUID | Resolver bind owned resource khi đủ bằng chứng |
| “Build thử đi.” | Gọi build_pc khi compile-ready, giải thích từ result | Optimizer/verifier tính build; coordinator publish |

Một **scenario** là cả hành trình. Một **sample** là một model call: input model
được thấy tại thời điểm đó và output mục tiêu đã gắn nhãn. Không đưa kết quả tương
lai vào input của bước trước.

## Phạm vi phiên bản đầu

Ba nhóm nhãn, dùng lại DTO của runtime:

- **TASK_EXTRACTION:** user đang yêu cầu BUILD, COMPARE, ANSWER hay giải thích build cũ?
- **REQUIREMENT_EXTRACTION:** user nêu/sửa/xóa yêu cầu nào? Phân biệt hard/soft, owned/pinned,
  SET/CLEAR và không nhắc lại; giữ source span và đơn vị.
- **REACT_DECISION:** chọn một trong CALL_TOOL, PROPOSE_REQUIREMENTS, ASK_CLARIFICATION,
  FINAL_ANSWER theo context/results hiện có.

Scope này chưa cover mọi model call: task/reference/unit reply, amendment và các
head phụ phải được đánh giá riêng trước khi thay provider toàn cục.
Từ protocol v2, model học quote nguyên văn; runtime tính source offsets. Adapter
huấn luyện bằng export cũ phải train lại trước khi dùng với schema mới.

## Các phase và điều kiện hoàn thành

| Phase | Việc chính | Đầu ra / xong khi |
| --- | --- | --- |
| T1 — Chốt bài toán | Chốt nhiệm vụ, contract, rubric, base model/revision và tài nguyên | Cùng hiểu model học gì; có lựa chọn model/GPU/chi phí được owner chấp thuận |
| T2 — Dataset pilot | Viết scenario, đóng băng snapshots, gắn nhãn, kiểm tra và review | Có dataset version; không trộn scenario giữa splits; nhãn được duyệt và xuất được đúng model protocol |
| T3 — Baseline | Chạy model gốc trên bộ đánh giá cố định | Báo cáo lỗi theo nhóm và cấu hình chạy tái hiện được |
| T4 — Train/compare | Train từ nhãn đã duyệt; chọn checkpoint bằng validation set | Adapter/model + config/dataset hashes + so sánh trước/sau trên test set giữ kín |
| T5 — Tích hợp thử | Serving/provider adapter, kiểm tra native tools và structured output | Graph thật hoạt động; các head không train không bị thay ngầm; cấu hình rollback rõ ràng |

Baseline chính là **cùng base model trước fine-tune**. OpenAI/Gemini hiện tại chỉ
là mốc tham khảo bổ sung. Không dùng khác biệt giữa hai base model để kết luận tác
dụng của fine-tuning.

## Dataset pilot hiện có

[Bảng scenario](../../ai-service/training/pilot-v1/SCENARIOS.md) là nơi đọc/duyệt.
[README dataset](../../ai-service/training/pilot-v1/README.md) giải thích format và lệnh kiểm tra.

- 51 samples / 50 scenario: 10 task, 16 requirement, 25 ReAct.
- 39 train / 6 validation / 6 test samples; scenario build nhiều bước ở cùng split.
- Tám snapshots có typed context và tool results; dùng catalog/web mô phỏng, không gọi live API.
- Build snapshot được tạo bằng deterministic optimizer thật với dữ liệu mô phỏng.
- **51 nhãn đều DRAFT.** Validator pass không tự chứng minh ý định đúng, prose đúng hay dataset đủ lớn.

Validator dùng runtime schema/tool policy, kiểm tra source spans/quantities, target
IDs trong snapshot, committed current results, grounding/completion cho FINAL_ANSWER,
file hashes và grouped splits. Reviewer còn phải xét semantics, câu hỏi có cần
thiết không, context có đủ không và các scenario gần trùng có cùng nhóm chưa.

Canonical labels lưu FlexibleDecision để kiểm tra. Exporter đã chuyển CALL_TOOL
thành native tool_calls và giữ matched tool messages. Prompt builders/schema/parser
dùng chung runtime, không chép một bản riêng cho training. Chỉ export dữ liệu đã
duyệt; test targets không thành file SFT. Export vẫn **chưa tokenizer-ready**:
chat template, tools và structured schema phải được kiểm chứng trên base model đã chọn.

## Cách tạo và duyệt thêm dữ liệu

1. Viết scenario bằng ngôn ngữ khách dùng, kèm hành vi mong đợi.
2. Tạo từng sample với exact user message và snapshot trước quyết định.
3. Tạo target đúng contract. Unknown/ambiguous SKU hoặc units phải giữ unknown/hỏi lại.
4. Chạy validator; reviewer đọc cả hành trình, sửa nhãn sai hoặc không cần thiết.
5. Chỉ người được giao duyệt mới đổi APPROVED và điền reviewed_by; cập nhật hashes,
   tạo dataset version mới trước baseline/train.

Teacher model có thể tạo bản nháp nhưng không tự duyệt chính nó. Không đưa raw
production chat vào dataset; muốn dùng cần nguồn dữ liệu hợp lệ và loại thông tin
cá nhân/secrets. Log/trace hiện chỉ là metadata vận hành, không phải corpus training.

## Đánh giá và chạy training

[Evaluation plan](../06-evaluation/evaluation-plan.md) định nghĩa metrics và fair comparison.
Không ép chỉ một tool sequence: target SFT là ví dụ tốt; đánh giá phải cho phép
những đường đi khác vẫn đúng policy và hoàn thành task.

Recipe đã implement: TRL/PEFT + bitsandbytes NF4 4-bit, LoRA all-linear; config ở
[qwen3-8b.json](../../ai-service/training/qwen3-8b.json). Training dependencies và
vLLM ở môi trường riêng, không cài vào runtime image. Không tự chạy GPU job,
tải weights, đặt mua compute hoặc promote model.
Tham khảo [TRL SFT](https://huggingface.co/docs/trl/en/sft_trainer).

CI thường kiểm tra dataset/contract/tests. Training chạy chủ động trên tài nguyên
đã chọn, không tự chạy mỗi push và không tự promote model vào runtime.

## Trạng thái và bước tiếp theo

| Phase | Hiện tại |
| --- | --- |
| T1 | Chốt scope, rubric, Qwen3-8B revision và QLoRA; GPU execution chưa verify |
| T2 | Có pilot/validator/export và Qwen completion mask; còn review nhãn và native tokenizer verification |
| T3 | Có inference capture + evaluator; chưa baseline model thật hoặc conversation evaluation |
| T4 | Có QLoRA trainer/manifest + paired comparison; chưa train GPU hoặc quality comparison thật |
| T5 | Có opt-in Qwen Provider và serving command; chưa GPU/vLLM/graph live smoke hoặc promote |

Lệnh chạy A→Z: [Training runbook](training.md).
Evaluator giữ case lỗi/thiếu trong mẫu số và tách protocol/schema khỏi semantic
review; không dùng gold target làm prediction hay coi PASS là hiểu đúng ý user.

**Bước tiếp:** duyệt scenario, kiểm chứng native tokenizer trên máy training,
sau đó thu response model thật để chạy baseline/train. Không công bố phần trăm cải thiện
khi chưa có kết quả T3/T4.
