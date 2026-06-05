"""Development entry point — Flask's built-in server.

For production, serve the WSGI app with gunicorn instead:
    gunicorn --chdir protected wsgi:app
"""

import os

from app import app


def main() -> None:
    app.run(
        host=os.environ.get("HOST", "127.0.0.1"),
        port=int(os.environ.get("PORT", "8000")),
    )


if __name__ == "__main__":
    main()
