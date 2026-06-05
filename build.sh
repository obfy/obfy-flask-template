#!/usr/bin/env bash
#
# Protect the Flask app in ./src into a drop-in mirror at ./protected.
# Run it with:  python protected/run.py     (dev)
#           or:  gunicorn --chdir protected wsgi:app   (prod)
#
# Use the SAME Python you deploy with — obfy's marshal/bytecode format is
# interpreter-version specific.
set -euo pipefail

PYTHON="${PYTHON:-python3}"

rm -rf protected

# --level 3 stops BELOW cross-module public-name renaming on purpose: Flask
#   derives endpoint names (used by url_for) from view-function names, and the
#   gunicorn target `wsgi:app` references the `app` name — both are PUBLIC names
#   that must survive. Level 3 still strips docstrings, mangles string literals,
#   injects dead code, and renames function-local variables.
obfy build --src ./src --out ./protected --python "$PYTHON" --level 3

echo
echo "Done. Serve it with:  python protected/run.py"
