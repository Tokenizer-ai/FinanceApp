# Verify ledger

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

This documentation set was reconstructed from build-session history, not read from the live source
tree. Claims that were not established directly in-session carry a **[VERIFY]** flag inline and a row
here with a one-line command that settles them.

**Rule:** a `V-*` item is not evidence. Do not cite a flagged claim as fact, and do not build on one
without clearing it first.

---

## Open items

| ID | Claim | Location | Clearing command |
|---|---|---|---|
| `V-001` | Chart library is Recharts | `vault` note §3 | `grep -E '"(recharts\|chart\.js\|d3)"' package.json` |
| `V-002` | Money helpers live at `src/lib/money.ts` | `ARCHITECTURE.md` §4 | `grep -rn "export function formatCents" src/` |
| `V-003` | Migrations directory is `drizzle/` | `ARCHITECTURE.md` §4 | `cat drizzle.config.ts && ls drizzle/` |
| `V-004` | Server binds loopback only | `SECURITY.md`, `ARCHITECTURE.md` §6 | `lsof -nP -iTCP:3000 -sTCP:LISTEN` — expect `127.0.0.1`, not `*` |
| `V-005` | Table inventory in `DATA-MODEL.md` §2 is complete | `DATA-MODEL.md` §2 | `sqlite3 data/finance.db ".tables"` |
| `V-006` | Directory and route listing is accurate | `ARCHITECTURE.md` §4 | `find src/app -name 'page.tsx' \| sort && find src/lib -name '*.ts' \| sort` |
| `V-007` | `holdings_snapshots` DDL matches the reproduction verbatim | `DATA-MODEL.md` §4 | `sqlite3 data/finance.db ".schema holdings_snapshots"` |

---

## Clearing procedure

1. Branch: `verify/V-00N`
2. Run the command against `/Users/jpperez/finance-app`
3. Outcome:
   - **Confirmed** — remove the inline `[VERIFY]` flag, move the row to *Cleared* below with the
     date and the evidence
   - **Corrected** — fix the documentation, move the row to *Cleared* noting what was wrong, and add
     a `CHANGELOG.md` entry
   - **Obsolete** — move to *Cleared* with a pointer to what replaced it
4. Commit: `verify(V-00N): <confirmed|corrected> <claim>`
5. Never delete a row. The ledger is the audit trail.

Run all seven at once:

```bash
cd /Users/jpperez/finance-app
echo "--- V-001"; grep -E '"(recharts|chart\.js|d3)"' package.json
echo "--- V-002"; grep -rn "export function formatCents" src/
echo "--- V-003"; ls drizzle/ 2>/dev/null; cat drizzle.config.ts 2>/dev/null | head -20
echo "--- V-004"; lsof -nP -iTCP:3000 -sTCP:LISTEN
echo "--- V-005"; sqlite3 data/finance.db ".tables"
echo "--- V-006"; find src/app -name 'page.tsx' | sort; find src/lib -name '*.ts' | sort
echo "--- V-007"; sqlite3 data/finance.db ".schema holdings_snapshots"
```

---

## Cleared

*(none yet)*

| ID | Claim | Outcome | Date | Evidence |
|---|---|---|---|---|
