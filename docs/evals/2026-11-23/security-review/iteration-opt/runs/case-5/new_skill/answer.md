**What I'd do, in order:**

1. TodoWrite: `Map attack surface` → `Trace sources to sinks` → `Check every class` → `Verify controls` → `Write report`.
2. Analyse the pasted snippet only. I wouldn't run any commands or spawn subagents. Assumptions: the snippet is in `app.py` lines 1–4 (`app.py:4` is the `open(...)` line). There's no auth decorator or `before_request` hook that I can't see. The process can read files outside `/var/exports`.
3. Write `./.claude-skills-work/security-review/export-handler/findings.md` containing the report below.
4. Reply with the report.

---

## Security Review: `/export` handler (app.py:1-4)

The handler has an unauthenticated arbitrary file read (path traversal). It's critical and the first thing to fix.

### 🔴 Critical
1. **Path traversal → arbitrary file read** (app.py:4)
   - Exploit: the `file` query parameter is attacker-controlled and goes straight into `open()`. `GET /export?file=../../etc/passwd` resolves to `/var/exports/../../etc/passwd`, so the route reads files outside the exports directory. Nothing removes `..`, resolves the real path or checks that it stays inside `/var/exports`.
   - Impact: the attacker can read any file the app process can read:
     - the app's source code and config files
     - `.env` files
     - `/proc/self/environ`, which holds environment variables such as `SECRET_KEY`, database credentials and cloud API keys
     - SSH keys

     A leaked Flask `SECRET_KEY` lets them forge session cookies, which escalates to auth bypass. Reading `../../dev/zero` with `.read()` exhausts memory (denial of service).
   - Fix: don't build paths from user input. Map an export ID to a filename on the server, or at least use `send_from_directory('/var/exports', name, as_attachment=True)`. It confines the path to the base directory with Werkzeug's `safe_join` and returns 404 if the path escapes. If you keep `open()`, resolve the path with `os.path.realpath` and reject it unless it starts with `/var/exports/`.

### 🟠 High
2. **Authorization: no auth, no per-resource check (IDOR)** (app.py:1-2)
   - Exploit: there's no `@login_required` or ownership check. Even with traversal fixed, any anonymous user who guesses or enumerates names (`?file=report-2026-11.csv`, `?file=user_42.csv`) can download other users' exports.
   - Impact: exposure of whatever data the exports contain, which is often bulk PII or business data.
   - Fix: require authentication, then check that the current user owns the requested export, ideally by looking up an export record by ID with an owner filter. Use random, unguessable export names.

### 🟡 Medium
3. **XSS via served file content** (app.py:4)
   - Exploit: Flask serves a returned `str` as `text/html`. If an export contains user-supplied data (for example a CSV cell holding `<script>`), or traversal reaches a file the attacker controls (such as an upload), the browser renders it as HTML on your origin.
   - Impact: stored XSS, which allows session riding and data theft in the victim's session.
   - Fix: `send_from_directory(..., as_attachment=True)` with the correct mimetype, plus `X-Content-Type-Options: nosniff`.

### 🟢 Low
4. **Missing input validation / error leakage** (app.py:3-4)
   - Exploit: with no `file` parameter, `name` is `None`, so `'/var/exports/' + None` raises `TypeError`. A non-existent or binary file raises `FileNotFoundError` or `UnicodeDecodeError`. All of these return a 500. Error differences also let an attacker check whether a file exists.
   - Impact: if `debug=True` in production, the request shows a Werkzeug traceback with an interactive debugger, and the debugger console can run code. Otherwise the impact is noisy 500s and file-existence probing.
   - Fix: `abort(400)` when `file` is missing or invalid, ensure `debug=False` in production, and handle errors with generic 404/400 responses. Also, `open()` without `with` leaks file handles.

### Checked, no issue in this snippet
- Injection (SQL, shell or template), secrets, crypto, SSRF, deserialization, open redirect: no matching sink here.
- CSRF: not applicable, since it's a read-only GET.

### ✅ Controls verified
- None. The handler has no input validation, path confinement, authentication or authorization.

---

**Minimal remediated shape (for the author to adapt):**
```python
from flask import abort, send_from_directory
from flask_login import login_required, current_user

@app.route('/export')
@login_required
def export():
    export_id = request.args.get('id', type=int)
    exp = Export.query.filter_by(id=export_id, owner_id=current_user.id).first_or_404()
    return send_from_directory('/var/exports', exp.filename, as_attachment=True)
```