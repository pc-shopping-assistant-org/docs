# AI HTTP API

Base path: `/api/v1`

| Endpoint | Use case | Success message key |
| --- | --- | --- |
| `POST /chat` | Chatbot interaction | `AI_CHAT_COMPLETED` |
| `POST /search` | Natural-language product search | `AI_SEARCH_COMPLETED` or `AI_SEARCH_NO_RESULTS` |
| `POST /consult` | Product consultation | `AI_CONSULT_COMPLETED` |
| `POST /compare` | Product comparison | `AI_COMPARE_COMPLETED` or `AI_COMPARE_PARTIAL` |
| `POST /evaluate` | Product explanation | `AI_EVALUATION_COMPLETED` |

All responses have `{data, message, errors}`. Validation, unavailable-backend
and missing-product conditions use a static top-level key and put details in
`errors[]`.
