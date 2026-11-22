# Train và chạy Qwen cho gearPC

Model đã chốt: **Qwen/Qwen3-8B, SFT bằng QLoRA**. Revision được pin trong
[config](../../ai-service/training/qwen3-8b.json), không tự chạy theo `main`.
Đây là fine-tune model có sẵn, không pretrain và không thay optimizer.

```text
Dataset được duyệt → baseline Qwen → SFT/QLoRA → adapter
                          │                       │
                          └── cùng input/config ──┘
                                      ↓
                            paired evaluation
                                      ↓
                         review → opt-in serving
```

## Trước khi chạy

- Chạy các lệnh từ `ai-service/`, trên máy có NVIDIA GPU/CUDA tương thích.
- Pilot hiện có51 nhãn **DRAFT**. Phải review và tạo dataset version đã duyệt;
  các lệnh inference/train sẽ từ chối DRAFT, không có cờ bỏ qua.
- Pin serving package trong [serving requirements](../../ai-service/training/serving-requirements.txt).
  Chưa kiểm chứng GPU/vLLM thực tế; package lock và test fixture không chứng minh
  đủ VRAM, CUDA tương thích hoặc chất lượng tiếng Việt.

## 1. Hai môi trường, một repo

Training và serving tách môi trường để tránh xung đột PyTorch/vLLM. Server FastAPI
không import GPU libraries; Docker runtime không cài dependency group training.

```bash
UV_PROJECT_ENVIRONMENT=.venv-training uv sync --locked --group training
uv venv .venv-serving --python 3.12
uv pip install --python .venv-serving/bin/python -r training/serving-requirements.txt
```

Các lệnh dưới dùng dataset `training/reviewed-v1`: đây là đường dẫn cho version
**bạn đã review**, không phải file đang có sẵn hoặc bản tự đổi APPROVED của pilot.

## 2. Kiểm tra dataset

```bash
uv run python -m ai_service.training training/reviewed-v1 --require-approved
```

Canonical labels/snapshots phải có hashes đúng, grouped splits và source evidence.
Xem [pilot](../../ai-service/training/pilot-v1/SCENARIOS.md), [plan](training-plan.md)
và [evaluation rubric](../06-evaluation/evaluation-plan.md).

## 3. Serve base model và lấy baseline

Terminal thứ nhất:

```bash
uv run python -m ai_service.training.serve --config training/qwen3-8b.json --executable .venv-serving/bin/vllm --execute
```

Bỏ `--execute` để chỉ in command, không tải/chạy weights. Server bind localhost:8001,
pin cả model/tokenizer revision, tắt thinking, bật native Hermes tool parser.

Terminal thứ hai, sau khi vLLM sẵn sàng:

```bash
uv run python -m ai_service.training.inference training/reviewed-v1 --config training/qwen3-8b.json --base-url http://localhost:8001/v1 --output training/artifacts/baseline-v1
```

Mặc định validation, không repair/retry. Mỗi case gọi endpoint thật, lưu raw response,
usage/latency nếu có, lỗi và input hashes; không lấy target làm prediction.
Nếu serving có authentication, export `AI_QWEN_API_KEY` trong shell của CLI.

## 4. Train adapter

Dừng vLLM trước nếu dùng cùng GPU, rồi chạy:

```bash
UV_PROJECT_ENVIRONMENT=.venv-training uv run --no-sync python -m ai_service.training.train training/reviewed-v1 --config training/qwen3-8b.json --output training/artifacts/qwen-v1
```

Recipe: NF4 4-bit/double quantization, LoRA `all-linear`, completion-only loss.
Prompt, history và tool results không bị dùng làm target. Chat template gốc phải
giữ đúng prefix; example quá dài bị từ chối, không âm thầm cắt source hoặc output.

Chỉ train/validation được nạp vào trainer. Chọn checkpoint theo validation loss;
đây **không phải** chứng nhận semantic quality. Output giữ run/config/dataset/code/
template hashes, adapter weights và file hashes. Job lỗi chưa tạo manifest hoàn
chỉnh thì không được xem là adapter sẵn sàng serving. Không ghi đè output cũ.

Batch, context, learning rate, epochs, seed và LoRA settings nằm trong config trên.
BF16 dùng khi GPU hỗ trợ, nếu không dùng FP16; không có cam kết VRAM tối thiểu.

## 5. Serve adapter, chạy cùng bộ đánh giá

```bash
uv run python -m ai_service.training.serve --config training/qwen3-8b.json --adapter training/artifacts/qwen-v1 --executable .venv-serving/bin/vllm --execute
```

Sau khi server sẵn sàng, ở terminal khác:

```bash
uv run python -m ai_service.training.inference training/reviewed-v1 --config training/qwen3-8b.json --base-url http://localhost:8001/v1 --adapter training/artifacts/qwen-v1 --output training/artifacts/adapted-v1
uv run python -m ai_service.training.compare training/artifacts/baseline-v1/report.json training/artifacts/adapted-v1/report.json --output training/artifacts/comparison-v1.json
```

Serving giữ pinned base tokenizer/template, không lấy template do trainer tự patch.
Comparison từ chối khác base revision, dataset/split, code, decoding, config hoặc
input hashes. FAIL/MISSING vẫn nằm trong mẫu số. Chỉ dùng `--split test` ở cả hai
lượt khi đã chốt đánh giá cuối; không dùng test để chỉnh config/chọn checkpoint.

PASS là qua kiểm tra máy, không là hiểu đúng ý user. Cần review intent, relevance,
grounding và chạy hội thoại thật trước khi promote. Không tự promote theo score.

## 6. Bật thử provider trong AI service

Sau review và khi vLLM đang chạy, cấu hình `.env` local:

```dotenv
AI_PROVIDER=qwen
AI_QWEN_BASE_URL=http://localhost:8001/v1
AI_QWEN_MODEL_NAME=gearpc-qwen3-8b
AI_QWEN_MAX_TOKENS=2048
AI_QWEN_REQUEST_TIMEOUT_SECONDS=120
```

Provider dùng lại native contracts. Dataset giữ nhãn nội bộ `TaskDraftBatch` và
`RequirementDraft`; export chuyển sang `QuotedTaskBatch` và
`QuotedRequirementDraft` đúng schema runtime. Offset chỉ được tính sau khi model
trả quote. Adapter train từ export cũ không tương thích với protocol v2.
ReAct dùng protocol `compact-native-tools-v5`: response hội thoại là text; proposal,
clarification và result selection là native function calls. `FlexibleDecision` chỉ
là nhãn nội bộ; không export JSON envelope/full union vào prompt. Export và serving
dùng cùng request projection/parser; application suy ra outcome từ canonical results.
Target business action có thể chứa mảng native tool calls. Serving/export cùng bật
parallel tool calls; application giữ giới hạn batch và policy cho từng call.
Export map nhãn canonical sang compact wire giống serving, kiểm tra từng target
against schema thực sự expose trong state đó. Proposal dùng items phẳng/value/unit/quote;
submit dùng refs/calls và chỉ có quotes/review khi readable web evidence cho phép.
Artifacts v3/v4 phải re-export/review, không âm thầm approve hoặc sửa nhãn.
Head TASK_EXTRACTION độc lập vẫn đọc được cho offline evaluation, không còn là
bước bắt buộc của runtime. Pilot hiện có chưa được relabel cho protocol mới.

Export ghi `react_protocol` trong manifest. Artifacts/adapter train bằng JSON protocol
cũ phải regenerate/retrain trước dùng protocol mới; không tự overwrite weights hay
approve labels. Pilot vẫn giữ trạng thái review gốc. Clarification có thể được expose
nhưng application phải kiểm tra đúng thông tin thiếu; schema hợp lệ không chứng minh
ý định đúng. Export chặn các action không được expose.

`prepare_qwen_request` là projection chung cho serving và training: schema JSON đầy
đủ của **structured extraction heads** đi vào system message, còn tool/control schema
giữ ở native `tools`; không chèn schema lần hai trong extractor. ReAct/tool-calling và hai structured heads trên dùng
adapter; choice/amendment chưa train dùng base `Qwen/Qwen3-8B` trên cùng vLLM
server. Không tự chuyển provider khi Qwen lỗi. Dùng model base thay alias để thử
chưa fine-tune; rollback provider bằng cấu hình. Runtime vẫn yêu cầu DB/JWKS;
hardware taxonomy lấy trực tiếp từ catalog.

## Code nằm ở đâu?

| Thành phần | Source |
| --- | --- |
| Dataset/labels và gates | [training/dataset.py](../../ai-service/src/ai_service/training/dataset.py) |
| Qwen config + loss mask | [qwen_config.py](../../ai-service/src/ai_service/training/qwen_config.py), [qwen_data.py](../../ai-service/src/ai_service/training/qwen_data.py) |
| Train/capture/compare/serve | [training package](../../ai-service/src/ai_service/training/) |
| Provider + shared input projection | [qwen.py](../../ai-service/src/ai_service/infrastructure/providers/qwen.py), [qwen_protocol.py](../../ai-service/src/ai_service/infrastructure/providers/qwen_protocol.py) |

Library references: [Qwen model](https://huggingface.co/Qwen/Qwen3-8B),
[TRL pre-tokenized SFT](https://huggingface.co/docs/trl/en/sft_trainer),
[PEFT quantization](https://huggingface.co/docs/peft/en/developer_guides/quantization),
[vLLM LoRA](https://docs.vllm.ai/en/latest/features/lora/).
