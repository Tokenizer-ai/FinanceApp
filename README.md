# finance-app-docs

Documentation, architecture decisions, and operational runbooks for **finance-app** — a local-first
personal finance and portfolio system running at `/Users/jpperez/finance-app`.

> **This repo contains documentation, not source.** The application lives in its own tree. Keep this
> repo alongside it, or vendor `docs/` into the app repo — see [Adoption](#adoption).

---

## What finance-app is

A single-user, self-hosted finance system. Next.js on `localhost:3000`, SQLite on disk, no cloud
tenancy. Two outbound integrations: **SimpleFIN Bridge** for accounts, transactions and holdings;
**Stooq** for daily security prices. Built as the instrument panel for a March 2027 retirement
transition, which is why position history, asset-class scoping, and analysis export are first-class
rather than bolted on.

```
Dock icon → launcher v1.1 → Next.js (prod build) → SQLite (data/finance.db)
                                    ↓
                     SimpleFIN Bridge · Stooq (HTTPS, server-side only)
```

## Documentation map

| Document | Read it when |
|---|---|
| [`vault/Finance App — Capabilities and Structure.md`](vault/) | You want the whole picture in one file (canonical vault note) |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Understanding layers, sync ordering, trust boundaries |
| [`docs/DATA-MODEL.md`](docs/DATA-MODEL.md) | Touching the schema or writing a query |
| [`docs/FEATURES.md`](docs/FEATURES.md) | Looking up what exists, by capability ID |
| [`docs/SIMPLEFIN-INTEGRATION.md`](docs/SIMPLEFIN-INTEGRATION.md) | Sync is broken, or provider data looks wrong |
| [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) | Adding UI |
| [`docs/OPERATIONS.md`](docs/OPERATIONS.md) | Installing a change, or the app won't start |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Something is throwing |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Deciding what to build next |
| [`docs/VERIFY-LEDGER.md`](docs/VERIFY-LEDGER.md) | Before trusting anything here as fact |
| [`docs/adr/`](docs/adr/) | Asking "why is it like this?" |

## The four rules

Everything else is detail. These four cause the majority of incidents:

1. **`npm run build` after every source change.** The app runs in production mode; source edits are
   invisible to the running compiled bundle.
2. **`npm run db:generate && npm run db:migrate` if `schema.ts` changed** — before the build. A
   skipped migration is a server-side crash, not a graceful degradation.
3. **All money is integer cents.** `parseCents()` in, `formatCents()` out. A fractional cent in the
   database is a live defect waiting on a page render.
4. **Back up `data/finance.db` before any repair.** It is the entire application state.

```bash
cd /Users/jpperez/finance-app
cp data/finance.db data/finance.db.bak-$(date +%Y%m%d)
lsof -ti :3000 | xargs kill
npm run db:generate && npm run db:migrate   # only if schema changed
npm run build
open -a FinanceApp
```

## Health check

```bash
sqlite3 data/finance.db "SELECT name FROM sqlite_master WHERE name='holdings_snapshots';"
sqlite3 data/finance.db "SELECT COUNT(*) FROM recurring_items WHERE typeof(expected_amount)='real';"  # expect 0
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000
tail -30 ~/Library/Logs/finance-app.log
```

## Conventions

**Stable IDs.** Every capability, table, defect, invariant, and open item carries an ID that does
not change once assigned. Cite the ID in commits and issues, never the prose.

| Prefix | Domain |
|---|---|
| `FA-CAP-*` | Capabilities |
| `FA-DM-*` | Data model / tables |
| `FA-INV-*` | Invariants |
| `FA-BUG-*` | Resolved defects |
| `FA-OPEN-*` | Open gaps |
| `FA-DQ-*` | Provider data-quality traps |
| `FA-TB-*` | Trust boundaries |
| `V-*` | Unverified claims (see verify ledger) |

**Verify flags.** Documentation reconstructed from build sessions rather than read from current
source is marked **[VERIFY]** and tracked in [`docs/VERIFY-LEDGER.md`](docs/VERIFY-LEDGER.md) with a
one-line command to clear it. Do not treat a flagged claim as fact.

**Plan before build.** Changes are specified and agreed in plan mode, then released to build. ADRs
capture the decision; the commit implements it.

## Adoption

Two supported layouts.

**Standalone (as shipped).** Keep this repo next to the app. Documentation versions independently of
code — appropriate while the docs are being reconstructed and verified.

```
~/Projects/
├── finance-app/          # source
└── finance-app-docs/     # this repo
```

**Vendored.** Once the verify ledger is clear, copy `docs/`, `.github/`, and the root markdown into
the app repo so documentation and code move in the same commit.

```bash
cp -r finance-app-docs/docs finance-app-docs/.github /Users/jpperez/finance-app/
cp finance-app-docs/CONTRIBUTING.md finance-app-docs/SECURITY.md /Users/jpperez/finance-app/
```

## Status

| | |
|---|---|
| Docs version | 1.0.0 |
| Documents app version | Reconstructed from sessions through 2026-08 |
| Verify ledger | **7 open** — see [`docs/VERIFY-LEDGER.md`](docs/VERIFY-LEDGER.md) |
| License | [MIT](LICENSE) |
