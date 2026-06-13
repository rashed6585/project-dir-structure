
#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-directory-name>"
  exit 1
fi

PROJECT_DIR=$1

# Create directories
mkdir -p "$PROJECT_DIR"/{src,tests,notebooks,data,scripts,docs,configs,logs,checkpoints}
mkdir -p "$PROJECT_DIR"/src/{data,models,utils,evaluation}
mkdir -p "$PROJECT_DIR"/data/{raw,processed}
mkdir -p "$PROJECT_DIR"/prompts
mkdir -p "$PROJECT_DIR"/.claude/{commands,agents,skills,rules,hooks}

# Create root-level files
touch "$PROJECT_DIR"/{LICENSE,.gitignore,pyproject.toml,config.yaml}

# include .env with default input
cat <<EOL > "$PROJECT_DIR/.env"

# Environment variables go here, can be read by python-dotenv package:
#
#   src/script.py
#   ----------------------------------------------------------------
#    import dotenv
#
#    project_dir = os.path.join(os.path.dirname(__file__), os.pardir)
#    dotenv_path = os.path.join(project_dir, '.env')
#    dotenv.load_dotenv(dotenv_path)
#   ----------------------------------------------------------------
#
# DO NOT ADD THIS FILE TO VERSION CONTROL!
SMPT_SERVER=
SMPT_PORT=
SMPT_SENDER=
ODBC_PER_USER_ENV=
ODBC_PER_PASS_ENV=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
AWS_BEDROCK_TOKEN=
EOL

# Create README.md with dynamic folder name
cat <<EOL > "$PROJECT_DIR/README.md"
# AI LLM Project

This project contains the structure for an AI LLM pipeline including data handling, model training, evaluation, and deployment.

## Folder Structure

$PROJECT_DIR/
├── README.md                       # Project overview and instructions
├── LICENSE                         # Licensing information
├── .gitignore                      # Files and directories to be ignored by Git
├── pyproject.toml                  # Project configuration and dependencies (uv)
├── config.yaml                     # Default configuration file
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
├── src/                            # Source code
│   ├── __init__.py                 # Initializes the src package
│   ├── data/                       # Data handling modules
│   │   ├── __init__.py
│   │   ├── data_loader.py          # Data loading logic
│   │   ├── data_preprocessor.py    # Data preprocessing steps
│   ├── models/                     # Model modules
│   │   ├── __init__.py
│   │   ├── base_model.py           # Base model architecture
│   │   ├── fine_tune.py            # Fine-tuning logic
│   ├── utils/                      # Utility functions
│   │   ├── __init__.py
│   │   ├── file_utils.py           # File operation helpers
│   │   ├── logger.py               # Logging utilities
│   ├── evaluation/                 # Evaluation modules
│       ├── __init__.py
│       ├── metrics.py              # Evaluation metrics              
│       ├── evaluate.py             # Evaluation scripts
├── tests/                          # Unit tests
│   ├── test_data_loader.py         # Tests for data loading
│   ├── test_fine_tune.py           # Tests for fine-tuning
│   ├── test_metrics.py             # Tests for evaluation metrics
├── notebooks/                      # Jupyter notebooks
│   ├── data_exploration.ipynb      # Dataset exploration and visualization
│   ├── model_training.ipynb        # Model training workflow
├── data/                           # Dataset storage
│   ├── raw/                        # Raw datasets
│   ├── processed/                  # Processed datasets
├── scripts/                        # Standalone scripts
│   ├── train.py                    # Script for training models
│   ├── predict.py                  # Script for generating predictions
├── docs/                           # Documentation
│   ├── index.md                    # Documentation index                    
│   ├── api_reference.md            # API reference documentation
├── configs/                        # Configuration files
│   ├── default_config.yaml         # Default configuration settings
│   ├── dev_config.yaml             # Development configuration settings
├── logs/                           # Log files
├── checkpoints/                    # Saved model checkpoints
EOL

# Create source code files
touch "$PROJECT_DIR"/src/__init__.py \
      "$PROJECT_DIR"/src/data/{__init__.py,data_loader.py,data_preprocessor.py} \
      "$PROJECT_DIR"/src/models/{__init__.py,base_model.py,fine_tune.py} \
      "$PROJECT_DIR"/src/utils/{__init__.py,file_utils.py,logger.py} \
      "$PROJECT_DIR"/src/evaluation/{__init__.py,metrics.py,evaluate.py}

# Create test files
touch "$PROJECT_DIR"/tests/{test_data_loader.py,test_fine_tune.py,test_metrics.py}

# Create notebook files
touch "$PROJECT_DIR"/notebooks/{data_exploration.ipynb,model_training.ipynb}

# Create script files
touch "$PROJECT_DIR"/scripts/{train.py,predict.py}

# Create documentation files
touch "$PROJECT_DIR"/docs/{index.md,api_reference.md}

# Create config files
touch "$PROJECT_DIR"/configs/{default_config.yaml,dev_config.yaml}

# .gitkeep for empty folder
touch "$PROJECT_DIR/checkpoints/.gitkeep"
touch "$PROJECT_DIR/data/processed/.gitkeep"
touch "$PROJECT_DIR/data/raw/.gitkeep"
touch "$PROJECT_DIR/logs/.gitkeep"


# create gitignore
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
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
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
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
#   For a library or package, you might want to ignore these files since the code is
#   intended to run in multiple environments; otherwise, check them in:
# .python-version

# pipenv
#   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
#   However, in case of collaboration, if having platform-specific dependencies or dependencies
#   having no cross-platform support, pipenv may install dependencies that don't work, or not
#   install all needed dependencies.
#Pipfile.lock

# UV
#   Similar to Pipfile.lock, it is generally recommended to include uv.lock in version control.
#   This is especially recommended for binary packages to ensure reproducibility, and is more
#   commonly ignored for libraries.
#uv.lock

# poetry
#   Similar to Pipfile.lock, it is generally recommended to include poetry.lock in version control.
#   This is especially recommended for binary packages to ensure reproducibility, and is more
#   commonly ignored for libraries.
#   https://python-poetry.org/docs/basic-usage/#commit-your-poetrylock-file-to-version-control
#poetry.lock

# pdm
#   Similar to Pipfile.lock, it is generally recommended to include pdm.lock in version control.
#pdm.lock
#   pdm stores project-wide configurations in .pdm.toml, but it is recommended to not include it
#   in version control.
#   https://pdm.fming.dev/latest/usage/project/#working-with-version-control
.pdm.toml
.pdm-python
.pdm-build/

# PEP 582; used by e.g. github.com/David-OConnor/pyflow and github.com/pdm-project/pdm
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

# log folder
/logs/*

# db folder
*/db/*

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
#  JetBrains specific template is maintained in a separate JetBrains.gitignore that can
#  be found at https://github.com/github/gitignore/blob/main/Global/JetBrains.gitignore
#  and can be added to the global gitignore or merged into this file.  For a more nuclear
#  option (not recommended) you can uncomment the following to ignore the entire idea folder.
#.idea/

# Ruff stuff:
.ruff_cache/

# PyPI configuration file
.pypirc

# Claude Code local overrides (personal settings, not team-shared)
.claude/settings.local.json
EOF

# create pyproject.toml
cat > "$PROJECT_DIR/pyproject.toml" << 'EOF'
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
      "Bash(python -m pytest*)"
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

# Example: append a log entry to logs/claude_tool.log
LOG_FILE="logs/claude_tool.log"
if [ -d "logs" ]; then
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
- All data loading goes through `src/data/data_loader.py`
- Log using the project logger in `src/utils/logger.py`, never `print()`
- Configuration is read from `config.yaml`; never hard-code paths or credentials

## Testing
- Test files mirror the `src/` structure under `tests/`
- Use `pytest` fixtures; avoid global state between tests
EOF

# create .claude/skills/analyze-data.md
cat > "$PROJECT_DIR/.claude/skills/analyze-data.md" << 'EOF'
---
name: analyze-data
description: Load a dataset from data/processed/, print shape and dtypes, generate descriptive statistics, and flag columns with >10% missing values.
---

Load the dataset at the path the user provides (default: data/processed/).
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
uv run pytest tests/ -v --tb=short
```
EOF

# create .claude/agents/data-analyst.md
cat > "$PROJECT_DIR/.claude/agents/data-analyst.md" << 'EOF'
---
name: data-analyst
description: Use this agent to explore datasets, compute statistics, and produce visualisation code. Works with files in data/raw/ and data/processed/.
---

You are a data analysis specialist for this LLM project.
When analysing data:
1. Load from `data/processed/` (prefer) or `data/raw/`
2. Use pandas for statistics and seaborn/matplotlib for charts
3. Flag data quality issues (nulls, duplicates, outliers)
4. Return runnable code snippets the user can paste into notebooks/

Tools available: Bash, Read. Do not write files unless asked.
EOF

# create CLAUDE.md
cat > "$PROJECT_DIR/CLAUDE.md" << 'EOF'
# Project Context

## Overview
<!-- Describe what this project does and its purpose -->

## Package Management
This project uses [uv](https://docs.astral.sh/uv/) for dependency management.

```bash
uv sync                     # Install all dependencies (including dev)
uv add <package>            # Add a runtime dependency
uv add --dev <package>      # Add a dev dependency
uv run pytest               # Run tests
uv run ruff check .         # Lint
uv run ruff format .        # Format
```

## Project Structure
- `src/` — Source code (data loading, models, utils, evaluation)
- `tests/` — Unit tests (pytest)
- `notebooks/` — Jupyter notebooks for exploration
- `scripts/` — Standalone train/predict scripts
- `configs/` — YAML configuration files
- `data/raw/` — Raw input datasets (not committed)
- `data/processed/` — Processed datasets (not committed)
- `checkpoints/` — Saved model checkpoints (not committed)

## Key Files
- `pyproject.toml` — Dependencies and tool configuration
- `config.yaml` — Default runtime configuration
- `.env` — Secrets and environment variables (not committed)
EOF

# Initialize Git repository
cd "$PROJECT_DIR"
git init
git add .
git commit -m "initial commit project structure."