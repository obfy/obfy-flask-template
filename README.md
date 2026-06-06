# obfy + Flask template

A minimal Flask service wired to ship with its source **obfuscated and
AES-256-GCM encrypted** by [obfy](https://github.com/obfy/obfy). `obfy build`
turns `./src` into a drop-in protected mirror (`./protected`) that you serve
exactly like the original.

```
src/run.py + wsgi.py + app/  ──► obfy build ──► protected/  ──► python protected/run.py
        (your code)                             (encrypted)      (or gunicorn wsgi:app)
```

## Layout

| Path | What it is |
|------|------------|
| `src/run.py` | Dev entry point — Flask's built-in server. |
| `src/wsgi.py` | WSGI entry point for gunicorn (`wsgi:app`). |
| `src/app/__init__.py` | The Flask `app` + routes. |
| `src/app/services.py` | The **protected business logic**. |
| `build.sh` | Runs `obfy build` with Flask-safe flags. |
| `Pipfile` | Deps (`flask`, `gunicorn`, plus `obfy` as a build tool). |
| `protected/` | Generated protected mirror (git-ignored). |

## Prerequisites

- **CPython 3.10–3.13.** Build with the **same Python version** you deploy with —
  obfy's marshalled bytecode is interpreter-version specific.
- macOS, Linux, or Windows.

## Setup

This template uses [pipenv](https://pipenv.pypa.io/) (the `Pipfile` pins
`python_version = "3.12"`):

```bash
pip install --user pipenv          # if you don't have it
pipenv install
```

Prefer plain venv + pip? `python3 -m venv .venv && source .venv/bin/activate &&
pip install flask gunicorn obfy`.

## Develop (unprotected)

Iterate on the real source:

```bash
pipenv run dev                     # == python src/run.py
# -> http://127.0.0.1:8000/quote?units=10
```

## Build the protected tree

```bash
pipenv run build                   # == bash build.sh
```

Then run the **protected** mirror — same app, different directory:

```bash
pipenv run serve                   # == python protected/run.py
```

`./protected` is a 1:1 mirror of `./src`: each `.py` becomes a tiny
self-activating stub, the real code lives encrypted under `protected/__obfy__/`,
and obfy's native loader is bundled in. Decryption happens in memory at import
time; plaintext source never lands on disk.

## Obfy level

`obfy build` takes `--level 0–5`, a sophistication dial where each level does
strictly more — `1` strips docstrings, `2` adds string mangling + dead code, `3`
adds function-local renames, `4` adds cross-module public-name renames, and `5`
adds native function compilation (eligible functions are lowered to obfy's own
bytecode VM, so their CPython bytecode never ships). Reference:
[obfuscation levels](https://docs.camouflage.network/obfy/guides/obfuscation-levels).

**This template builds at `--level 3`.** Two kinds of **public names** must survive
obfuscation (which is why the build stops below cross-module public-name renaming):

- **View-function names.** Flask derives each route's *endpoint* from its view
  function name, and `url_for("quote")` looks it up by that string. Renaming the
  function would break `url_for`.
- **The `app` name.** The gunicorn target `wsgi:app` references `app` by name.
  Importing the `wsgi.py` stub self-activates the obfy loader, so the protected
  tree works with that string target — but the `app` symbol itself must keep its
  name.

Level 3 still strips docstrings, mangles string literals, injects dead code, and
renames function-local variables. Have a pure-logic module with no Flask coupling
(no endpoint/`url_for` names)? Split it into its own package and protect *that* at
a higher level separately.

## Deploying

Serve `./protected` with gunicorn:

```bash
gunicorn --chdir protected wsgi:app
```

For Docker, build `./protected` in a build stage and `COPY` it into the image
instead of your source. See
[packaging](https://docs.camouflage.network/obfy/guides/packaging) and
[deploying](https://docs.camouflage.network/obfy/deploying).

## Honest posture

Python obfuscation is **deterrence, not encryption-grade security** — CPython must
eventually execute real bytecode. obfy stops casual copying and raises the cost for
everyone else; it does not replace legal protection for sensitive IP. See the
[honest posture](https://docs.camouflage.network/obfy/guides/obfuscation-levels#honest-posture).

## Docs

Full obfy documentation: **[docs.camouflage.network/obfy](https://docs.camouflage.network/obfy/introduction)**.

## License

MIT — see [LICENSE](./LICENSE). The code you build with this template is yours.
