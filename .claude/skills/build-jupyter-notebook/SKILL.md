---
name: build-jupyter-notebook
description: Convert a Python (.py) file to a Jupyter Notebook (.ipynb). Use when the user says "convert to notebook", "make a jupyter notebook", "py to ipynb", or provides a .py file and wants a .ipynb output.
model: haiku
argument-hint: <input.py> [output.ipynb]
allowed-tools:
  - Bash(python:*)
  - Bash(python3:*)
---

# /build-jupyter-notebook — Convert .py to .ipynb

Convert a Python script to a Jupyter Notebook using the project's `py_to_ipynb.py` converter.

**Arguments:** `$ARGUMENTS`

---

## Steps

1. Parse `$ARGUMENTS` to extract `<input.py>` and optional `[output.ipynb]`.
2. If no input file is provided, tell the user the usage and stop:
   ```
   Usage: /build-jupyter-notebook <input.py> [output.ipynb]
   ```
3. Resolve the input path. If it doesn't exist, report the error and stop.
4. Run the converter:
   ```bash
   python3 $CLAUDE_PROJECT_DIR/.claude/skills/build-jupyter-notebook/py_to_ipynb.py <input.py> [output.ipynb]
   ```
5. Report the output path and number of cells created.
