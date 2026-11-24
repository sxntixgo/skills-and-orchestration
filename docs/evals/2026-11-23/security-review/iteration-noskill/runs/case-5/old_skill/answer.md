**Critical: path traversal lets anyone read any file the app process can read.** `/export?file=../../etc/passwd` resolves to `/var/exports/../../etc/passwd` and returns it. The same trick reaches app source, `.env` files, SSH keys and cloud credentials.

## Findings

| # | Severity | Issue |
|---|----------|-------|
| 1 | **Critical** | **Path traversal.** `name` is joined to the directory with no checks. `../` sequences, including URL-encoded `%2e%2e%2f`, escape `/var/exports/`. |
| 2 | **High** | **No authentication or authorization.** Anyone can call the endpoint, and nothing checks that the caller owns the export. Even after fixing #1, any user can read any other user's exports by guessing file names (IDOR). |
| 3 | **Medium** | **Memory-exhaustion DoS.** `.read()` loads the whole file into memory. `?file=../../dev/zero` (via #1) or a very large export can kill the worker. |
| 4 | **Medium** | **Stored XSS.** A plain string return is served as `text/html`. If an export contains attacker-influenced content, it runs as script on your origin. |
| 5 | Low | **Unhandled errors.** A missing `file` param gives `None` and a `TypeError`. A missing file gives `FileNotFoundError`, null bytes give `ValueError`, and binary files give `UnicodeDecodeError`. All return 500s, and with `debug=True` they leak paths and code. They also let an attacker probe which files exist. |
| 6 | Low | **File handle leak.** `open()` is never closed. |
| 7 | Low | **Symlinks.** Any symlink inside `/var/exports` that points outside it is followed. |

## Fixed version

```python
import re
from flask import abort, send_from_directory
from flask_login import login_required, current_user  # or your auth mechanism

EXPORT_DIR = '/var/exports'
SAFE_NAME = re.compile(r'^[A-Za-z0-9_-]{1,64}\.(csv|json|xlsx)$')

@app.route('/export')
@login_required
def export():
    name = request.args.get('file', '')
    if not SAFE_NAME.fullmatch(name):
        abort(400)
    if not user_owns_export(current_user, name):  # your ownership check
        abort(404)
    # safe_join rejects traversal; streams the file; sets the Content-Type from the extension
    return send_from_directory(EXPORT_DIR, name, as_attachment=True)
```

What each part fixes:
- **Allowlist regex**: blocks `/`, `..`, null bytes and unexpected file types (#1, #5).
- **`send_from_directory`**: a second traversal guard via `safe_join`. It streams the file instead of reading it into memory, closes the handle and handles binary files (#1, #3, #5, #6).
- **`as_attachment=True`**: the browser downloads the file instead of rendering it, which removes the XSS risk (#4).
- **Auth and ownership check**: fixes #2. A better design is to look exports up by an opaque ID in the database (`/export/<uuid>`) and never accept a file name from the user.
- **Symlinks (#7)**: run the app as a low-privilege user that can't read secrets, and keep untrusted symlinks out of `/var/exports`.