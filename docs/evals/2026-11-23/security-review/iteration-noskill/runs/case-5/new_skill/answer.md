## Actions

1. **TodoWrite:** attack surface → trace → check all 12 classes → verify controls → report.
2. **No commands.** The code was pasted inline, so I cite lines as `export:N`, where line 1 is `@app.route`. I assume this is the complete handler: no `before_request` auth hook, no auth decorator, and default Flask config.
3. **Write** `./.claude-skills-work/security-review/export/findings.md` containing the report below.
4. **No subagents.** The target is four lines.

## Security Review: `/export` handler

**Attack surface:** the `file` query parameter (untrusted), the contents of files under `/var/exports` (possibly user-influenced, so also untrusted), and an unauthenticated route.
**Trace:** `request.args['file']` (line 3) is concatenated into the path and passed to `open()` (line 4), then the file content goes straight into the HTTP response with Flask's default `text/html` type. Nothing sanitizes it along the way.

### 🔴 Critical
1. **Path traversal / arbitrary file read** (`export:3-4`)
   - Exploit: `GET /export?file=../../etc/passwd` builds `/var/exports/../../etc/passwd`. The same works for `../../proc/self/environ`, the app's source and config, `~/.ssh/*` and cloud credential files.
   - Impact: the attacker can read any file the app's user can read. Leaking `SECRET_KEY` from env or config lets them forge Flask sessions, which means auth bypass. Leaked DB or cloud keys extend to full compromise. `../../dev/zero` exhausts memory, which is a DoS.
   - Fix: serve with `send_from_directory(EXPORT_DIR, name)`, which uses `safe_join` and rejects `..` and absolute paths. Alternatively, resolve with `os.path.realpath` and require the result to stay under `EXPORT_DIR`. Better still, take an export ID and look up the server-side filename.

### 🟠 High
2. **Missing authentication and authorization (IDOR)** (`export:1-2`)
   - Exploit: with no login check and no ownership check, anyone can request `?file=<another user's export>`. Export names are often guessable, such as `report_123.csv` or a date.
   - Impact: any user's exported data can be read, and it likely includes PII or business data.
   - Fix: add `@login_required` and check the current user against the export's owner, returning 404 when it isn't theirs.

### 🟡 Medium
3. **XSS via served content** (`export:4`)
   - Exploit: returning a `str` makes Flask send `Content-Type: text/html`. If an export contains user-controlled data, such as a CSV cell holding `<script>`, the browser renders it on the app's origin.
   - Impact: stored XSS, which allows session or action hijacking. Combined with finding 1, any HTML-like file the attacker can reach also renders as HTML.
   - Fix: `send_from_directory(..., as_attachment=True, mimetype='text/csv')` (or the correct type), plus `X-Content-Type-Options: nosniff`.

### 🟢 Low
4. **Unhandled missing parameter / error leakage** (`export:3-4`)
   - Exploit: with no `file` parameter, `'/var/exports/' + None` raises `TypeError`, and a nonexistent file raises `FileNotFoundError`. Both return a 500. With `debug=True`, the response includes a stack trace and the Werkzeug debugger, which can lead to RCE.
   - Impact: information disclosure, and RCE if debug mode is on in production.
   - Fix: validate the parameter and `abort(400/404)`, and make sure `debug=False` in production.
5. **Resource handling** (`export:4`)
   - Exploit: the file is never closed, and the whole file is read into memory. Repeated requests for large exports exhaust file descriptors or RAM.
   - Impact: DoS.
   - Fix: `send_from_directory` streams the file and closes it. Also rate-limit the endpoint.

### Suggested fix (the author applies it)
```python
EXPORT_DIR = '/var/exports'

@app.route('/export')
@login_required
def export():
    export_id = request.args.get('id', type=int)
    exp = Export.query.filter_by(id=export_id, owner_id=current_user.id).first_or_404()
    return send_from_directory(EXPORT_DIR, exp.filename,
                               as_attachment=True, mimetype='text/csv')
```

### ✅ Controls verified
- None present in the handler. The remaining classes don't apply to this code: there is no SQL, NoSQL, shell or template injection sink, no SSRF, no deserialization, no hardcoded secrets or crypto, no redirect, and no CSRF risk because the GET is read-only.
- In Python 3, null-byte truncation is blocked (`open()` raises `ValueError`), but traversal still works.
- Unverified: global auth hooks (`before_request`), the `DEBUG` setting, and security headers. Confirm these in the app config.

## Final reply
The handler has a 🔴 critical path traversal: `?file=../../etc/passwd` reads any file the app can read, including secrets like `SECRET_KEY`, which then allows session forgery. It also has no authentication or ownership check (🟠 IDOR), serves files as `text/html` (🟡 XSS), crashes with a 500 when the parameter is missing (debug mode would make that RCE), and leaks file handles. The fix is to require login, take an export ID instead of a filename, check that the user owns it, and serve it with `send_from_directory(..., as_attachment=True)`. The full report is in `.claude-skills-work/security-review/export/findings.md`.