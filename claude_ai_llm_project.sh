
#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-directory-name>"
  exit 1
fi

PROJECT_DIR=$1

# Initialize Git repository before populating the project directory
mkdir -p "$PROJECT_DIR"
(
  cd "$PROJECT_DIR" || exit 1
  git init
  git checkout -b dev-v1.0
)

# Create directories
mkdir -p "$PROJECT_DIR"/{docs,checkpoints,knowledge-base}
mkdir -p "$PROJECT_DIR"/tmp/input-prompts
mkdir -p "$PROJECT_DIR"/{backend,frontend,orchestrator}
mkdir -p "$PROJECT_DIR"/backend/{src,notebooks,tests,scripts,configs,logs,api,features}
mkdir -p "$PROJECT_DIR"/backend/src/{models,utils,evaluation}
mkdir -p "$PROJECT_DIR"/backend/src/data-pipeline/{sql,sqoop,dags,spark-node}
mkdir -p "$PROJECT_DIR"/backend/src/deployment/{kubernetes,inference}
mkdir -p "$PROJECT_DIR"/backend/data/{raw,processed,sample}
mkdir -p "$PROJECT_DIR"/.claude/{commands,agents,skills,rules,hooks}
mkdir -p "$PROJECT_DIR"/frontend/{public,tests,logs}
mkdir -p "$PROJECT_DIR"/frontend/src/{components,pages,hooks,utils,assets,styles}
mkdir -p "$PROJECT_DIR"/.github/workflows
mkdir -p "$PROJECT_DIR"/orchestrator/{config,logs,prompts/system,prompts/tasks,prompts/templates}
mkdir -p "$PROJECT_DIR"/orchestrator/src/{agents/specialists,workflows,guardrails,knowledge/documents,memory,tools,llm,utils}

# Create root-level files
touch "$PROJECT_DIR"/LICENSE
touch "$PROJECT_DIR"/backend/pyproject.toml

# create backend/.env.example — committed template; copy to backend/.env and fill in values
cat > "$PROJECT_DIR/backend/.env.example" << 'EOF'
# Backend environment variables — copy this file to .env and fill in real values.
# Load in Python via python-dotenv:
#
#   from dotenv import load_dotenv
#   load_dotenv()                  # reads backend/.env when running from backend/
#
# DO NOT commit .env — only commit .env.example with empty or placeholder values.

# ── SMTP ──────────────────────────────────────────────────────────────────────
SMPT_SERVER=smtp.example.com
SMPT_PORT=587
SMPT_SENDER=no-reply@example.com

# ── Database ──────────────────────────────────────────────────────────────────
ODBC_PER_USER_ENV=db_user
ODBC_PER_PASS_ENV=db_password

# ── PostgreSQL ────────────────────────────────────────────────────────────────
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=appdb
DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb

# ── AWS ───────────────────────────────────────────────────────────────────────
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_REGION=us-east-1

EOF

# Create README.md with dynamic folder name
cat <<EOL > "$PROJECT_DIR/README.md"
# AI LLM Project

This project contains the structure for an AI LLM pipeline including data handling, model training, evaluation, and deployment.

## Folder Structure

$PROJECT_DIR/
├── LICENSE
├── .gitignore
├── README.md
├── CLAUDE.md
├── docker-compose.yml
├── .github/
│   └── workflows/
│       ├── ci.yml                      # CI — lint & test on push / PR
│       └── cd.yml                      # CD — build & push on production branch
├── .claude/
│   ├── settings.json                   # Shared permissions and hooks (team-committed)
│   ├── settings.local.json             # Personal local overrides (gitignored)
│   ├── commands/                       # Custom slash commands
│   ├── agents/                         # Custom subagent definitions
│   ├── skills/                         # Reusable prompt skills
│   ├── rules/                          # Project coding conventions
│   └── hooks/                          # Shell scripts triggered by Claude Code hooks
├── knowledge-base/                     # Static domain knowledge and reference docs
├── orchestrator/                       # LLM orchestration layer
│   ├── .env.example
│   ├── .gitignore
│   ├── README.md
│   ├── pyproject.toml
│   ├── uv.lock
│   ├── Dockerfile
│   ├── logs/                           # Orchestrator log files (gitignored)
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py                 # App-wide settings and env validation (Pydantic)
│   ├── prompts/
│   │   ├── system/
│   │   │   └── SYSTEM.md               # Core agent persona, behavior identity, & ReAct rules
│   │   ├── tasks/
│   │   │   └── task_execution.xml      # Structural schemas, rules, & task-specific constraints
│   │   └── templates/
│   │       └── tool_calling.json       # Few-shot examples & reusable structural prompt templates
│   └── src/
│       ├── __init__.py
│       ├── main.py                     # Application entry point (FastAPI)
│       ├── agents/
│       │   ├── __init__.py
│       │   ├── base.py                 # Abstract Base Agent class
│       │   ├── orchestrator.py         # Central Router / Dynamic LLM Coordinator
│       │   └── specialists/
│       │       ├── __init__.py
│       │       └── data_analyst.py
│       ├── workflows/
│       │   ├── __init__.py
│       │   ├── base.py
│       │   └── sequential_flow.py
│       ├── guardrails/
│       │   ├── __init__.py
│       │   ├── input_moderation.py     # Prompt injection, jailbreak, and PII filtering
│       │   └── output_verifier.py      # JSON/XML syntax & hallucination checks
│       ├── knowledge/
│       │   ├── __init__.py
│       │   ├── store.py
│       │   └── documents/
│       ├── memory/
│       │   ├── __init__.py
│       │   ├── base.py
│       │   ├── short_term.py           # Ephemeral session history via Redis
│       │   ├── long_term.py            # Persistent relational state (PostgreSQL)
│       │   ├── vector_db.py            # Semantic storage (FAISS / pgvector)
│       │   ├── cache.py                # Key-value cache for LLM hits
│       │   └── embeddings.py           # Vectorization engine wrappers
│       ├── tools/
│       │   ├── __init__.py
│       │   ├── base.py                 # Tool registration decorator and schema parser
│       │   ├── web_search.py
│       │   ├── calculator.py
│       │   ├── file_reader.py
│       │   └── custom_tools.py
│       ├── llm/
│       │   ├── __init__.py
│       │   ├── client.py               # Single-point gateway for underlying models
│       │   └── token_counter.py        # Sliding context window analyzer & cost tracker
│       └── utils/
│           ├── __init__.py
│           ├── logger.py
│           ├── helpers.py
│           └── timers.py               # Execution benchmarking and latency tracking
├── backend/                            # Backend — Python / AI-LLM
│   ├── pyproject.toml                  # Python dependencies and tool config (uv)
│   ├── .env.example                    # Backend env var template (commit this)
│   ├── Dockerfile                      # python:3.11-alpine container
│   ├── .dockerignore
│   ├── api/                            # API layer (FastAPI routes)
│   ├── features/                       # Feature engineering
│   │   └── feature_engineering.py
│   ├── notebooks/
│   │   ├── data_exploration.ipynb
│   │   └── model_training.ipynb
│   ├── src/
│   │   ├── __init__.py
│   │   ├── data-pipeline/
│   │   │   ├── __init__.py
│   │   │   ├── data_loader.py
│   │   │   ├── data_preprocessor.py
│   │   │   ├── sql/                    # SQL scripts hive/exadata
│   │   │   ├── sqoop/                  # Sqoop import/export jobs
│   │   │   ├── dags/                   # Airflow DAG definitions
│   │   │   └── spark-node/             # Spark job configs and scripts
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   ├── base_model.py
│   │   │   └── fine_tune.py
│   │   ├── utils/
│   │   │   ├── __init__.py
│   │   │   ├── helpers.py              # File and general helper utilities
│   │   │   ├── logger.py
│   │   │   └── tracing.py             # Distributed tracing utilities
│   │   ├── evaluation/
│   │   │   ├── __init__.py
│   │   │   ├── metrics.py
│   │   │   └── evaluate.py
│   │   └── deployment/
│   │       ├── __init__.py
│   │       ├── kubernetes/             # K8s manifests and helpers
│   │       └── inference/              # Inference serving configs
│   ├── tests/
│   │   ├── test_data_loader.py
│   │   ├── test_fine_tune.py
│   │   └── test_metrics.py
│   ├── data/                           # Dataset storage (contents gitignored)
│   │   ├── raw/
│   │   ├── processed/
│   │   └── sample/
│   ├── scripts/
│   │   ├── train.py
│   │   └── predict.py
│   ├── configs/
│   │   ├── default_config.yaml
│   │   ├── dev_config.yaml
│   │   └── prod_config.yaml
│   └── logs/                           # Backend log files (gitignored)
├── frontend/                           # Frontend — Node 20 / React / Tailwind CSS
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── .nvmrc
│   ├── .env.example
│   ├── Dockerfile                      # node:20-alpine multi-stage container
│   ├── .dockerignore
│   ├── public/
│   │   ├── index.html
│   │   └── favicon.ico
│   ├── src/
│   │   ├── index.jsx
│   │   ├── App.jsx
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── utils/
│   │   ├── assets/
│   │   └── styles/
│   │       └── index.css
│   ├── tests/
│   │   └── App.test.jsx
│   └── logs/                           # Frontend log files (gitignored)
├── docs/
│   ├── index.md
│   └── api_reference.md
├── checkpoints/                        # Saved model checkpoints (gitignored)
└── tmp/                                # Temporary scratch files (gitignored)
    └── input-prompts/
EOL

# Create backend source code files
touch "$PROJECT_DIR"/backend/src/__init__.py \
      "$PROJECT_DIR"/backend/src/data-pipeline/{__init__.py,data_loader.py,data_preprocessor.py} \
      "$PROJECT_DIR"/backend/src/models/{__init__.py,base_model.py,fine_tune.py} \
      "$PROJECT_DIR"/backend/src/utils/{__init__.py,helpers.py,logger.py,tracing.py} \
      "$PROJECT_DIR"/backend/src/evaluation/{__init__.py,metrics.py,evaluate.py} \
      "$PROJECT_DIR"/backend/src/deployment/__init__.py \
      "$PROJECT_DIR"/backend/features/{__init__.py,feature_engineering.py} \
      "$PROJECT_DIR"/backend/api/__init__.py

# Create test files
touch "$PROJECT_DIR"/backend/tests/{test_data_loader.py,test_fine_tune.py,test_metrics.py}

# Create notebook files
touch "$PROJECT_DIR"/backend/notebooks/{data_exploration.ipynb,model_training.ipynb}

# Create script files
touch "$PROJECT_DIR"/backend/scripts/{train.py,predict.py}

# Create documentation files
touch "$PROJECT_DIR"/docs/{index.md,api_reference.md}

# Create config files
touch "$PROJECT_DIR"/backend/configs/{default_config.yaml,dev_config.yaml,prod_config.yaml}

# Create frontend files
touch "$PROJECT_DIR"/frontend/public/{index.html,favicon.ico}
touch "$PROJECT_DIR"/frontend/src/{index.jsx,App.jsx}
touch "$PROJECT_DIR"/frontend/src/styles/index.css
touch "$PROJECT_DIR"/frontend/tests/App.test.jsx
touch "$PROJECT_DIR"/frontend/{tailwind.config.js,postcss.config.js,vite.config.js,.nvmrc}

# create frontend/.env.example — committed template; copy to frontend/.env and fill in values
cat > "$PROJECT_DIR/frontend/.env.example" << 'EOF'
# Frontend environment variables — copy this file to .env and fill in real values.
# Vite exposes ONLY variables prefixed with VITE_ to the browser bundle.
# Variables without the VITE_ prefix are available server-side (SSR / scripts) only.
#
# DO NOT commit .env — only commit .env.example with empty or placeholder values.

# ── API ───────────────────────────────────────────────────────────────────────
# Base URL of the backend API (no trailing slash)
VITE_API_BASE_URL=http://localhost:8000

# ── App ───────────────────────────────────────────────────────────────────────
VITE_APP_TITLE=AI LLM Project
VITE_APP_ENV=development
EOF

# .gitkeep for empty folders so Git tracks them
touch "$PROJECT_DIR/checkpoints/.gitkeep"
touch "$PROJECT_DIR/backend/data/processed/.gitkeep"
touch "$PROJECT_DIR/backend/data/raw/.gitkeep"
touch "$PROJECT_DIR/backend/data/sample/.gitkeep"
touch "$PROJECT_DIR/backend/logs/.gitkeep"
touch "$PROJECT_DIR/backend/src/deployment/kubernetes/.gitkeep"
touch "$PROJECT_DIR/backend/src/deployment/inference/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/dags/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/spark-node/.gitkeep"
touch "$PROJECT_DIR/backend/api/.gitkeep"
touch "$PROJECT_DIR/frontend/logs/.gitkeep"
touch "$PROJECT_DIR/tmp/.gitkeep"
touch "$PROJECT_DIR/tmp/input-prompts/.gitkeep"
touch "$PROJECT_DIR/knowledge-base/.gitkeep"
touch "$PROJECT_DIR/orchestrator/logs/.gitkeep"

# create .gitignore
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# ── Python ───────────────────────────────────────────────────────────────────
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
*.pyc
*.pyo

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
# .python-version

# pipenv
#Pipfile.lock

# UV
#uv.lock

# poetry
#poetry.lock

# pdm
#pdm.lock
.pdm.toml
.pdm-python
.pdm-build/

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# Ignore compiled Python bytecode files
*.pyc

# Ignore editor-specific files
.vscode/
*.sublime-*

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# PyCharm
#.idea/

# Ruff stuff:
.ruff_cache/

# PyPI configuration file
.pypirc

# ── Project folders ──────────────────────────────────────────────────────────
# Log files
/backend/logs/*
!/backend/logs/.gitkeep
/frontend/logs/*
!/frontend/logs/.gitkeep
/orchestrator/logs/*
!/orchestrator/logs/.gitkeep

# Temporary scratch files
/tmp/*
!/tmp/.gitkeep
!/tmp/input-prompts/

# DB folder
*/db/*

# Model checkpoints
/checkpoints/*
!/checkpoints/.gitkeep

# ── Data files — track directory structure only, not actual data ─────────────
/backend/data/raw/*
!/backend/data/raw/.gitkeep
/backend/data/processed/*
!/backend/data/processed/.gitkeep
/backend/data/sample/*
!/backend/data/sample/.gitkeep

# ── Frontend (Node.js / React) ───────────────────────────────────────────────
# Installed packages — never commit, restore with: npm install / yarn
frontend/node_modules/

# Production build output
frontend/build/
frontend/dist/
frontend/.vite/

# Environment files — contain secrets, each dev has their own
frontend/.env
frontend/.env.local
frontend/.env.*.local

# Test coverage reports
frontend/coverage/

# Misc tooling artefacts
frontend/.DS_Store
frontend/npm-debug.log*
frontend/yarn-debug.log*
frontend/yarn-error.log*
frontend/.pnp/
frontend/.pnp.js

# ── Claude Code ───────────────────────────────────────────────────────────────
# Claude Code local overrides (personal settings, not team-shared)
.claude/settings.local.json
EOF

# create backend/pyproject.toml
cat > "$PROJECT_DIR/backend/pyproject.toml" << 'EOF'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "project-name"
version = "0.1.0"
description = "A project for training and evaluating LLMs"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "boto3>=1.24.0",
    "pandas>=2.1.3",
    "numpy>=1.21.0",
    "matplotlib>=3.5.0",
    "seaborn>=0.11.0",
    "joblib>=1.1.0",
    "fastapi>=0.111.0",
    "uvicorn[standard]>=0.29.0",
    "python-dotenv>=1.0.0",
    "psycopg2-binary>=2.9.0",
]

[project.scripts]
train-model = "scripts.train:main"
predict-model = "scripts.predict:main"

[dependency-groups]
dev = [
    "pytest>=7.0.0",
    "ruff>=0.12.9",
]

[tool.uv]
package = true

[tool.ruff]
line-length = 100
target-version = "py312"
fix = true
exclude = [
    ".git",
    ".venv",
    "__pycache__",
    "build",
    "dist",
    "*.egg-info",
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "lf"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # Pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "D",   # pydocstyle
    "UP",  # pyupgrade
    "YTT", # flake8-2020
    "S",   # bandit
    "T20", # flake8-print
    "RUF", # Ruff-specific rules
]
ignore = [
    "D100",  # Missing docstring in public module
    "D101",  # Missing docstring in public class
    "D102",  # Missing docstring in public method
    "D103",  # Missing docstring in public function
    "D104",  # Missing docstring in public package
    "D107",  # Missing docstring in __init__
    "I001",  # Import block is un-sorted or un-formatted
    "S101",  # Use of assert
    "UP032", # Use f-string instead of `format` call
]

[tool.ruff.lint.isort]
known-first-party = ["src"]
section-order = ["future", "standard-library", "third-party", "first-party", "local-folder"]

[tool.ruff.lint.pydocstyle]
convention = "google"
EOF

# create backend/Dockerfile
cat > "$PROJECT_DIR/backend/Dockerfile" << 'EOF'
FROM python:3.11-alpine

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libffi-dev postgresql-dev

RUN pip install uv

COPY pyproject.toml .

RUN uv sync --no-dev

COPY src/ ./src/
COPY configs/ ./configs/
COPY scripts/ ./scripts/

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# create backend/.dockerignore
cat > "$PROJECT_DIR/backend/.dockerignore" << 'EOF'
__pycache__/
*.pyc
*.pyo
.venv/
.env
data/
logs/
.pytest_cache/
.ruff_cache/
*.egg-info/
notebooks/
tests/
EOF

# create frontend/Dockerfile
cat > "$PROJECT_DIR/frontend/Dockerfile" << 'EOF'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
EOF

# create frontend/.dockerignore
cat > "$PROJECT_DIR/frontend/.dockerignore" << 'EOF'
node_modules/
dist/
build/
.env
.env.local
.env.*.local
coverage/
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnp/
.pnp.js
tests/
EOF

# create docker-compose.yml
cat > "$PROJECT_DIR/docker-compose.yml" << 'EOF'
version: '3.9'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: backend
    env_file:
      - ./backend/.env
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-network
    volumes:
      - ./backend/data:/app/data
      - ./backend/logs:/app/logs

  orchestrator:
    build:
      context: ./orchestrator
      dockerfile: Dockerfile
    container_name: orchestrator
    env_file:
      - ./orchestrator/.env
    environment:
      REDIS_URL: redis://redis:6379
      DATABASE_URL: postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@db:5432/orchestrator
    ports:
      - "8001:8001"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    volumes:
      - ./orchestrator/logs:/app/logs

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
      - orchestrator
    networks:
      - app-network

  db:
    image: postgres:16-alpine
    container_name: postgres_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      POSTGRES_DB: ${POSTGRES_DB:-appdb}
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    volumes:
      - redis_data:/data

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
EOF

# create .github/workflows/ci.yml
cat > "$PROJECT_DIR/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [dev-v1.0]
  pull_request:
    branches: [dev-v1.0]

jobs:
  backend-lint-test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install uv
        run: pip install uv
      - name: Install dependencies
        run: uv sync
      - name: Lint
        run: uv run ruff check .
      - name: Test
        run: uv run pytest tests/ -v --tb=short

  frontend-lint-test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint
      - name: Test
        run: npm test
EOF

# create .github/workflows/cd.yml
cat > "$PROJECT_DIR/.github/workflows/cd.yml" << 'EOF'
name: CD

on:
  push:
    branches: [production-v1.0]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Log in to container registry
        uses: docker/login-action@v3
        with:
          registry: ${{ secrets.REGISTRY_URL }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
      - name: Build and push backend
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ secrets.REGISTRY_URL }}/backend:${{ github.sha }}
      - name: Build and push frontend
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ secrets.REGISTRY_URL }}/frontend:${{ github.sha }}
EOF

# create frontend/package.json
cat > "$PROJECT_DIR/frontend/package.json" << 'EOF'
{
  "name": "frontend",
  "version": "0.1.0",
  "private": true,
  "engines": {
    "node": ">=20.0.0"
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^6.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.0.0",
    "eslint-plugin-react": "^7.0.0",
    "eslint-plugin-react-hooks": "^4.0.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@testing-library/user-event": "^14.0.0",
    "vitest": "^1.0.0",
    "@vitest/coverage-v8": "^1.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "coverage": "vitest run --coverage",
    "lint": "eslint src/"
  }
}
EOF

# create frontend/vite.config.js
cat > "$PROJECT_DIR/frontend/vite.config.js" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './tests/setup.js',
  },
})
EOF

# create frontend/tailwind.config.js
cat > "$PROJECT_DIR/frontend/tailwind.config.js" << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# create frontend/postcss.config.js
cat > "$PROJECT_DIR/frontend/postcss.config.js" << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# create frontend/.nvmrc — pins Node version for nvm users
cat > "$PROJECT_DIR/frontend/.nvmrc" << 'EOF'
20
EOF

# create .claude/settings.json
cat > "$PROJECT_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(uv sync)",
      "Bash(uv run pytest*)",
      "Bash(uv run ruff*)",
      "Bash(uv add*)",
      "Bash(uv remove*)",
      "Bash(python -m pytest*)",
      "Bash(npm install*)",
      "Bash(npm run*)",
      "Bash(npx *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/PostToolUse.sh"
          }
        ]
      }
    ]
  }
}
EOF

# create .claude/settings.local.json
cat > "$PROJECT_DIR/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(code *)"
    ]
  },
  "env": {
    "CLAUDE_USER": "your-name"
  }
}
EOF

# create .claude/hooks/PostToolUse.sh
cat > "$PROJECT_DIR/.claude/hooks/PostToolUse.sh" << 'EOF'
#!/usr/bin/env bash
# PostToolUse hook — runs after every Bash tool call.
# Claude Code passes tool metadata via stdin as JSON; parse with jq if needed.

TOOL_NAME="${CLAUDE_TOOL_NAME:-Bash}"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "[hook] $TOOL_NAME completed at $TIMESTAMP" >&2

# Example: append a log entry to backend/logs/claude_tool.log
LOG_FILE="backend/logs/claude_tool.log"
if [ -d "backend/logs" ]; then
  echo "$TIMESTAMP  tool=$TOOL_NAME  exit=$?" >> "$LOG_FILE"
fi
EOF
chmod +x "$PROJECT_DIR/.claude/hooks/PostToolUse.sh"

# create .claude/rules/coding-conventions.md
cat > "$PROJECT_DIR/.claude/rules/coding-conventions.md" << 'EOF'
# Coding Conventions

## Python Style
- Follow PEP 8; enforced by ruff (line length 100, Google docstring style)
- Use type hints on all public functions
- Prefer `pathlib.Path` over `os.path` for file operations

## Project Patterns
- All data loading goes through `backend/src/data-pipeline/data_loader.py`
- Log using the project logger in `backend/src/utils/logger.py`, never `print()`
- Use `backend/src/utils/tracing.py` for distributed tracing instrumentation
- General file/text helpers live in `backend/src/utils/helpers.py`
- Feature engineering logic belongs in `backend/features/feature_engineering.py`
- API routes live in `backend/api/`; one router file per resource
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
EOF

# create .claude/skills/analyze-data.md
cat > "$PROJECT_DIR/.claude/skills/analyze-data.md" << 'EOF'
---
name: analyze-data
description: Load a dataset from backend/data/processed/, print shape and dtypes, generate descriptive statistics, and flag columns with >10% missing values.
---

Load the dataset at the path the user provides (default: backend/data/processed/).
Using pandas:
1. Print `df.shape`, `df.dtypes`, and `df.describe()`
2. List columns where null % > 10 and suggest a fill strategy
3. Suggest one matplotlib/seaborn chart that best illustrates the distribution

Keep output concise; show code the user can paste into a notebook.
EOF

# create .claude/commands/run-tests.md
cat > "$PROJECT_DIR/.claude/commands/run-tests.md" << 'EOF'
Run the full test suite with verbose output and short tracebacks.

```bash
# Backend
uv run pytest backend/tests/ -v --tb=short

# Frontend
cd frontend && npm test
```
EOF

# create .claude/agents/data-analyst.md
cat > "$PROJECT_DIR/.claude/agents/data-analyst.md" << 'EOF'
---
name: data-analyst
description: Use this agent to explore datasets, compute statistics, and produce visualisation code. Works with files in backend/data/raw/ and backend/data/processed/.
---

You are a data analysis specialist for this LLM project.
When analysing data:
1. Load from `backend/data/processed/` (prefer) or `backend/data/raw/`
2. Use pandas for statistics and seaborn/matplotlib for charts
3. Flag data quality issues (nulls, duplicates, outliers)
4. Return runnable code snippets the user can paste into `backend/notebooks/`

Tools available: Bash, Read. Do not write files unless asked.
EOF

# ── Orchestrator files ────────────────────────────────────────────────────────

touch "$PROJECT_DIR/orchestrator/uv.lock"

cat > "$PROJECT_DIR/orchestrator/.gitignore" << 'EOF'
__pycache__/
*.pyc
*.pyo
.venv/
.env
.pytest_cache/
.ruff_cache/
*.egg-info/
EOF

cat > "$PROJECT_DIR/orchestrator/.env.example" << 'EOF'
# Orchestrator environment variables — copy to .env and fill in real values.
# DO NOT commit .env — only commit .env.example with empty or placeholder values.

# ── LLM ───────────────────────────────────────────────────────────────────────
ANTHROPIC_API_KEY=your-anthropic-api-key
LLM_MODEL=claude-opus-4-5
LLM_MAX_TOKENS=4096

# ── Redis (Short-term memory) ──────────────────────────────────────────────────
REDIS_URL=redis://localhost:6379

# ── Database (Long-term memory) ───────────────────────────────────────────────
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/orchestrator

# ── Vector DB ─────────────────────────────────────────────────────────────────
VECTOR_DB_PATH=./src/knowledge/documents

# ── Web Search ────────────────────────────────────────────────────────────────
TAVILY_API_KEY=your-tavily-api-key

# ── App ───────────────────────────────────────────────────────────────────────
APP_ENV=development
LOG_LEVEL=INFO
EOF

cat > "$PROJECT_DIR/orchestrator/README.md" << 'EOF'
# Orchestrator

Multi-agent LLM orchestration layer. Coordinates specialist agents, manages memory tiers, and enforces guardrails.

## Quick Start

```bash
cd orchestrator
uv sync
cp .env.example .env   # fill in real values
uv run uvicorn src.main:app --reload
```

## Structure

- `config/` — App-wide settings via Pydantic
- `prompts/` — System prompts, task schemas, and few-shot templates
- `src/agents/` — Orchestrator router and specialist agent logic
- `src/memory/` — Short-term (Redis), long-term (PostgreSQL), and vector (FAISS/pgvector) state
- `src/tools/` — Capability sandbox (web search, calculator, file reader)
- `src/guardrails/` — Input/output validation and safety filtering
- `src/llm/` — Framework-agnostic LLM client and token counter
EOF

cat > "$PROJECT_DIR/orchestrator/pyproject.toml" << 'EOF'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "orchestrator"
version = "0.1.0"
description = "LLM Orchestrator — multi-agent coordination layer"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.111.0",
    "uvicorn[standard]>=0.29.0",
    "anthropic>=0.28.0",
    "pydantic>=2.7.0",
    "pydantic-settings>=2.3.0",
    "redis>=5.0.0",
    "faiss-cpu>=1.8.0",
    "python-dotenv>=1.0.0",
    "httpx>=0.27.0",
    "psycopg2-binary>=2.9.0",
    "sqlalchemy>=2.0.0",
]

[dependency-groups]
dev = [
    "pytest>=7.0.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.12.9",
]

[tool.uv]
package = true

[tool.ruff]
line-length = 100
target-version = "py312"
fix = true

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP", "S", "RUF"]
ignore = ["S101", "UP032", "D100", "D101", "D102", "D103", "D104", "D107"]
EOF

cat > "$PROJECT_DIR/orchestrator/Dockerfile" << 'EOF'
FROM python:3.12-alpine

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libffi-dev postgresql-dev

RUN pip install uv

COPY pyproject.toml .

RUN uv sync --no-dev

COPY src/ ./src/
COPY config/ ./config/
COPY prompts/ ./prompts/

EXPOSE 8001

CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8001"]
EOF

# orchestrator/config
touch "$PROJECT_DIR/orchestrator/config/__init__.py"

cat > "$PROJECT_DIR/orchestrator/config/settings.py" << 'EOF'
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    anthropic_api_key: str = ""
    llm_model: str = "claude-opus-4-5"
    llm_max_tokens: int = 4096

    redis_url: str = "redis://localhost:6379"
    database_url: str = ""
    vector_db_path: str = "./src/knowledge/documents"

    tavily_api_key: str = ""

    app_env: str = "development"
    log_level: str = "INFO"


settings = Settings()
EOF

# orchestrator/prompts
cat > "$PROJECT_DIR/orchestrator/prompts/system/SYSTEM.md" << 'EOF'
# System Prompt — Core Agent Persona

## Identity
You are an intelligent orchestrator agent. Your role is to decompose complex tasks, coordinate specialist agents, and synthesize results into coherent responses.

## Behavior
- Follow the ReAct pattern: Reason → Act → Observe → Repeat
- Delegate domain-specific tasks to the appropriate specialist agent
- Validate all outputs through guardrails before returning to the user
- Never expose internal tool calls or intermediate reasoning to the user

## Constraints
- Do not hallucinate facts; use tools to retrieve real data
- Respect token budgets; summarize when context grows large
- Always cite sources when returning retrieved information
EOF

cat > "$PROJECT_DIR/orchestrator/prompts/tasks/task_execution.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<task_schema>
  <version>1.0</version>
  <rules>
    <rule id="TR-01">Break every task into atomic steps before execution.</rule>
    <rule id="TR-02">Each step must have a single, verifiable success criterion.</rule>
    <rule id="TR-03">On failure, retry once with adjusted parameters before escalating.</rule>
    <rule id="TR-04">Log start time, end time, and exit status for every step.</rule>
  </rules>
  <output_format>
    <field name="task_id"  type="string" required="true"/>
    <field name="status"   type="enum"   values="pending,running,completed,failed"/>
    <field name="steps"    type="array"  item_type="step"/>
    <field name="result"   type="string" required="false"/>
  </output_format>
</task_schema>
EOF

cat > "$PROJECT_DIR/orchestrator/prompts/templates/tool_calling.json" << 'EOF'
{
  "version": "1.0",
  "few_shot_examples": [
    {
      "user": "What is the current weather in London?",
      "tool_call": {
        "name": "web_search",
        "input": { "query": "current weather London UK" }
      },
      "tool_result": "Partly cloudy, 18°C.",
      "assistant": "The current weather in London is partly cloudy with a temperature of 18°C."
    }
  ],
  "tool_templates": {
    "web_search": {
      "name": "web_search",
      "description": "Search the internet for up-to-date information.",
      "input_schema": {
        "type": "object",
        "properties": {
          "query": { "type": "string", "description": "The search query." }
        },
        "required": ["query"]
      }
    }
  }
}
EOF

# orchestrator/src
touch "$PROJECT_DIR/orchestrator/src/__init__.py"

cat > "$PROJECT_DIR/orchestrator/src/main.py" << 'EOF'
from fastapi import FastAPI

app = FastAPI(title="Orchestrator", version="0.1.0")


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
EOF

# orchestrator agents, workflows, guardrails, knowledge, memory, tools, llm, utils
touch "$PROJECT_DIR"/orchestrator/src/agents/{__init__.py,base.py,orchestrator.py}
touch "$PROJECT_DIR"/orchestrator/src/agents/specialists/{__init__.py,data_analyst.py}
touch "$PROJECT_DIR"/orchestrator/src/workflows/{__init__.py,base.py,sequential_flow.py}
touch "$PROJECT_DIR"/orchestrator/src/guardrails/{__init__.py,input_moderation.py,output_verifier.py}
touch "$PROJECT_DIR"/orchestrator/src/knowledge/{__init__.py,store.py}
touch "$PROJECT_DIR"/orchestrator/src/memory/{__init__.py,base.py,short_term.py,long_term.py,vector_db.py,cache.py,embeddings.py}
touch "$PROJECT_DIR"/orchestrator/src/tools/{__init__.py,base.py,web_search.py,calculator.py,file_reader.py,custom_tools.py}
touch "$PROJECT_DIR"/orchestrator/src/llm/{__init__.py,client.py,token_counter.py}
touch "$PROJECT_DIR"/orchestrator/src/utils/{__init__.py,logger.py,helpers.py,timers.py}

# create CLAUDE.md
cat > "$PROJECT_DIR/CLAUDE.md" << 'EOF'
# Project Context

## Overview
<!-- Describe what this project does and its purpose -->

## Backend — Package Management
This project uses [uv](https://docs.astral.sh/uv/) for Python dependency management.

```bash
cd backend
uv sync                     # Install all dependencies (including dev)
uv add <package>            # Add a runtime dependency
uv add --dev <package>      # Add a dev dependency
uv run pytest               # Run tests
uv run ruff check .         # Lint
uv run ruff format .        # Format
```

## Frontend — Package Management
This project uses **Node 20**, [Vite](https://vitejs.dev/), React, and [Tailwind CSS](https://tailwindcss.com/).
Use `nvm` to switch to the correct Node version before working on the frontend.

```bash
cd frontend
nvm use                     # Switch to Node 20 (reads .nvmrc)
npm install                 # Install all dependencies
npm run dev                 # Start Vite dev server (http://localhost:5173)
npm run build               # Production build → dist/
npm test                    # Run Vitest tests
npm run coverage            # Test coverage report
npm run lint                # ESLint
```

## Orchestrator — Package Management
The orchestrator uses [uv](https://docs.astral.sh/uv/) and exposes a FastAPI app on port 8001.

```bash
cd orchestrator
uv sync
cp .env.example .env        # fill in API keys and DB URIs
uv run uvicorn src.main:app --reload
```

## Docker
```bash
docker compose up --build              # Start all services (backend, orchestrator, frontend, PostgreSQL, Redis)
docker compose up --build orchestrator # Rebuild and start orchestrator only
docker compose down -v                 # Stop all services and remove volumes
```

## Project Structure
- `backend/src/` — Python source code (data-pipeline, models, utils, evaluation, deployment)
- `backend/api/` — FastAPI route handlers
- `backend/features/` — Feature engineering modules
- `backend/notebooks/` — Jupyter notebooks for exploration
- `backend/src/data-pipeline/dags/` — Airflow DAG definitions
- `backend/src/data-pipeline/spark-node/` — Spark job configs and scripts
- `backend/src/deployment/` — Kubernetes manifests and inference serving configs
- `backend/configs/` — Shared YAML configuration files (default, dev, prod)
- `backend/data/raw/` — Raw input datasets (not committed)
- `backend/data/processed/` — Processed datasets (not committed)
- `backend/data/sample/` — Sample/seed datasets (not committed)
- `frontend/src/` — React source (components, pages, hooks, utils, assets, styles)
- `frontend/src/styles/index.css` — Tailwind CSS directives and global styles
- `orchestrator/src/` — Multi-agent orchestration layer
- `orchestrator/prompts/` — System prompts, task schemas, and few-shot templates
- `knowledge-base/` — Static domain knowledge and reference documents
- `backend/tests/` — Backend unit tests (pytest)
- `backend/scripts/` — Standalone train/predict scripts
- `frontend/logs/` — Frontend log files (not committed)
- `checkpoints/` — Saved model checkpoints (not committed)
- `tmp/` — Temporary scratch files (not committed)
- `tmp/input-prompts/` — Temporary prompt drafts and experiments

## Key Files
- `docker-compose.yml` — Orchestrates backend, frontend, and PostgreSQL services
- `backend/pyproject.toml` — Python dependencies and tool configuration
- `backend/configs/default_config.yaml` — Default runtime configuration
- `backend/configs/prod_config.yaml` — Production overrides
- `frontend/package.json` — Node.js dependencies and scripts (requires Node 20)
- `frontend/vite.config.js` — Vite bundler + Vitest configuration
- `orchestrator/pyproject.toml` — Orchestrator dependencies
- `orchestrator/config/settings.py` — Pydantic settings with env validation
- `.github/workflows/ci.yml` — CI pipeline (lint + test on push/PR)
- `.github/workflows/cd.yml` — CD pipeline (build + push on production-v1.0)
EOF

# Commit initial project structure on dev-v1.0
cd "$PROJECT_DIR"
git add .
git commit -m "initial commit: project structure."

# Create empty orphan production-v1.0 branch
git checkout --orphan production-v1.0
git rm -rf --cached .
git clean -fd
git commit --allow-empty -m "initial: empty production-v1.0 branch"

# Return to development branch
git checkout dev-v1.0
