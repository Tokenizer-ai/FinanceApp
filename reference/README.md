# Reference scripts

Preserved artifacts, kept here so they are recoverable independently of the machine they run on.

| File | Purpose |
|---|---|
| `launcher-v1.1.sh` | The macOS Dock launcher. Installs to `/Applications/FinanceApp.app/Contents/MacOS/launcher`. After replacing it, run `xattr -cr /Applications/FinanceApp.app` and right-click → Open → Open once, or the icon will silently do nothing (`FA-BUG-005`) |
| `health-check.sh` | Read-only diagnostic covering runtime, schema state, the integer-cents invariant, snapshot coverage, recent syncs, and backup presence |

Both are read-only with respect to application state. `health-check.sh` runs only `SELECT` and
`PRAGMA` statements.
