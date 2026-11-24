**What I'd do, in order**

1. TodoWrite items: map attack surface → trace source→sink → check vuln classes → verify controls → report.
2. Read `skills/security-review/references/vuln-classes.md` (done).
3. Checkpoint findings as I go to `./.claude-skills-work/security-review/flask-export/findings.md`. It holds the same content as the report below.
4. Assumptions (you gave no file path, so line refs are snippet lines 1–4): no `@login_required`, no `before_request` auth hook, and the app runs as a normal service user.
5. No commands, subagents or code edits. The skill only reports; you fix.

---

**Final reply:**

## Security Review: Flask `/export` handler

The main problem is a 🔴 critical path traversal: any caller can read any file the app process can read. It's made worse because the route has no auth check.

**Attack surface:** one untrusted input, `request.args['file']`, which flows straight into `open()` at line 4. Nothing in between validates it.

### 🔴 Critical
1. **Path traversal / arbitrary file read** (snippet:4)
   - Exploit: `GET /export?file=../../etc/passwd`. The string concatenation keeps `../` segments, so the path leaves `/var/exports/`. An attacker can target the app's source code, `.env` and config files, `/proc/self/environ` (environment secrets), SSH keys and cloud credential files.
   - Impact: secrets and credentials get disclosed. That often leads to DB or cloud takeover, and leaked source helps find more bugs.
   - Fix: use `flask.send_from_directory("/var/exports", name)`, which uses `werkzeug.security.safe_join` and rejects traversal. Better still, don't take a filename at all: map an export ID to a server-side path.
   - If you must build the path yourself: `p = os.path.realpath(os.path.join(BASE, name))`, then reject the request unless `os.path.commonpath([p, BASE]) == BASE`.

### 🟠 High
2. **Missing authentication and authorization (IDOR)** (snippet:1–2)
   - Exploit: anyone, logged in or not, can request any file in `/var/exports/`. That includes other users' exports, whose names can be guessed or enumerated.
   - Impact: other users' exported data leaks. Exports are usually bulk PII or business data.
   - Fix: require authentication. Then check that the current user owns or may access *this* export, using a server-side ownership record. Never trust the filename alone.

### 🟡 Medium
3. **Stored XSS through the response content type** (snippet:4)
   - Exploit: Flask serves a returned `str` as `text/html`. If an export contains user-controlled content (for example a CSV with a `<script>` in a name field), a victim who opens the link runs that script on your app's origin.
   - Impact: session theft or actions taken as the victim.
   - Fix: use `send_file(..., mimetype="text/csv", as_attachment=True)` (or the right type) and set `X-Content-Type-Options: nosniff`.
4. **Unhandled errors and info leakage** (snippet:3–4)
   - Exploit: a missing `file` param makes `'/var/exports/' + None` raise `TypeError`. Bad names raise `FileNotFoundError`, `IsADirectoryError` or `PermissionError`, and a `\x00` raises `ValueError`. All of these return 500s.
   - Impact: different errors let an attacker tell whether a file exists. If `debug=True` ever reaches production, the Werkzeug debugger shows stack traces, and its console is a route to RCE.
   - Fix: validate that `file` is present and matches a strict pattern (e.g. `^[A-Za-z0-9_-]+\.csv$`), return a generic 404, and make sure debug is off in production.

### 🟢 Low
5. **Resource exhaustion** (snippet:4)
   - Exploit: `.read()` loads the whole file into memory. With traversal, `../../dev/zero` reads forever. Even after the traversal fix, repeated requests for large exports use a lot of memory. The file handle is also never closed (no `with`).
   - Impact: denial of service for the worker.
   - Fix: stream with `send_file` / `send_from_directory`, which also handles closing the file, and rate-limit the endpoint.

### ✅ Controls verified
- Because the prefix is joined with `+` rather than `os.path.join`, an absolute input like `/etc/passwd` becomes `/var/exports//etc/passwd` and doesn't escape the directory. This is incidental, not a real control, and `../` still gets through.
- There's no SQL, shell, deserialization or outbound-HTTP sink, so injection, deserialization and SSRF don't apply. The route is a read-only GET, so CSRF doesn't apply.

**Suggested shape of the fix:**
```python
@app.route('/export/<int:export_id>')
@login_required
def export(export_id):
    exp = Export.query.filter_by(id=export_id, owner_id=current_user.id).first_or_404()
    return send_from_directory('/var/exports', exp.filename,
                               mimetype='text/csv', as_attachment=True)
```