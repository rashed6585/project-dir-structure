#!/usr/bin/env python3

import json
import logging
import sys
import subprocess
from pathlib import Path

# Logging setup - log file next to this script
root_dir = Path(__file__).resolve().parents[3]
log_dir = root_dir / "logs"
log_dir.mkdir(parents=True, exist_ok=True)
LOG_FILE = log_dir / "ts_lint.log"

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.FileHandler(LOG_FILE, mode="a")],
)
logger = logging.getLogger(__name__)


def main():
    try:
        # Read input data from stdin
        input_data = json.load(sys.stdin)

        tool_input = input_data.get("tool_input", {})
        logger.debug(f"tool_input: {tool_input}")

        # Get file path from tool input
        file_path = tool_input.get("file_path")
        if not file_path:
            sys.exit(0)

        # Only check TypeScript/JavaScript files
        if not file_path.endswith((".ts", ".tsx", ".js", ".jsx")):
            sys.exit(0)

        # Check if file exists
        if not Path(file_path).exists():
            sys.exit(0)

        # Run ESLint to check for errors and style violations
        try:
            result = subprocess.run(
                ["npx", "eslint", file_path],
                capture_output=True,
                text=True,
                timeout=30,
            )

            if result.returncode != 0 and (result.stdout or result.stderr):
                # Log the error for debugging
                # Ensure log directory exists
                root_dir = Path(__file__).resolve().parents[3]
                log_dir = root_dir / "logs"
                log_dir.mkdir(parents=True, exist_ok=True)
                log_file = log_dir / "eslint_errors.json"
                error_output = result.stdout or result.stderr
                error_entry = {
                    "file_path": file_path,
                    "errors": error_output,
                    "session_id": input_data.get("session_id"),
                }

                # Load existing errors or create new list
                if log_file.exists():
                    with open(log_file) as f:
                        errors = json.load(f)
                else:
                    errors = []

                errors.append(error_entry)

                # Save errors
                with open(log_file, "w") as f:
                    json.dump(errors, f, indent=2)

                # Send error message to stderr for LLM to see
                print(f"ESLint errors found in {file_path}:", file=sys.stderr)
                print(error_output, file=sys.stderr)

                # Exit with code 2 to signal LLM to correct
                sys.exit(2)

        except subprocess.TimeoutExpired:
            print("ESLint check timed out", file=sys.stderr)
            sys.exit(0)
        except FileNotFoundError:
            # ESLint not available, skip check
            sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Error parsing JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error in eslint hook: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
