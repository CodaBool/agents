---
name: playwright-browser
description: browser automation CLI. Chrome via CDP with compact element refs.
---

# Efficient browser automation with Playwright CLI

## Environment & Daemon Mechanics (Critical)

- **Operating system:** Windows with PowerShell.
- **Browser:** User-managed portable Chromium, already launched with remote debugging on `127.0.0.1:9222` and a separate persistent profile.
- **Tool:** invoke as `playwright-cli`.
- **Workspace Hashing (CWD Isolation):** `playwright-cli` scopes its background daemon to the current working directory via `%LOCALAPPDATA%\ms-playwright\daemon\<workspace-hash>\`. **Always execute `playwright-cli` from the exact same workspace root directory.** Changing directories across subshells spawns isolated daemons that cannot see existing sessions and results in `"The browser 'local' is not open"` errors.
- **Persistent Session Naming:** Always pass `-s=local`. Running commands without `-s=local` defaults to an isolated in-memory headless browser (`default`).
- **Attach only; never launch:** Attach to the existing browser on port `9222`. **Never run `playwright-cli open`** and never launch a new browser or alter its profile.

## Zero-Failure Startup & Teardown

1. **Stay in the repository root** for all commands.
2. **Fast-path session check & attach:**
   - Do not waste calls guessing whether a session is alive. Run `playwright-cli -s=local tab-list`.
   - If `local` is not open or disconnected, attach immediately:
     ```
     playwright-cli -s=local attach --cdp=http://127.0.0.1:9222
     ```
   - *Note:* `attach` automatically outputs the active Page URL, Page Title, and initial state. Do not immediately run a redundant full snapshot if `attach` already gave you the context you need.
3. **Zero-Indexed Tabs (`0`, `1`, `2`...):**
   - Tabs are **0-indexed**. Never assume `tab-select 1` is the first tab or exists without checking.
   - Always inspect `playwright-cli -s=local tab-list` before calling `tab-select <index>`. Requesting an out-of-bounds tab index or selecting a tab that crashed can drop the CDP handle.
4. **Handling Debugger/Error Pages & CDP Drops:**
   - If a target tab hits a backend exception (e.g., Werkzeug/Jinja debugger) or reloads abruptly, the daemon may drop the CDP connection and report `"The browser 'local' is not open"`.
   - **Recovery:** Do **not** run `playwright-cli open`. Simply re-run `playwright-cli -s=local attach --cdp=http://127.0.0.1:9222` from the workspace root to re-bind the session.
5. **Finish & Teardown:**
   - **Leave the `-s=local` session attached** across tasks so subsequent terminals/agents in the same workspace root can reuse it directly without re-attaching.
   - Only run `playwright-cli -s=local detach` if explicitly asked to disconnect the daemon.
   - **Never run `close`, `close-all`, `kill-all`, or `delete-data` on the user's browser.**
   - If `127.0.0.1:9222` is unreachable (`Invoke-RestMethod http://127.0.0.1:9222/json/version` fails), stop and report the error. Never silently launch a fallback browser.

## Operating strategy: minimize tokens and calls

1. **Zero speculative commands:** Verify working directory, session name (`-s=local`), and tab index (`tab-list`) so every command succeeds on the first try.
2. **Use the smallest useful output:** Pass `--raw` whenever you only need a return value, omitting CLI wrapper text and automatic post-action snapshots.
3. **Inspect only what is needed:** Start with `snapshot --depth=3`, `find "target text"`, or `snapshot "#specific-section"`, not a full-page dump.
4. **Prefer one small extraction over many observations:** For read-only analysis, use `--raw eval` to return a compact JSON object containing only the required fields.
5. **Use refs from current snapshots** for interactions (`click e5`, `fill e8 "value"`). Prefer stable role/test-id selectors when appropriate. Avoid brittle positional selectors and coordinates.
6. **Do not re-snapshot after every action:** `attach`, `goto`, and interaction commands already report page state unless `--raw` is used. Get a new focused snapshot only when the relevant DOM structure changed, a ref is stale, or a result needs verification.
7. **Do not read or print entire pages by default:** Avoid full `document.body.innerText`, huge DOM trees, full network logs, giant JSON payloads, and repeated screenshots.
8. **Use screenshots only for visual tasks:** Layout, appearance, canvas, graphical controls, or debugging a genuinely visual problem.
9. **Stop once success is verified:** Report the outcome and any blockers briefly.

## Common commands

```powershell
# 1. Verify open tabs (also confirms 'local' session is active in current CWD)
playwright-cli -s=local tab-list

# 2. Attach only if 'local' session is not open or CDP dropped
playwright-cli -s=local attach --cdp=http://127.0.0.1:9222

# 3. Select a verified 0-indexed tab
playwright-cli -s=local tab-select 0

# 4. Navigate and inspect only the relevant region
playwright-cli -s=local goto https://example.com
playwright-cli -s=local snapshot --depth=3
playwright-cli -s=local find "Settings"
playwright-cli -s=local snapshot "main"

# 5. Interact with element refs obtained from current state
playwright-cli -s=local click e5
playwright-cli -s=local fill e8 "Example value"
playwright-cli -s=local press Enter

# 6. Return a small piece of page data without wrapper text or auto-snapshots
playwright-cli -s=local --raw eval "({title: document.title, url: location.href})"
playwright-cli -s=local --raw eval "[...document.querySelectorAll('main h2')].slice(0,10).map(e => e.textContent.trim())"

# 7. Check a result, taking a screenshot only if appearance matters
playwright-cli -s=local find "Saved successfully"
playwright-cli -s=local screenshot --filename=verification.png
