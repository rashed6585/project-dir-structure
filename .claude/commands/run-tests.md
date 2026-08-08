Run the full test suite with verbose output and short tracebacks.

```bash
# Backend
uv run pytest backend/tests/ -v --tb=short

# Frontend
cd frontend && npm test
```
