#!/usr/bin/env python3
"""
Python (.py) to Jupyter Notebook (.ipynb) Converter

Converts a Python script into a Jupyter notebook with intelligent cell splitting.

Usage:
    python py_to_ipynb.py input.py [output.ipynb]
    python py_to_ipynb.py input.py  # outputs input.ipynb
"""

import json
import re
import sys
from pathlib import Path


def create_notebook(cells):
    """Create a proper .ipynb JSON structure."""
    return {
        "cells": cells,
        "metadata": {
            "kernelspec": {
                "display_name": "Python 3",
                "language": "python",
                "name": "python3"
            },
            "language_info": {
                "name": "python",
                "version": "3.8.0",
                "mimetype": "text/x-python",
                "codemirror_mode": {"name": "ipython", "version": 3},
                "pygments_lexer": "ipython3",
                "nbconvert_exporter": "python",
                "file_extension": ".py"
            }
        },
        "nbformat": 4,
        "nbformat_minor": 4
    }


def create_code_cell(source):
    """Create a code cell dictionary."""
    return {
        "cell_type": "code",
        "execution_count": None,
        "metadata": {},
        "outputs": [],
        "source": source
    }


def create_markdown_cell(source):
    """Create a markdown cell dictionary."""
    return {
        "cell_type": "markdown",
        "metadata": {},
        "source": source
    }


def parse_py_to_cells(source_code):
    """
    Parse Python source code into notebook cells.

    Strategy:
    1. Look for explicit cell markers: # %% [markdown] or # %%
    2. If no markers, split by logical blocks (imports, functions, classes, etc.)
    """
    lines = source_code.splitlines(keepends=True)

    # Check if explicit markers exist
    has_explicit_markers = any(
        re.match(r'^\s*#\s*%%', line.strip()) for line in lines
    )

    if has_explicit_markers:
        return parse_with_markers(lines)
    else:
        return split_by_logical_blocks(source_code)


def parse_with_markers(lines):
    """Parse using explicit # %% cell markers."""
    cells = []
    current_cell_lines = []
    current_cell_type = "code"

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Check for markdown cell marker: # %% [markdown]
        markdown_match = re.match(r'^\s*#\s*%%\s*\[markdown\]\s*$', stripped, re.IGNORECASE)
        # Check for code cell marker: # %%
        code_match = re.match(r'^\s*#\s*%%\s*$', stripped)

        if markdown_match or code_match:
            # Save previous cell if exists
            if current_cell_lines:
                cell_content = ''.join(current_cell_lines).rstrip('\n') + '\n'
                if current_cell_type == "code":
                    cells.append(create_code_cell(cell_content))
                else:
                    cells.append(create_markdown_cell(cell_content))
                current_cell_lines = []

            # Set new cell type
            current_cell_type = "markdown" if markdown_match else "code"
            i += 1
            continue

        current_cell_lines.append(line)
        i += 1

    # Save last cell
    if current_cell_lines:
        cell_content = ''.join(current_cell_lines).rstrip('\n') + '\n'
        if current_cell_type == "code":
            cells.append(create_code_cell(cell_content))
        else:
            cells.append(create_markdown_cell(cell_content))

    return cells


def split_by_logical_blocks(source_code):
    """
    Split code into logical blocks when no explicit markers exist.

    Groups:
    - All imports together
    - Each function/class definition as one cell
    - Global code blocks together
    - if __name__ == "__main__" as one cell
    """
    lines = source_code.splitlines(keepends=True)
    cells = []

    # Collect all lines into categorized blocks
    import_lines = []
    current_block = []
    blocks = []

    # Patterns
    import_pattern = re.compile(r'^(?:from\s+\w+|import\s+\w+)')
    def_class_pattern = re.compile(r'^(?:def\s+|class\s+)')
    decorator_pattern = re.compile(r'^@\w+')
    if_main_pattern = re.compile(r'^if\s+__name__\s*==\s*[\'"]__main__[\'"]\s*:\s*$')

    in_definition = False
    definition_indent = 0
    collecting_imports = False

    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped:
            if collecting_imports:
                import_lines.append(line)
            elif current_block:
                current_block.append(line)
            continue

        current_indent = len(line) - len(line.lstrip())

        # Handle imports - collect all consecutive imports
        if import_pattern.match(stripped) and current_indent == 0:
            if not collecting_imports and current_block:
                # Save previous block
                blocks.append(('code', current_block))
                current_block = []
            collecting_imports = True
            import_lines.append(line)
            continue
        elif collecting_imports and not import_pattern.match(stripped):
            # End of import section
            if import_lines:
                blocks.append(('import', import_lines))
                import_lines = []
            collecting_imports = False

        # Handle decorators and definitions
        if decorator_pattern.match(stripped) and current_indent == 0:
            # Start of decorated definition
            if current_block and not in_definition:
                blocks.append(('code', current_block))
                current_block = []
            in_definition = True
            definition_indent = current_indent
            current_block.append(line)
            continue

        if def_class_pattern.match(stripped) and current_indent == 0:
            # Start of function/class
            if current_block and not in_definition:
                blocks.append(('code', current_block))
                current_block = []
            in_definition = True
            definition_indent = current_indent
            current_block.append(line)
            continue

        # Check if definition ended
        if in_definition and current_indent <= definition_indent and stripped and i > 0:
            prev_line = lines[i-1].strip()
            # Definition ended if we hit a non-empty line at same or lower indent
            # that is not a continuation of the definition body
            if not (def_class_pattern.match(stripped) or decorator_pattern.match(stripped)):
                in_definition = False
                if current_block:
                    blocks.append(('def', current_block))
                    current_block = []

        # Handle if __name__ == "__main__"
        if if_main_pattern.match(stripped) and current_indent == 0:
            if current_block and not in_definition:
                blocks.append(('code', current_block))
                current_block = []
            in_definition = True
            definition_indent = current_indent
            current_block.append(line)
            continue

        current_block.append(line)

    # Save remaining
    if import_lines:
        blocks.append(('import', import_lines))
    if current_block:
        blocks.append(('code', current_block))

    # Convert blocks to cells
    for block_type, block_lines in blocks:
        cell_content = ''.join(block_lines).rstrip('\n') + '\n'
        cells.append(create_code_cell(cell_content))

    # If nothing was split, return whole thing as one cell
    if not cells:
        cells.append(create_code_cell(source_code + '\n'))

    return cells


def convert_file(input_path, output_path=None):
    """Convert a .py file to .ipynb."""
    input_path = Path(input_path)

    if not input_path.exists():
        raise FileNotFoundError(f"File not found: {input_path}")

    if input_path.suffix != '.py':
        raise ValueError(f"Expected .py file, got: {input_path.suffix}")

    if output_path is None:
        output_path = input_path.with_suffix('.ipynb')
    else:
        output_path = Path(output_path)

    # Read source
    with open(input_path, 'r', encoding='utf-8') as f:
        source_code = f.read()

    # Parse into cells
    cells = parse_py_to_cells(source_code)

    # Create notebook
    notebook = create_notebook(cells)

    # Write output
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(notebook, f, indent=2, ensure_ascii=False)

    print(f"Converted: {input_path} -> {output_path}")
    print(f"  Created {len(cells)} cell(s)")

    for idx, cell in enumerate(cells):
        cell_type = cell["cell_type"]
        source_preview = cell["source"].split('\n')[0][:50]
        print(f"  Cell {idx}: [{cell_type}] {source_preview}...")

    return output_path


def main():
    if len(sys.argv) < 2:
        print("Usage: python py_to_ipynb.py <input.py> [output.ipynb]")
        print("       python py_to_ipynb.py <input.py>  # outputs input.ipynb")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        convert_file(input_file, output_file)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
