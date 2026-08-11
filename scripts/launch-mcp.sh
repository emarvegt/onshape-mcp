#!/usr/bin/env bash
# Validate the local development environment before starting the MCP server.

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
venv_python="$project_root/venv/bin/python"
requirements_file="$project_root/requirements.txt"

if [[ ! -x "$venv_python" ]]; then
    echo "Onshape MCP was not started: no usable virtual environment was found." >&2
    echo "Create it with: python3 -m venv venv" >&2
    exit 1
fi

if ! "$venv_python" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
    echo "Onshape MCP was not started: venv/bin/python must be Python 3.10 or newer." >&2
    exit 1
fi

if [[ ! -f "$requirements_file" ]]; then
    echo "Onshape MCP was not started: requirements.txt was not found." >&2
    exit 1
fi

if ! "$venv_python" -m pip install --dry-run --no-index -r "$requirements_file" >/dev/null; then
    echo "Onshape MCP was not started: dependencies from requirements.txt are missing." >&2
    echo "Install them with: venv/bin/python -m pip install -r requirements.txt" >&2
    exit 1
fi

if ! "$venv_python" -m pip check >/dev/null; then
    echo "Onshape MCP was not started: installed Python dependencies are inconsistent." >&2
    exit 1
fi

if [[ "${1:-}" == "--check" ]]; then
    echo "Onshape MCP prerequisites are ready."
    exit 0
fi

cd "$project_root"
exec "$venv_python" -m onshape_mcp.server
