# Roadmap and open gaps

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

Open items carry stable `FA-OPEN-*` IDs. Nothing here is scheduled — this is a backlog with honest
priorities, not a plan.

---

## Open gaps

| ID | Item | Priority | Notes |
|---|---|---|---|
| `FA-OPEN-001` | Symbol trend chart on real snapshot history | Medium | Currently price-reconstruction × current shares. Deferred until recorded history is deep enough to be worth charting. Data accrues daily |
| `FA-OPEN-002` | View scope honoured beyond the Dashboard | **High** | Reports, Transactions, Portfolio display the pill and ignore it. Silent inconsistency is worse than absence. Infrastructure is global; only wiring is needed |
| `FA-OPEN-003` | Surface unknown recurring frequencies | **High** | Unrecognised frequencies count as monthly in totals, silently. Cheap to fix, currently mis-states cash-flow projections |
| `FA-OPEN-004` | Snapshot coverage visibility | Medium | Small Portfolio-page section showing which dates/months have recorded history. Matters because coverage is sparse (see `OPERATIONS.md` §5) |
| `FA-OPEN-005` | Multi-currency conversion | Low | Currency fields exist end-to-end; nothing converts |
| `FA-OPEN-006` | Data hygiene tools | Medium | Duplicate-transaction detection, transfer-pair review, category rule builder |
| `FA-OPEN-007` | Performance analytics | Medium | Per-symbol TWR/IRR, realized vs. unrealized, dividend tracking |
| `FA-OPEN-008` | Retirement / FIRE projection widget | **High** | Glide path to 2027-03-01, safe-withdrawal math. The app has net worth trend, contributions, and benchmarks — the inputs exist |
| `FA-OPEN-009` | In-app LLM portfolio scoring | **Blocked** | Structural, not technical — see ADR-0006. `FA-CAP-206` is the accepted alternative |
| `FA-OPEN-010` | Provider data-quality panel | **High** | Flag positions whose asset class was never manually confirmed and accounts whose type was never reviewed. Would have caught `FA-DQ-001`–`003` before they inverted an allocation conclusion |
| `FA-OPEN-011` | Regression tests | **High** | No automated tests exist. Coverage on `formatCents`, the Sankey key builder, and the sync engine would have caught three of six logged defects |
| `FA-OPEN-012` | Alerts / anomaly digest | Low | The sync engine sees everything: new recurring charge, balance drop, spend spike |

---

## Suggested ordering

Reasoning, not a commitment.

**First — correctness and honesty.** `FA-OPEN-003` (silent monthly assumption) and `FA-OPEN-002`
(scope ignored) both make the app quietly report something other than what it appears to.
`FA-OPEN-010` addresses the same class of failure at the provider boundary. Given that this app
feeds retirement decisions, silent wrongness is the highest-cost defect type it can have.

**Second — durability.** `FA-OPEN-011`. Three of six logged defects were regressions a test would
have caught, and two of them surfaced as production page crashes.

**Third — the reason the app exists.** `FA-OPEN-008`, the retirement projection. Everything upstream
of it is already built; this is the feature that turns a ledger into a decision instrument before
March 2027.

**Later — analytical depth.** `FA-OPEN-001`, `FA-OPEN-007`, `FA-OPEN-006`.

**Deliberately not doing.** `FA-OPEN-009` (blocked by design), `FA-OPEN-005` (no forcing need).

---

## Superseded

| ID | Item | Outcome |
|---|---|---|
| — | Manual monthly CSV archiving as the history mechanism | Superseded by `holdings_snapshots` (ADR-0004). The app is now its own historian; no filing discipline required |
