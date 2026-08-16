# ADR-0004 — Daily holdings snapshots as position history

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** manual monthly CSV archiving

## Context

The `holdings` table is current-state: each sync overwrites it. Balance history existed
(`balance_snapshots`) and price history existed (`security_prices`), but **position** history did
not. Consequently the monthly portfolio export could only reconstruct history as *month-end price ×
today's share count* — which shows how prices moved a fixed position, not how the position itself
changed. Contributions, rebalances, and drift were invisible.

The interim answer was manual: export a CSV on the first of each month and file it. That depends on
discipline and produces a folder of files outside the app.

## Decision

Add `holdings_snapshots` — a dated copy of every holding row, written on **every sync** and after
**every holdings mutation** (manual CRUD and CSV import).

Write semantics are a **full daily replace**: delete today's rows, insert current state.

```ts
db.delete(holdingsSnapshots).where(eq(holdingsSnapshots.date, today)).run();
// …insert current holdings
```

Market value precedence: live Stooq close × shares → provider-reported value → `null`. The snapshot
runs **after** the price fetch in the sync pipeline so values use fresh closes.

The monthly export becomes **snapshot-first**: real historical share counts where snapshots exist,
reconstructed and **explicitly labelled** for months before the feature shipped.

## Consequences

**Positive**

- The app is its own historian. No filing discipline, no external folder of CSVs.
- True month-over-month comparison: real shares, real values, real weight drift.
- Delete-then-insert correctly records an account whose holdings were **emptied** — an upsert would
  leave orphan rows asserting positions that no longer exist.
- Storage cost is negligible: a few dozen rows per day in SQLite.

**Negative**

- **History cannot be backfilled.** It begins the day the feature shipped. Everything before is
  reconstruction, and is labelled as such.
- Snapshots are written on sync, and sync happens on app open. **Days the app is not opened have no
  row**, so "month-end" means "the last day the app was opened that month."
- Consumers must handle a sparse date series rather than assuming daily continuity.

**Neutral**

- `FA-CAP-203` (per-symbol trend) still uses price-reconstruction and has not been switched to read
  snapshots — deferred as `FA-OPEN-001` until recorded history is deep enough to chart.

## Alternatives considered

| Option | Why rejected |
|---|---|
| Manual monthly CSV export and archive | Depends on discipline; data lives outside the app; no programmatic access |
| Versioned `holdings` table with `valid_from` / `valid_to` | Every dashboard query would need a "latest" predicate. The hot path is overwhelmingly current state |
| Upsert instead of delete-then-insert | Cannot represent an emptied account. Stale rows would silently assert positions that no longer exist |
| Snapshot before the price fetch | Would record stale or null market values |
