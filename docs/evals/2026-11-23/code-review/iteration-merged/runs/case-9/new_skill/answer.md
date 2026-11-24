**What I'd do, in order**

1. TodoWrite items: Context → Check every dimension → Rate & order → Report.
2. Context: the snippet is all I have. I'd read the rest of the Flask app for `before_request` auth hooks, `login_required`, `DEBUG`, and how files get into `/var/exports`. **Assumptions:** no global auth hook, the files are per-user exports, and the app runs with access to its own config and environment. Line numbers below count within the snippet, as `export:N`, because no file path was given.
3. Write the report below to `./.claude-skills-work/code-review/export-handler/findings.md`.
4. No subagents and no commands. It's a single 4-line handler.

**Reply:**

## Code Review: `/export` handler

### 🔴 Must fix
1. **Path traversal** (export:3→4): `file` goes straight from the query string into `open()` with no canonicalization or confinement.
   - **Exploit:** `GET /export?file=../../../etc/passwd` opens `/var/exports/../../../etc/passwd`. The same works for `../../proc/self/environ` and for the app's own config or `.env`.
   - **Impact:** an attacker can read any file the app user can read. That includes secrets such as `SECRET_KEY` (enough to forge sessions), DB credentials and SSH keys.
   - **Fix:** use `send_from_directory(EXPORT_DIR, filename)`. It uses `safe_join` and returns 404 for anything outside the directory. If you keep `open()`, resolve with `os.path.realpath` and reject anything where `os.path.commonpath([resolved, EXPORT_DIR]) != EXPORT_DIR`. Don't switch to `os.path.join` alone: an absolute `file=/etc/passwd` makes it discard the base directory.
2. **Missing authentication and per-resource authorization (IDOR)** (export:1–2): no auth decorator, and no check that the caller owns the export.
   - **Exploit:** an unauthenticated user requests `?file=<other_user>_report.csv`. Export names are often guessable (ids, dates).
   - **Impact:** anyone can read any user's exports.
   - **Fix:** add `@login_required`. Map the request to an export record the caller owns, ideally `?id=<export_id>` looked up with `owner_id == current_user.id`, and serve that record's stored filename. Never use a client-supplied path.

### 🟡 Should fix
1. **Reflected/stored XSS via content type** (export:4): returning a `str` makes Flask serve it as `text/html` on your origin.
   - **Exploit:** an export containing user-controlled data (e.g. a name field set to `<script>…`) runs that script in the viewer's session.
   - **Fix:** `send_from_directory(..., as_attachment=True)`. It sets the MIME type from the file extension and adds `Content-Disposition: attachment`.
2. **Unhandled errors return 500** (export:3–4):
   - A missing `file` makes `None` reach the string concatenation, raising `TypeError`.
   - A nonexistent file raises `FileNotFoundError`.
   - A NUL byte raises `ValueError`.
   - With debug on, the traceback leaks server paths.
   - **Fix:** `abort(400)` when the parameter is missing, and 404 for a missing file (`send_from_directory` handles that).
3. **Leaked file handle** (export:4): the `open()` is never closed. **Fix:** a `with` block, or `send_from_directory`.
4. **Text-mode read of the whole file** (export:4): binary exports (xlsx, zip) fail with `UnicodeDecodeError` or come out corrupted. Large files are loaded fully into memory. **Fix:** `send_from_directory` / `send_file`, which streams in binary.

### 🟢 Consider
1. **Hardcoded base dir** (export:4): move `'/var/exports/'` to `app.config['EXPORT_DIR']`.
2. **Naming** (export:3): `name` → `filename`.
3. **Tests:** none shown. Add tests for:
   - a valid owned file (200, attachment header)
   - a missing param (400)
   - `../` and `%2e%2e%2f` traversal (404)
   - an absolute path (404)
   - another user's file (403/404)
   - a nonexistent file (404)

Suggested shape (the author decides):
```python
@app.route('/export')
@login_required
def export():
    export_id = request.args.get('id', type=int) or abort(400)
    record = Export.query.filter_by(id=export_id, owner_id=current_user.id).first_or_404()
    return send_from_directory(app.config['EXPORT_DIR'], record.filename, as_attachment=True)
```

### ✅ Good
- A fixed base directory shows the intent to scope reads. It just isn't enforced yet.
- It's a read-only GET with no side effects, so CSRF doesn't apply.