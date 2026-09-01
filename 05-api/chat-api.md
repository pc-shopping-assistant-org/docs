# AI HTTP API

Base path: `/api/v1`

| Endpoint | Use case | Success message key |
| --- | --- | --- |
| `POST /chat` | Chatbot interaction | `AI_CHAT_COMPLETED` |
| `POST /chat/stream` | Streaming chatbot interaction (SSE) | `AI_CHAT_STREAM_COMPLETED` |
| `POST /search` | Natural-language product search | `AI_SEARCH_COMPLETED` or `AI_SEARCH_NO_RESULTS` |
| `POST /consult` | Product consultation | `AI_CONSULT_COMPLETED` |
| `POST /compare` | Product comparison | `AI_COMPARE_COMPLETED` or `AI_COMPARE_PARTIAL` |
| `POST /evaluate` | Product explanation | `AI_EVALUATION_COMPLETED` |

All responses have `{data, message, errors}`. Validation, unavailable-backend
and missing-product conditions use a static top-level key and put details in
`errors[]`.

## Streaming chat

`POST /api/v1/chat/stream` accepts the same body as `/chat`:

```json
{
  "message": "Tìm laptop gaming dưới 30 triệu",
  "conversation_id": null
}
```

The response uses `Content-Type: text/event-stream`. Each SSE `data` frame is
still the canonical envelope; the event header is only a transport hint. The
`data.event` value is one of `START`, `DELTA`, `COMPLETED`, or `ERROR`:

```text
event: delta
data: {"data":{"event":"DELTA","conversation_id":"…","delta":"Xin "},"message":"AI_CHAT_STREAM_DELTA","errors":[]}
```

- `START` provides the conversation id and uses
  `AI_CHAT_STREAM_STARTED`.
- `DELTA` contains an incremental text chunk and uses
  `AI_CHAT_STREAM_DELTA`.
- `COMPLETED` contains the normal `ChatData` in `data.result` and uses
  `AI_CHAT_STREAM_COMPLETED`.
- `ERROR` is terminal and uses `AI_CHAT_STREAM_FAILED`; details are in
  `errors[]`.

The frontend BFF forwards the stream without buffering it. Clients should
cancel the request when the view unmounts or the user starts another turn.
