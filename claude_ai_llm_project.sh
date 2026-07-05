
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
mkdir -p "$PROJECT_DIR"/backend/{src,notebooks,tests,scripts,configs,serving-api}
mkdir -p "$PROJECT_DIR"/logs/{backend,frontend,orchestrator}
mkdir -p "$PROJECT_DIR"/backend/src/{models,utils,evaluation,features}
mkdir -p "$PROJECT_DIR"/backend/src/data-pipeline/{sql,sqoop,dags,spark-node}
mkdir -p "$PROJECT_DIR"/backend/src/deployment/{kubernetes,inference}
mkdir -p "$PROJECT_DIR"/backend/data/{raw,processed,sample}
mkdir -p "$PROJECT_DIR"/.claude/{commands,agents,skills,rules,hooks}
mkdir -p "$PROJECT_DIR"/frontend/{public,tests}
mkdir -p "$PROJECT_DIR"/frontend/src/{components,pages,hooks,utils,assets,styles}
mkdir -p "$PROJECT_DIR"/.github/workflows
mkdir -p "$PROJECT_DIR"/orchestrator/{config,prompts/system,prompts/tasks,prompts/templates}
mkdir -p "$PROJECT_DIR"/orchestrator/src/{agents/specialists,workflows,guardrails,knowledge/documents,memory,tools,llm,utils}
mkdir -p "$PROJECT_DIR"/shared/{models,interfaces}
mkdir -p "$PROJECT_DIR"/tests/integration

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

\`\`\`
$PROJECT_DIR/
├── LICENSE                             # Open-source license file
├── .gitignore                          # Root gitignore covering all sub-projects (Global, Backend, Frontend, Orchestrator)
├── README.md                           # Project overview, folder guide, and quick-start instructions
├── CLAUDE.md                           # Claude Code project context, conventions, and package management commands
├── docker-compose.yml                  # Unified multi-service orchestration (backend, orchestrator, frontend, PostgreSQL+pgvector, Redis)
├── justfile                            # Root task runner: seed DB, clear logs, lint/test across all services simultaneously
├── .github/
│   └── workflows/
│       ├── ci.yml                      # CI — lint & test on push / PR (backend, orchestrator, frontend)
│       └── cd.yml                      # CD — build & push Docker images on production branch
├── .claude/
│   ├── settings.json                   # Shared Claude Code permissions and hooks (team-committed)
│   ├── settings.local.json             # Personal local overrides — not committed (gitignored)
│   ├── commands/                       # Custom slash commands available inside Claude Code sessions
│   │   └── run-tests.md                # /run-tests — executes full backend + frontend test suites
│   ├── agents/                         # Custom subagent definitions for specialized AI tasks
│   │   └── data-analyst.md             # Subagent: dataset exploration, statistics, and chart generation
│   ├── skills/                         # Reusable prompt skills invokable across sessions
│   │   └── analyze-data.md             # Skill: load, describe, and flag quality issues in a dataset
│   ├── rules/                          # Project-specific coding conventions Claude Code will follow
│   │   └── coding-conventions.md       # Style guide covering Python, React, and Orchestrator patterns
│   └── hooks/                          # Shell scripts triggered by Claude Code lifecycle events
│       ├── PostToolUse.sh              # Logs every Bash tool call with timestamp to logs/backend/
│       └── ruff-format.sh              # Auto-formats .py files with ruff after every Write/Edit/MultiEdit
├── shared/                             # Cross-stack communication contracts — single source of truth for API shapes
│   ├── models/                         # Pydantic schemas shared between backend and orchestrator (FastAPI request/response bodies)
│   │   └── __init__.py
│   └── interfaces/                     # TypeScript interfaces shared with the frontend (mirrors Pydantic models)
│       └── index.ts
├── knowledge-base/                     # Static domain knowledge and reference documents used for RAG ingestion
├── tests/
│   └── integration/                    # E2E tests — spin up full docker-compose stack and verify cross-service flows
│       ├── __init__.py
│       └── test_e2e_flow.py            # Verifies Frontend -> Orchestrator -> Backend health and request routing
├── orchestrator/                       # LLM orchestration layer — multi-agent coordination, memory, and guardrails
│   ├── .env.example                    # Orchestrator env var template — commit this, copy to .env with real values
│   ├── README.md                       # Orchestrator quick-start, architecture overview, and module guide
│   ├── pyproject.toml                  # Python dependencies: FastAPI, anthropic, redis, faiss-cpu, psycopg2
│   ├── uv.lock                         # Locked dependency versions — always commit for reproducible installs
│   ├── Dockerfile                      # python:3.12-alpine container for the orchestrator service
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py                 # App-wide settings loaded from environment — Pydantic BaseSettings with validation
│   ├── prompts/
│   │   ├── system/
│   │   │   └── SYSTEM.md               # Core agent persona, behavioral identity, and ReAct reasoning rules
│   │   ├── tasks/
│   │   │   └── task_execution.xml      # Task structural schemas, execution rules, and step-level constraints
│   │   └── templates/
│   │       └── tool_calling.json       # Few-shot examples and reusable JSON templates for tool invocations
│   └── src/
│       ├── __init__.py
│       ├── main.py                     # FastAPI application entry point — registers routes and starts the ASGI server
│       ├── agents/
│       │   ├── __init__.py
│       │   ├── base.py                 # Abstract BaseAgent — defines the interface all agents must implement
│       │   ├── orchestrator.py         # Central Router — dynamic LLM coordinator that delegates to specialists
│       │   ├── registry.py             # Specialist registry — dynamically imports agents so __init__.py stays clean
│       │   └── specialists/
│       │       ├── __init__.py
│       │       └── data_analyst.py     # Specialist agent: data exploration, statistics, and analytical reasoning
│       ├── workflows/
│       │   ├── __init__.py
│       │   ├── base.py                 # Base workflow class defining the step execution contract
│       │   └── sequential_flow.py      # Sequential step-by-step task execution workflow
│       ├── guardrails/
│       │   ├── __init__.py
│       │   ├── input_moderation.py     # Filters prompt injection, jailbreaks, and PII from user input
│       │   └── output_verifier.py      # Validates JSON/XML structure and flags potential hallucinations
│       ├── knowledge/
│       │   ├── __init__.py
│       │   ├── store.py                # Knowledge retrieval interface — wraps vector_db for RAG queries
│       │   └── documents/              # Ingested source documents and FAISS index files (Docker volume mount)
│       ├── memory/
│       │   ├── __init__.py
│       │   ├── base.py                 # Abstract Memory interface — all memory backends implement this contract
│       │   ├── short_term.py           # Ephemeral session history via Redis — TTL-scoped per conversation
│       │   ├── long_term.py            # Persistent relational state via PostgreSQL — survives container restarts
│       │   ├── vector_db.py            # Semantic storage via FAISS (disk-persisted via volume) or pgvector
│       │   ├── cache.py                # Key-value cache for LLM response deduplication (Redis-backed)
│       │   └── embeddings.py           # Vectorization engine wrappers — converts text to embedding vectors
│       ├── tools/
│       │   ├── __init__.py
│       │   ├── base.py                 # Tool registration decorator and JSON schema auto-parser
│       │   ├── web_search.py           # Web search capability via Tavily API
│       │   ├── calculator.py           # Safe arithmetic expression evaluator
│       │   ├── file_reader.py          # Reads documents from the knowledge-base/ directory
│       │   └── custom_tools.py         # Project-specific tool implementations
│       ├── llm/
│       │   ├── __init__.py
│       │   ├── client.py               # Single-point LLM gateway — abstracts underlying model providers (Anthropic)
│       │   └── token_counter.py        # Sliding context window analyzer and per-call cost tracker
│       └── utils/
│           ├── __init__.py
│           ├── logger.py               # get_logger() — file + stdout handler writing to logs/orchestrator/YYYYMMDD/
│           ├── helpers.py              # General-purpose utility functions
│           └── timers.py               # Execution benchmarking and request latency tracking
├── backend/                            # Backend — Python / AI-LLM pipeline and data processing
│   ├── pyproject.toml                  # Python dependencies and tool configuration managed with uv
│   ├── .env.example                    # Backend env var template — commit this, copy to .env with real values
│   ├── Dockerfile                      # python:3.11-alpine container for the backend service
│   ├── .dockerignore                   # Excludes .venv, data/, notebooks/ and large artifacts from Docker build
│   ├── serving-api/                    # FastAPI route handlers — one router file per resource domain
│   │   └── __init__.py
│   ├── notebooks/
│   │   ├── data_exploration.ipynb      # Interactive EDA — profiling, distributions, and correlations
│   │   └── model_training.ipynb        # Model training experiments — hyperparameter search and evaluation
│   ├── src/
│   │   ├── __init__.py
│   │   ├── features/                   # Feature engineering modules — transformation and selection logic
│   │   │   ├── __init__.py
│   │   │   └── feature_engineering.py  # Core feature pipeline: encoding, scaling, and derived feature creation
│   │   ├── data-pipeline/              # Ingestion, transformation, and orchestration layer
│   │   │   ├── __init__.py
│   │   │   ├── data_loader.py          # All data loading goes through here — single entry point for raw sources
│   │   │   ├── data_preprocessor.py    # Cleaning, normalisation, type casting, and train/val/test splitting
│   │   │   ├── sql/                    # SQL scripts for Hive / Exadata query execution
│   │   │   ├── sqoop/                  # Sqoop import/export job definitions for HDFS ingestion
│   │   │   ├── dags/                   # Airflow DAG definitions for pipeline scheduling and orchestration
│   │   │   └── spark-node/             # Spark job configurations and PySpark transformation scripts
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   ├── base_model.py           # Shared model base class, registry, and serialization helpers
│   │   │   └── fine_tune.py            # Fine-tuning training loop, checkpoint saving, and early stopping
│   │   ├── utils/
│   │   │   ├── __init__.py
│   │   │   ├── helpers.py              # File I/O and general-purpose helper utilities
│   │   │   ├── logger.py               # get_logger() — file + stdout handler writing to logs/backend/YYYYMMDD/
│   │   │   └── tracing.py              # Distributed tracing instrumentation (OpenTelemetry compatible)
│   │   ├── evaluation/
│   │   │   ├── __init__.py
│   │   │   ├── metrics.py              # Evaluation metric definitions: BLEU, ROUGE, F1, perplexity, etc.
│   │   │   └── evaluate.py             # Evaluation harness — runs metrics over model outputs and reports results
│   │   └── deployment/
│   │       ├── __init__.py
│   │       ├── kubernetes/             # Kubernetes manifests: Deployments, Services, ConfigMaps, HPA
│   │       └── inference/              # Inference serving configs for Triton / TorchServe
│   ├── tests/
│   │   ├── test_data_loader.py         # Unit tests for data ingestion and loader contract
│   │   ├── test_fine_tune.py           # Unit tests for fine-tuning loop and checkpoint logic
│   │   └── test_metrics.py             # Unit tests for evaluation metric correctness
│   ├── data/                           # Dataset storage — directory structure tracked, file contents gitignored
│   │   ├── raw/                        # Unmodified source data as received from upstream
│   │   ├── processed/                  # Cleaned and transformed data ready for model training
│   │   └── sample/                     # Small representative sample for fast local development and testing
│   ├── scripts/
│   │   ├── train.py                    # Training entry point — called by CI pipelines or run manually
│   │   └── predict.py                  # Inference entry point for generating batch predictions
│   └── configs/
│       ├── default_config.yaml         # Base configuration — shared defaults for all environments
│       ├── dev_config.yaml             # Development overrides (relaxed limits, local endpoints)
│       └── prod_config.yaml            # Production overrides (strict limits, remote endpoints)
├── frontend/                           # Frontend — Node 20 / React / Tailwind CSS SPA
│   ├── package.json                    # Node.js dependencies and npm lifecycle scripts
│   ├── vite.config.js                  # Vite bundler configuration and Vitest test setup
│   ├── tailwind.config.js              # Tailwind CSS content paths and theme extension points
│   ├── postcss.config.js               # PostCSS plugins: Tailwind CSS and Autoprefixer
│   ├── .nvmrc                          # Pins Node version to 20 for nvm users — run 'nvm use' before installing
│   ├── .env.example                    # Frontend env var template — commit this, copy to .env with real values
│   ├── Dockerfile                      # node:20-alpine multi-stage build: builder stage + serve-only runner stage
│   ├── .dockerignore                   # Excludes node_modules, dist/, coverage/ from Docker build context
│   ├── public/
│   │   ├── index.html                  # HTML shell loaded by Vite — contains the #root mount point
│   │   └── favicon.ico                 # Browser tab icon
│   ├── src/
│   │   ├── index.jsx                   # React DOM entry point — mounts <App /> to #root
│   │   ├── App.jsx                     # Root component — defines global layout, theme providers, and router
│   │   ├── components/                 # Reusable UI components — one component per file, no page logic here
│   │   ├── pages/                      # Page-level components that are the target of a route — one per route
│   │   ├── hooks/                      # Custom React hooks — all prefixed with 'use' (e.g. useAuth, useData)
│   │   ├── utils/                      # Pure helper functions, constants, and type converters
│   │   ├── assets/                     # Static assets: images, SVGs, fonts, and icons
│   │   └── styles/
│   │       └── index.css               # Tailwind @tailwind directives and global base style overrides
│   └── tests/
│       └── App.test.jsx                # Component tests using Vitest + React Testing Library
├── logs/                               # Centralised runtime logs — mounted into containers via docker-compose volumes
│   ├── backend/                        # Backend log files (gitignored; .gitkeep tracks the folder)
│   ├── frontend/                       # Frontend log files (gitignored; .gitkeep tracks the folder)
│   └── orchestrator/                   # Orchestrator log files (gitignored; .gitkeep tracks the folder)
├── docs/
│   ├── index.md                        # Documentation home — project overview and navigation guide
│   └── api_reference.md                # REST API reference — endpoints, request/response schemas, examples
├── checkpoints/                        # Saved model training checkpoints (gitignored; .gitkeep tracks the folder)
└── tmp/                                # Temporary scratch files — never committed (fully gitignored)
    └── input-prompts/                  # Temporary prompt drafts, experiments, and LLM input test files
\`\`\`
EOL

# Create backend source code files
touch "$PROJECT_DIR"/backend/src/__init__.py \
      "$PROJECT_DIR"/backend/src/data-pipeline/{__init__.py,data_loader.py,data_preprocessor.py} \
      "$PROJECT_DIR"/backend/src/models/{__init__.py,base_model.py,fine_tune.py} \
      "$PROJECT_DIR"/backend/src/utils/{__init__.py,helpers.py,logger.py,tracing.py} \
      "$PROJECT_DIR"/backend/src/evaluation/{__init__.py,metrics.py,evaluate.py} \
      "$PROJECT_DIR"/backend/src/deployment/__init__.py \
      "$PROJECT_DIR"/backend/src/features/{__init__.py,feature_engineering.py} \
      "$PROJECT_DIR"/backend/serving-api/__init__.py

# create backend/src/utils/logger.py
cat > "$PROJECT_DIR/backend/src/utils/logger.py" << 'EOF'
import logging
import sys
from datetime import datetime
from pathlib import Path

import pytz

_LOGS_DIR = Path(__file__).parents[3] / "logs" / "backend"


def get_logger(name: str, log_file: str, log_level: int = logging.DEBUG) -> logging.Logger:
    """Return a named logger writing to logs/backend/YYYYMMDD/<log_file>.log and stdout."""
    logger = logging.getLogger(name)
    if logger.hasHandlers():
        return logger

    logger.setLevel(log_level)

    tz = pytz.timezone("Asia/Dhaka")

    def _converter(*args):
        return datetime.now(tz).timetuple()

    today = datetime.now(tz).strftime("%Y%m%d")
    log_dir = _LOGS_DIR / today
    log_dir.mkdir(parents=True, exist_ok=True)

    fh = logging.FileHandler(log_dir / f"{log_file}.log")
    fh.setLevel(logging.DEBUG)
    fmt_fh = logging.Formatter("[ %(asctime)s ] %(name)-15s %(levelname)-8s %(message)s")
    fmt_fh.converter = _converter
    fh.setFormatter(fmt_fh)
    logger.addHandler(fh)

    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.INFO)
    fmt_ch = logging.Formatter("%(asctime)s %(name)s %(levelname)s %(message)s")
    fmt_ch.converter = _converter
    ch.setFormatter(fmt_ch)
    logger.addHandler(ch)

    return logger
EOF

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
touch "$PROJECT_DIR/logs/backend/.gitkeep"
touch "$PROJECT_DIR/backend/src/deployment/kubernetes/.gitkeep"
touch "$PROJECT_DIR/backend/src/deployment/inference/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/dags/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/spark-node/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/sql/.gitkeep"
touch "$PROJECT_DIR/backend/src/data-pipeline/sqoop/.gitkeep"
touch "$PROJECT_DIR/backend/serving-api/.gitkeep"
touch "$PROJECT_DIR/frontend/src/components/.gitkeep"
touch "$PROJECT_DIR/frontend/src/pages/.gitkeep"
touch "$PROJECT_DIR/frontend/src/hooks/.gitkeep"
touch "$PROJECT_DIR/frontend/src/utils/.gitkeep"
touch "$PROJECT_DIR/frontend/src/assets/.gitkeep"
touch "$PROJECT_DIR/logs/frontend/.gitkeep"
touch "$PROJECT_DIR/tmp/.gitkeep"
touch "$PROJECT_DIR/tmp/input-prompts/.gitkeep"
touch "$PROJECT_DIR/knowledge-base/.gitkeep"
touch "$PROJECT_DIR/orchestrator/src/knowledge/documents/.gitkeep"
touch "$PROJECT_DIR/logs/orchestrator/.gitkeep"

# create .gitignore
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# --- Global ---

# OS artefacts
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor / IDE
.vscode/
*.sublime-*
#.idea/

# Environment files — each developer keeps their own; never commit .env
.env
.env.local
.env.*.local

# Temporary and scratch files
/tmp/*
!/tmp/.gitkeep
!/tmp/input-prompts/

# Model checkpoints — gitignore contents but keep the folder tracked via .gitkeep
/checkpoints/*
!/checkpoints/.gitkeep

# DB folder
*/db/*

# --- Backend ---

# Python byte-compiled / optimised / DLL files
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

# Django
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask
instance/
.webassets-cache

# Scrapy
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

# uv — commit uv.lock for reproducibility; uncomment to ignore
#uv.lock

# pdm
.pdm.toml
.pdm-python
.pdm-build/

# PEP 582
__pypackages__/

# Celery
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Virtual environments
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder
.spyderproject
.spyproject

# Rope
.ropeproject

# mkdocs
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Claude
.claude/
CLAUDE.md

# Cython debug symbols
cython_debug/

# Ruff
.ruff_cache/

# PyPI
.pypirc

# Central logs directory
/logs/backend/*
!/logs/backend/.gitkeep

# Data files — track directory structure only, not actual data contents
/backend/data/raw/*
!/backend/data/raw/.gitkeep
/backend/data/processed/*
!/backend/data/processed/.gitkeep
/backend/data/sample/*
!/backend/data/sample/.gitkeep

# --- Frontend ---

# Installed packages — restore with: npm install
frontend/node_modules/

# Production build output
frontend/build/
frontend/dist/
frontend/.vite/

# Test coverage reports
frontend/coverage/

# Misc tooling artefacts
frontend/.DS_Store
frontend/npm-debug.log*
frontend/yarn-debug.log*
frontend/yarn-error.log*
frontend/.pnp/
frontend/.pnp.js

/logs/frontend/*
!/logs/frontend/.gitkeep

# --- Orchestrator ---

# Orchestrator virtual environment and compiled files
orchestrator/.venv/
orchestrator/**/__pycache__/
orchestrator/**/*.py[cod]
orchestrator/**/*.egg-info/
orchestrator/.pytest_cache/
orchestrator/.ruff_cache/

/logs/orchestrator/*
!/logs/orchestrator/.gitkeep

# FAISS index files — persisted to Docker volume; never commit the index binary
orchestrator/src/knowledge/documents/*.index
orchestrator/src/knowledge/documents/*.npy

# --- Claude Code ---

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
    "pytz>=2024.1",
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
      - ./logs/backend:/app/logs

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
      - ./logs/orchestrator:/app/logs
      - faiss_data:/app/src/knowledge/documents

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
    image: pgvector/pgvector:pg16
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
  faiss_data:
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

# create justfile — root task runner
cat > "$PROJECT_DIR/justfile" << 'EOF'
# justfile — root task runner for the AI LLM Project
# Install just: https://github.com/casey/just
# Usage: just <recipe>

# Default: list all available recipes
default:
    @just --list

# ── Database seeding ──────────────────────────────────────────────────────────
# Seed the PostgreSQL database with initial schema and sample data
seed-db:
    docker compose exec db psql -U postgres -d appdb -c "SELECT 'seed placeholder — add your seed SQL here';"

# ── Log management ───────────────────────────────────────────────────────────
# Clear all log files across backend, frontend, and orchestrator
clear-logs:
    find logs/backend -type f -name "*.log" -delete
    find logs/frontend -type f -name "*.log" -delete
    find logs/orchestrator -type f -name "*.log" -delete
    @echo "All logs cleared."

# ── Linting ──────────────────────────────────────────────────────────────────
# Lint backend Python code with ruff
lint-backend:
    cd backend && uv run ruff check .

# Lint orchestrator Python code with ruff
lint-orchestrator:
    cd orchestrator && uv run ruff check .

# Lint frontend JavaScript/TypeScript code with ESLint
lint-frontend:
    cd frontend && npm run lint

# Lint all projects simultaneously
lint-all: lint-backend lint-orchestrator lint-frontend

# ── Testing ──────────────────────────────────────────────────────────────────
# Run backend unit tests
test-backend:
    cd backend && uv run pytest tests/ -v --tb=short

# Run orchestrator unit tests
test-orchestrator:
    cd orchestrator && uv run pytest tests/ -v --tb=short

# Run frontend unit tests
test-frontend:
    cd frontend && npm test

# Run all unit tests across all projects
test-all: test-backend test-orchestrator test-frontend

# Run end-to-end integration tests against the full docker-compose stack
test-integration:
    docker compose up -d
    sleep 5
    uv run pytest tests/integration/ -v --tb=short
    docker compose down

# ── Docker ───────────────────────────────────────────────────────────────────
# Build and start all services
up:
    docker compose up --build -d

# Stop all services and remove volumes
down:
    docker compose down -v

# Rebuild a single service (usage: just rebuild backend)
rebuild service:
    docker compose up --build -d {{service}}

# Stream logs for a service (usage: just logs orchestrator)
logs service:
    docker compose logs -f {{service}}

# ── Setup ────────────────────────────────────────────────────────────────────
# Install all dependencies across backend, orchestrator, and frontend
install:
    cd backend && uv sync
    cd orchestrator && uv sync
    cd frontend && npm install
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
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/ruff-format.sh",
            "timeout": 20,
            "statusMessage": "Running ruff format..."
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
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/ruff-format.sh",
            "timeout": 20,
            "statusMessage": "Running ruff format..."
          }
        ]
      }
    ]
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

# Example: append a log entry to logs/claude_tool.log
LOG_FILE="logs/claude_tool.log"
if [ -d "logs" ]; then
  echo "$TIMESTAMP  tool=$TOOL_NAME  exit=$?" >> "$LOG_FILE"
fi
EOF
chmod +x "$PROJECT_DIR/.claude/hooks/PostToolUse.sh"

# create .claude/hooks/ruff-format.sh
cat > "$PROJECT_DIR/.claude/hooks/ruff-format.sh" << 'EOF'
#!/usr/bin/env bash
# PostToolUse hook: runs `ruff format` on any .py file Claude Code writes/edits.
# Reads the tool-call JSON from stdin, extracts the file_path, and formats it
# if it's a Python file and ruff is available.

set -euo pipefail

INPUT=$(cat)

# file_path is present for Write/Edit/MultiEdit tool calls
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Nothing to do if there's no path or it's not a .py file
if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.py ]]; then
  exit 0
fi

# Skip if the file doesn't actually exist (e.g. it was deleted)
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Make sure ruff is on PATH; adjust this if you use a venv/poetry/uv
if ! command -v ruff >/dev/null 2>&1; then
  echo "ruff not found on PATH; skipping format for $FILE_PATH" >&2
  exit 0
fi

# 1. Fix lint-only concerns first: import sorting ([tool.ruff.lint.isort])
#    and any other auto-fixable lint rules. `ruff format` does NOT read
#    [tool.ruff.lint] / [tool.ruff.lint.isort] / [tool.ruff.lint.pydocstyle]
#    at all -- those only apply under `ruff check`.
#    --fix only applies fixable rules; pydocstyle (D) rules have no
#    autofix, so they'll still surface as diagnostics, not be silently
#    "fixed" -- that's expected, not a bug.
ruff check --fix --select I "$FILE_PATH" 2>&1 || true

# 2. Apply actual code formatting ([tool.ruff.format]).
#    Both commands independently discover the nearest pyproject.toml by
#    walking up from $FILE_PATH, so backend/pyproject.toml (or any
#    subproject config) is picked up correctly without extra flags.
ruff format "$FILE_PATH"
EOF
chmod +x "$PROJECT_DIR/.claude/hooks/ruff-format.sh"

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
    "pytz>=2024.1",
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
touch "$PROJECT_DIR"/orchestrator/src/memory/{__init__.py,base.py,cache.py,embeddings.py}
touch "$PROJECT_DIR"/orchestrator/src/tools/{__init__.py,base.py,web_search.py,calculator.py,file_reader.py,custom_tools.py}
touch "$PROJECT_DIR"/orchestrator/src/llm/{__init__.py,client.py,token_counter.py}
touch "$PROJECT_DIR"/orchestrator/src/utils/{__init__.py,logger.py,helpers.py,timers.py}

# create orchestrator/src/utils/logger.py
cat > "$PROJECT_DIR/orchestrator/src/utils/logger.py" << 'EOF'
import logging
import sys
from datetime import datetime
from pathlib import Path

import pytz

_LOGS_DIR = Path(__file__).parents[3] / "logs" / "orchestrator"


def get_logger(name: str, log_file: str, log_level: int = logging.DEBUG) -> logging.Logger:
    """Return a named logger writing to logs/orchestrator/YYYYMMDD/<log_file>.log and stdout."""
    logger = logging.getLogger(name)
    if logger.hasHandlers():
        return logger

    logger.setLevel(log_level)

    tz = pytz.timezone("Asia/Dhaka")

    def _converter(*args):
        return datetime.now(tz).timetuple()

    today = datetime.now(tz).strftime("%Y%m%d")
    log_dir = _LOGS_DIR / today
    log_dir.mkdir(parents=True, exist_ok=True)

    fh = logging.FileHandler(log_dir / f"{log_file}.log")
    fh.setLevel(logging.DEBUG)
    fmt_fh = logging.Formatter("[ %(asctime)s ] %(name)-15s %(levelname)-8s %(message)s")
    fmt_fh.converter = _converter
    fh.setFormatter(fmt_fh)
    logger.addHandler(fh)

    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.INFO)
    fmt_ch = logging.Formatter("%(asctime)s %(name)s %(levelname)s %(message)s")
    fmt_ch.converter = _converter
    ch.setFormatter(fmt_ch)
    logger.addHandler(ch)

    return logger
EOF

touch "$PROJECT_DIR"/shared/models/__init__.py
touch "$PROJECT_DIR"/shared/interfaces/index.ts
touch "$PROJECT_DIR"/tests/integration/__init__.py

# create orchestrator/src/agents/registry.py — dynamic specialist registry
cat > "$PROJECT_DIR/orchestrator/src/agents/registry.py" << 'EOF'
import importlib
import pkgutil
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from orchestrator.src.agents.base import BaseAgent

_REGISTRY: dict[str, type] = {}


def register(name: str):
    """Decorator that registers a specialist agent class under a given name."""
    def decorator(cls):
        _REGISTRY[name] = cls
        return cls
    return decorator


def _load_specialists() -> None:
    """Auto-import all modules in specialists/ so @register decorators fire."""
    specialists_path = Path(__file__).parent / "specialists"
    package = f"{__package__}.specialists"
    for _, module_name, _ in pkgutil.iter_modules([str(specialists_path)]):
        importlib.import_module(f"{package}.{module_name}")


def get(name: str):
    if name not in _REGISTRY:
        _load_specialists()
    if name not in _REGISTRY:
        raise KeyError(f"No specialist registered as '{name}'. Available: {list(_REGISTRY)}")
    return _REGISTRY[name]


def all_specialists() -> dict[str, type]:
    _load_specialists()
    return dict(_REGISTRY)
EOF

# create orchestrator/src/memory/short_term.py — Redis-backed ephemeral session history
cat > "$PROJECT_DIR/orchestrator/src/memory/short_term.py" << 'EOF'
import json
from typing import Any

import redis.asyncio as redis

from config.settings import settings


class ShortTermMemory:
    """Ephemeral session history backed by Redis. Each session key expires via TTL."""

    def __init__(self, session_id: str, ttl: int = 3600) -> None:
        self._client: redis.Redis = redis.from_url(settings.redis_url, decode_responses=True)
        self._key = f"session:{session_id}:history"
        self._ttl = ttl

    async def append(self, role: str, content: str) -> None:
        message = json.dumps({"role": role, "content": content})
        async with self._client.pipeline() as pipe:
            pipe.rpush(self._key, message)
            pipe.expire(self._key, self._ttl)
            await pipe.execute()

    async def get_history(self) -> list[dict[str, Any]]:
        raw = await self._client.lrange(self._key, 0, -1)
        return [json.loads(m) for m in raw]

    async def clear(self) -> None:
        await self._client.delete(self._key)
EOF

# create orchestrator/src/memory/long_term.py — PostgreSQL-backed persistent state
cat > "$PROJECT_DIR/orchestrator/src/memory/long_term.py" << 'EOF'
from datetime import datetime

from sqlalchemy import Column, DateTime, String, Text, create_engine
from sqlalchemy.orm import DeclarativeBase, Session

from config.settings import settings


class Base(DeclarativeBase):
    pass


class ConversationRecord(Base):
    __tablename__ = "conversation_records"

    id = Column(String, primary_key=True)
    session_id = Column(String, index=True, nullable=False)
    role = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class LongTermMemory:
    """Persistent relational state backed by PostgreSQL. Survives container restarts."""

    def __init__(self) -> None:
        self._engine = create_engine(settings.database_url)
        Base.metadata.create_all(self._engine)

    def save(self, record_id: str, session_id: str, role: str, content: str) -> None:
        with Session(self._engine) as session:
            record = ConversationRecord(
                id=record_id,
                session_id=session_id,
                role=role,
                content=content,
            )
            session.add(record)
            session.commit()

    def get_session_history(self, session_id: str) -> list[dict]:
        with Session(self._engine) as session:
            records = (
                session.query(ConversationRecord)
                .filter_by(session_id=session_id)
                .order_by(ConversationRecord.created_at)
                .all()
            )
            return [{"role": r.role, "content": r.content} for r in records]
EOF

# create orchestrator/src/memory/vector_db.py — FAISS semantic storage (disk-persisted)
# FAISS saves its index to local disk files; the Docker volume mount at
# /app/src/knowledge/documents ensures the index survives container restarts.
cat > "$PROJECT_DIR/orchestrator/src/memory/vector_db.py" << 'EOF'
from pathlib import Path

import faiss
import numpy as np

from config.settings import settings


class FAISSVectorDB:
    """Semantic storage via FAISS persisted to disk via a Docker volume mount.

    Index files live at settings.vector_db_path which maps to the faiss_data
    named volume in docker-compose.yml so the index is never wiped on restart.
    """

    _INDEX_FILE = "faiss.index"
    _TEXTS_FILE = "faiss_texts.npy"

    def __init__(self, dim: int = 1536) -> None:
        self._path = Path(settings.vector_db_path)
        self._path.mkdir(parents=True, exist_ok=True)
        self._index_path = self._path / self._INDEX_FILE
        self._texts_path = self._path / self._TEXTS_FILE

        if self._index_path.exists():
            self._index = faiss.read_index(str(self._index_path))
            self._texts: list[str] = np.load(
                str(self._texts_path), allow_pickle=True
            ).tolist()
        else:
            self._index = faiss.IndexFlatL2(dim)
            self._texts = []

    def add(self, vectors: np.ndarray, texts: list[str]) -> None:
        self._index.add(vectors.astype("float32"))
        self._texts.extend(texts)
        self._persist()

    def search(self, query: np.ndarray, k: int = 5) -> list[str]:
        _, indices = self._index.search(query.astype("float32").reshape(1, -1), k)
        return [self._texts[i] for i in indices[0] if i < len(self._texts)]

    def _persist(self) -> None:
        faiss.write_index(self._index, str(self._index_path))
        np.save(str(self._texts_path), np.array(self._texts, dtype=object))
EOF

# create shared/models/__init__.py — Pydantic schemas shared between backend and orchestrator
cat > "$PROJECT_DIR/shared/models/__init__.py" << 'EOF'
from pydantic import BaseModel


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    session_id: str
    message: str


class ChatResponse(BaseModel):
    session_id: str
    reply: str
    tool_calls_used: list[str] = []
EOF

# create shared/interfaces/index.ts — TypeScript interfaces matching Pydantic schemas
cat > "$PROJECT_DIR/shared/interfaces/index.ts" << 'EOF'
export interface ChatMessage {
  role: string;
  content: string;
}

export interface ChatRequest {
  session_id: string;
  message: string;
}

export interface ChatResponse {
  session_id: string;
  reply: string;
  tool_calls_used: string[];
}
EOF

# create tests/integration/test_e2e_flow.py — E2E tests for the full docker-compose stack
cat > "$PROJECT_DIR/tests/integration/test_e2e_flow.py" << 'EOF'
"""Integration tests — spin up the full docker-compose stack and verify end-to-end flows.

Run with:
    just test-integration
    # or manually:
    docker compose up -d && sleep 5 && pytest tests/integration/ -v
"""

import time

import httpx
import pytest

BACKEND_URL = "http://localhost:8000"
ORCHESTRATOR_URL = "http://localhost:8001"


@pytest.fixture(scope="session", autouse=True)
def wait_for_services():
    """Poll each service health endpoint until ready or timeout."""
    services = [(BACKEND_URL, "/health"), (ORCHESTRATOR_URL, "/health")]
    timeout = 60
    for base_url, path in services:
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                resp = httpx.get(f"{base_url}{path}", timeout=2)
                if resp.status_code == 200:
                    break
            except httpx.RequestError:
                time.sleep(2)
        else:
            pytest.fail(f"Service at {base_url}{path} did not become healthy within {timeout}s")


def test_backend_health():
    resp = httpx.get(f"{BACKEND_URL}/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_orchestrator_health():
    resp = httpx.get(f"{ORCHESTRATOR_URL}/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"
EOF

# create CLAUDE.md
cat > "$PROJECT_DIR/CLAUDE.md" << 'EOF'
# Project Context

## Overview
<!-- Describe what this project does and its purpose -->

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## Project Structure
- `backend/src/` — Python source code (data-pipeline, models, utils, evaluation, deployment)
- `backend/serving-api/` — FastAPI route handlers — one router file per resource domain
- `backend/src/features/` — Feature engineering modules
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
- `orchestrator/src/agents/registry.py` — Dynamic specialist registry (auto-imports via pkgutil)
- `orchestrator/src/memory/short_term.py` — Redis-backed ephemeral session history
- `orchestrator/src/memory/long_term.py` — PostgreSQL-backed persistent state
- `orchestrator/src/memory/vector_db.py` — FAISS semantic storage (disk-persisted via Docker volume)
- `orchestrator/prompts/` — System prompts, task schemas, and few-shot templates
- `shared/models/` — Pydantic schemas shared between backend and orchestrator
- `shared/interfaces/` — TypeScript interfaces shared with the frontend
- `knowledge-base/` — Static domain knowledge and reference documents
- `tests/integration/` — E2E tests that spin up the full docker-compose stack
- `backend/tests/` — Backend unit tests (pytest)
- `backend/scripts/` — Standalone train/predict scripts
- `backend/src/utils/logger.py` — get_logger() writing to logs/backend/YYYYMMDD/
- `orchestrator/src/utils/logger.py` — get_logger() writing to logs/orchestrator/YYYYMMDD/
- `logs/` — Centralised runtime logs: logs/backend/, logs/frontend/, logs/orchestrator/ (not committed)
- `checkpoints/` — Saved model checkpoints (not committed; .gitkeep preserves the folder)
- `tmp/` — Temporary scratch files (not committed)
- `tmp/input-prompts/` — Temporary prompt drafts and experiments

## Key Files
- `docker-compose.yml` — Orchestrates all services (PostgreSQL+pgvector, Redis, backend, orchestrator, frontend)
- `justfile` — Root task runner: lint, test, seed DB, clear logs
- `backend/pyproject.toml` — Python dependencies and tool configuration
- `backend/configs/default_config.yaml` — Default runtime configuration
- `backend/configs/prod_config.yaml` — Production overrides
- `frontend/package.json` — Node.js dependencies and scripts (requires Node 20)
- `frontend/vite.config.js` — Vite bundler + Vitest configuration
- `orchestrator/pyproject.toml` — Orchestrator dependencies
- `orchestrator/config/settings.py` — Pydantic settings with env validation
- `shared/models/__init__.py` — Pydantic schemas that define the cross-stack API contract
- `shared/interfaces/index.ts` — TypeScript interfaces mirroring the Pydantic schemas
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
