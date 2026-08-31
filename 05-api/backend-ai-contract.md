# Backend ↔ AI contract

The AI service calls the backend `/api/v1` catalog endpoints and returns the
same response envelope as the backend:

```json
{
  "data": {},
  "message": "AI_SEARCH_COMPLETED",
  "errors": []
}
```

`message` is always a static machine-readable key for frontend mapping. Any
human-readable or field-specific detail belongs in `errors[]`. The AI service
must not expose the backend's internal exception text in the top-level field.

The backend remains the source of truth for product, variant, price, stock and
order data. AI responses may summarize that data but must preserve product IDs
and the canonical `listPrice` fields when returning product cards.
