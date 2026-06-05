"""WSGI entry point for gunicorn/uWSGI: `gunicorn --chdir protected wsgi:app`.

Importing this stub self-activates the obfy loader, which then serves the
encrypted `app` package — so the protected tree works with a string target.
"""

from app import app

__all__ = ["app"]
