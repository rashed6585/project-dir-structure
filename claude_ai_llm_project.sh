
#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-directory-name>"
  exit 1
fi

PROJECT_DIR=$1

# Create directories
mkdir -p "$PROJECT_DIR"/{docs,checkpoints,tmp,backend,frontend}
mkdir -p "$PROJECT_DIR"/backend/{src,notebooks,tests,scripts,configs,logs}
mkdir -p "$PROJECT_DIR"/backend/src/{models,utils,evaluation}
mkdir -p "$PROJECT_DIR"/backend/src/data-pipeline/{sql,sqoop}
mkdir -p "$PROJECT_DIR"/backend/data/{raw,processed}
mkdir -p "$PROJECT_DIR"/prompts
mkdir -p "$PROJECT_DIR"/.claude/{commands,agents,skills,rules,hooks}
mkdir -p "$PROJECT_DIR"/frontend/{public,tests,logs}
mkdir -p "$PROJECT_DIR"/frontend/src/{components,pages,hooks,utils,assets,styles}

# Create root-level files
touch "$PROJECT_DIR"/LICENSE
touch "$PROJECT_DIR"/backend/{pyproject.toml,config.yaml}

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

# ── AWS / Bedrock ─────────────────────────────────────────────────────────────
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_REGION=us-east-1
AWS_BEDROCK_TOKEN=your-bedrock-token
EOF

# Create README.md with dynamic folder name
cat <<EOL > "$PROJECT_DIR/README.md"
# AI LLM Project

This project contains the structure for an AI LLM pipeline including data handling, model training, evaluation, and deployment.

## Folder Structure

$PROJECT_DIR/
├── LICENSE                         # Licensing information
├── .gitignore                      # Files and directories to be ignored by Git
├── README.md                       # Project overview and instructions
├── CLAUDE.md                       # Claude Code project context and instructions
├── .claude/                        # Claude Code project settings
│   ├── settings.json               # Shared permissions and hooks (team-committed)
│   ├── settings.local.json         # Personal local overrides (gitignored)
│   ├── commands/                   # Custom slash commands
│   ├── agents/                     # Custom subagent definitions
│   ├── skills/                     # Reusable prompt skills
│   ├── rules/                      # Project coding conventions
│   └── hooks/                      # Shell scripts triggered by Claude Code hooks
├── prompts/                        # Prompt templates
├── backend/                        # Backend — Python / AI-LLM
│   ├── pyproject.toml              # Python dependencies and tool config (uv)
│   ├── config.yaml                 # Default runtime configuration
│   ├── .env.example                # Backend env var template (commit this)
│   ├── notebooks/                  # Jupyter notebooks
│   │   ├── data_exploration.ipynb  # Dataset exploration and visualisation
│   │   └── model_training.ipynb    # Model training workflow
│   ├── src/                        # Source code
│   │   ├── __init__.py
│   │   ├── data-pipeline/          # Data handling modules
│   │   │   ├── __init__.py
│   │   │   ├── data_loader.py      # Data loading logic
│   │   │   ├── data_preprocessor.py # Data preprocessing steps
│   │   │   ├── sql/                # SQL scripts
│   │   │   └── sqoop/              # Sqoop import/export jobs
│   │   ├── models/                 # Model modules
│   │   │   ├── __init__.py
│   │   │   ├── base_model.py       # Base model architecture
│   │   │   └── fine_tune.py        # Fine-tuning logic
│   │   ├── utils/                  # Utility functions
│   │   │   ├── __init__.py
│   │   │   ├── file_utils.py       # File operation helpers
│   │   │   └── logger.py           # Logging utilities
│   │   └── evaluation/             # Evaluation modules
│   │       ├── __init__.py
│   │       ├── metrics.py          # Evaluation metrics
│   │       └── evaluate.py         # Evaluation scripts
│   ├── tests/                      # Backend unit tests (pytest)
│   │   ├── test_data_loader.py
│   │   ├── test_fine_tune.py
│   │   └── test_metrics.py
│   ├── data/                       # Dataset storage
│   │   ├── raw/                    # Raw datasets
│   │   └── processed/              # Processed datasets
│   ├── scripts/                    # Standalone scripts
│   │   ├── train.py                # Script for training models
│   │   └── predict.py              # Script for generating predictions
│   ├── configs/                    # Shared configuration files
│   │   ├── default_config.yaml     # Default configuration settings
│   │   └── dev_config.yaml         # Development configuration settings
│   └── logs/                       # Backend log files (gitignored)
├── frontend/                       # Frontend — Node 20 / React / Tailwind CSS
│   ├── package.json                # Node.js dependencies and scripts
│   ├── vite.config.js              # Vite bundler configuration
│   ├── tailwind.config.js          # Tailwind CSS configuration
│   ├── postcss.config.js           # PostCSS plugins (Tailwind + Autoprefixer)
│   ├── .nvmrc                      # Pins Node version to 20
│   ├── .env                        # Frontend env vars (not committed)
│   ├── .env.example                # Frontend env var template (commit this)
│   ├── public/                     # Static assets served as-is
│   │   ├── index.html              # HTML entry point
│   │   └── favicon.ico
│   ├── src/                        # React source code
│   │   ├── index.jsx               # Application entry point
│   │   ├── App.jsx                 # Root component
│   │   ├── components/             # Reusable UI components
│   │   ├── pages/                  # Page-level route components
│   │   ├── hooks/                  # Custom React hooks
│   │   ├── utils/                  # Frontend helper utilities
│   │   ├── assets/                 # Images, fonts, icons
│   │   └── styles/
│   │       └── index.css           # Tailwind directives + global styles
│   ├── tests/                      # Frontend unit / integration tests
│   │   └── App.test.jsx
│   └── logs/                       # Frontend log files (gitignored)
├── docs/                           # Documentation
│   ├── index.md                    # Documentation index
│   └── api_reference.md            # API reference documentation
├── checkpoints/                    # Saved model checkpoints (gitignored)
└── tmp/                            # Temporary scratch files (gitignored)
EOL

# Create backend source code files
touch "$PROJECT_DIR"/backend/src/__init__.py \
      "$PROJECT_DIR"/backend/src/data-pipeline/{__init__.py,data_loader.py,data_preprocessor.py} \
      "$PROJECT_DIR"/backend/src/models/{__init__.py,base_model.py,fine_tune.py} \
      "$PROJECT_DIR"/backend/src/utils/{__init__.py,file_utils.py,logger.py} \
      "$PROJECT_DIR"/backend/src/evaluation/{__init__.py,metrics.py,evaluate.py}

# Create test files
touch "$PROJECT_DIR"/backend/tests/{test_data_loader.py,test_fine_tune.py,test_metrics.py}

# Create notebook files
touch "$PROJECT_DIR"/backend/notebooks/{data_exploration.ipynb,model_training.ipynb}

# Create script files
touch "$PROJECT_DIR"/backend/scripts/{train.py,predict.py}

# Create documentation files
touch "$PROJECT_DIR"/docs/{index.md,api_reference.md}

# Create config files
touch "$PROJECT_DIR"/backend/configs/{default_config.yaml,dev_config.yaml}

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
touch "$PROJECT_DIR/backend/logs/.gitkeep"
touch "$PROJECT_DIR/frontend/logs/.gitkeep"
touch "$PROJECT_DIR/tmp/.gitkeep"


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

# Temporary scratch files
/tmp/*
!/tmp/.gitkeep

# DB folder
*/db/*

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
- Configuration is read from `backend/config.yaml`; never hard-code paths or credentials

## Frontend Patterns
- Node 20 required — run `nvm use` inside `frontend/` before installing or running scripts
- Components live in `frontend/src/components/`; one component per file
- Page-level components (route targets) live in `frontend/src/pages/`
- Custom hooks live in `frontend/src/hooks/`; prefix with `use`
- Style with Tailwind utility classes; avoid writing custom CSS unless unavoidable
- Global styles and Tailwind directives (`@tailwind base/components/utilities`) go in `frontend/src/styles/index.css`
- Never import `index.css` more than once — it is imported in `index.jsx` only

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

## Project Structure
- `backend/src/` — Python source code (data-pipeline, models, utils, evaluation)
- `backend/notebooks/` — Jupyter notebooks for exploration
- `backend/config.yaml` — Default runtime configuration
- `frontend/src/` — React source (components, pages, hooks, utils, assets, styles)
- `frontend/src/styles/index.css` — Tailwind CSS directives and global styles
- `frontend/public/` — Static assets served as-is
- `backend/tests/` — Backend unit tests (pytest)
- `backend/scripts/` — Standalone train/predict scripts
- `backend/configs/` — Shared YAML configuration files
- `backend/data/raw/` — Raw input datasets (not committed)
- `backend/data/processed/` — Processed datasets (not committed)
- `frontend/logs/` — Frontend log files (not committed)
- `checkpoints/` — Saved model checkpoints (not committed)
- `tmp/` — Temporary scratch files (not committed)

## Key Files
- `backend/pyproject.toml` — Python dependencies and tool configuration
- `backend/config.yaml` — Default runtime configuration
- `frontend/package.json` — Node.js dependencies and scripts (requires Node 20)
- `frontend/vite.config.js` — Vite bundler + Vitest configuration
- `frontend/tailwind.config.js` — Tailwind CSS content paths and theme
- `frontend/postcss.config.js` — PostCSS pipeline (Tailwind + Autoprefixer)
- `frontend/.nvmrc` — Pins Node 20 for nvm users
- `.env` — Root secrets and environment variables (not committed)
EOF

# Initialize Git repository
cd "$PROJECT_DIR"
git init
git add .
git commit -m "initial commit project structure."
