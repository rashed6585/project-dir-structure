# Coding Conventions

## Python Style
- Follow PEP 8; enforced by ruff (line length 120)
- Docstrings: omit by default. Add only a one-line docstring when the input/output or behavior isn't obvious from the signature — no Args/Returns/Raises sections. If a docstring is present, ruff enforces Google convention formatting on it (`pydocstyle` D-rules), so keep it to one line to stay compliant with minimal effort.
- Use type hints on all public functions
- Prefer `pathlib.Path` over `os.path` for file operations

## Project Patterns
- All data loading goes through `backend/src/data-pipeline/data_loader.py`
- Log using the project logger in `backend/src/utils/logger.py`, never `print()`
- Use `backend/src/utils/tracing.py` for distributed tracing instrumentation
- General file/text helpers live in `backend/src/utils/helpers.py`
- Feature engineering logic belongs in `backend/src/features/feature_engineering.py`
- API routes live in `backend/serving-api/`; one router file per resource
- Airflow DAGs go in `backend/src/data-pipeline/dags/`
- Spark jobs go in `backend/src/data-pipeline/spark-node/`
- Configuration is read from `backend/configs/`; never hard-code paths or credentials

## Frontend Patterns
- Node 20 required — run `nvm use` inside `frontend/` before installing or running scripts
- Components live in `frontend/src/components/`; one component per file
- Page-level components (route targets) live in `frontend/src/pages/`
- Custom hooks live in `frontend/src/hooks/`; prefix with `use`
- Style with Tailwind utility classes; avoid writing custom CSS unless unavoidable
- Global styles and Tailwind directives (`@tailwind base/components/utilities`) go in `frontend/src/styles/index.css`
- Never import `index.css` more than once — it is imported in `index.jsx` only

## Orchestrator Patterns
- All LLM calls go through `orchestrator/src/llm/client.py`
- Memory tier selection: Redis for session state, PostgreSQL for persistent records, vector DB for semantic retrieval
- All tools must be registered via the decorator in `orchestrator/src/tools/base.py`
- Prompt files live in `orchestrator/prompts/`; never embed long prompts inline in code

## Testing
- Backend test files mirror the `backend/src/` structure under `backend/tests/`
- Frontend tests live in `frontend/tests/`; use Vitest + React Testing Library
- Use `pytest` fixtures for backend; avoid global state between tests