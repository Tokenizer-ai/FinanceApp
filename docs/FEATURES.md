# Capability catalogue

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

Every shipped capability, with a stable ID. Numbering blocks: **100** sync and ingestion,
**200** portfolio, **300** dashboard, **400** pages, **500** runtime. Gaps are intentional — leave
room when adding.

---

## 100 — Sync and ingestion

| ID | Capability | Detail |
|---|---|---|
| `FA-CAP-101` | SimpleFIN account sync | Balances, org name and domain, currency; `balance-date` honoured |
| `FA-CAP-102` | SimpleFIN transaction sync | `pending=1` requested; `start-date` passed in unix seconds. History depth is bank-dependent, typically ~90 days on first sync |
| `FA-CAP-103` | SimpleFIN holdings sync | Parses all nine fields of the undocumented `/accounts` holdings array extension. Option A merge semantics (ADR-0003) |
| `FA-CAP-104` | Manual sync and auto-sync | "Sync now" in Settings; sync-on-open calls `POST /api/sync?onlyIfStale=1`. Staleness threshold **1 hour** (relaxed from 12h) |
| `FA-CAP-105` | CSV transaction import wizard | Backfill path for history deeper than the bridge returns |
| `FA-CAP-106` | Holdings CSV import | `importHoldingsCsv`; triggers a snapshot write on completion |
| `FA-CAP-107` | Stooq daily price fetch | Held tickers plus benchmarks. Per-ticker outcome recorded in `priceFetch[]` on the sync result (BUILD_SPEC §9) |
| `FA-CAP-108` | Sync log | Per-run counts and provider-relayed errors surfaced in Settings — including bank-side messages like re-authentication prompts |

---

## 200 — Portfolio

| ID | Capability | Detail |
|---|---|---|
| `FA-CAP-201` | Holdings table | Ticker, name, shares (fractional, text), cost basis, market value, asset class, source |
| `FA-CAP-202` | Manual holdings CRUD | For accounts the provider does not report positions on — TIAA Traditional, unvested equity, anything outside a linked institution |
| `FA-CAP-203` | Per-symbol value trend chart | Leads the Portfolio page. One line per ticker, computed as price history × **current** shares |
| `FA-CAP-204` | Current-positions CSV export | Generated on the fly, streamed to the browser. Nothing is stored server-side |
| `FA-CAP-205` | Monthly-history CSV export | **Snapshot-first**: real historical share counts where `holdings_snapshots` rows exist; reconstructed and explicitly labelled for months before the feature shipped |
| `FA-CAP-206` | Analysis export (Markdown) | One button emits a structured document with all current and historical portfolio data, formatted for pasting into an external LLM session. The accepted alternative to in-app API calls (ADR-0006) |

**Known weakness — `FA-CAP-203`.** The symbol trend still multiplies historical prices by *today's*
share count, so it shows price movement rather than true position value over time. Switching it to
read `holdings_snapshots` is `FA-OPEN-001`, deferred until recorded history is deep enough to be
worth charting.

---

## 300 — Dashboard

| ID | Capability | Detail |
|---|---|---|
| `FA-CAP-301` | Drag-and-drop widget grid | Four widgets: net worth, breakdown, trend, accounts |
| `FA-CAP-302` | Server-persisted layout | Widget order and visibility stored in `settings`, not browser storage — survives cache clears and device changes (ADR-0005) |
| `FA-CAP-303` | Multi-series trend chart | One distinct colour per asset class, with total net worth drawn in orange |
| `FA-CAP-304` | View scope switcher | Pill control — All / Cash / Investments / Debt. Cookie-backed, filters all dashboard aggregates **server-side** |

**Known weakness — `FA-CAP-304`.** The pill infrastructure is global but only the Dashboard honours
it. Reports, Transactions, and Portfolio ignore the scope silently, which is worse than not offering
it there at all. `FA-OPEN-002`.

---

## 400 — Pages

| ID | Capability | Detail |
|---|---|---|
| `FA-CAP-401` | Accounts accordion | Collapsible cards grouped by account type, each group carrying a subtotal |
| `FA-CAP-402` | Budget accordion | Same pattern, grouped by category group |
| `FA-CAP-403` | Recurring detection | Median-based expected amount per detected series. **Must round to integer cents** — see `FA-BUG-002` |
| `FA-CAP-404` | Reports — Sankey cash flow | Multi-level income → group → category flow. Node keys namespaced by level with a self-link guard (`FA-BUG-003`) |
| `FA-CAP-405` | Transactions ledger | Search, categorize, pending indicators |

**Known weakness — `FA-CAP-403`.** Recurring items whose frequency is not recognised are silently
counted as monthly in totals. Silent is the problem, not the default. `FA-OPEN-003`.

---

## 500 — Runtime and operations

| ID | Capability | Detail |
|---|---|---|
| `FA-CAP-501` | Dock launcher v1.1 | Detects a valid production build via `.next/BUILD_ID`; auto-builds when missing; falls back to dev mode if the build fails; waits up to 60s; alerts via `osascript` on timeout. Source at `reference/launcher-v1.1.sh` |
| `FA-CAP-502` | Centralised log | `~/Library/Logs/finance-app.log`, one `--- launcher <date> ---` marker per click |
| `FA-CAP-503` | Password login | Gate on `/login` before any route in the `(app)` group |
| `FA-CAP-504` | Dark mode | `color-scheme` declarations plus global form-control rules — both required, see `FA-BUG-004` |

---

## Capability-to-document index

| Looking for | Go to |
|---|---|
| How sync works end to end | `ARCHITECTURE.md` §3, `SIMPLEFIN-INTEGRATION.md` |
| Where snapshot data comes from | `DATA-MODEL.md` §4 |
| Why layout is server-side | `adr/0005-server-persisted-dashboard-layout.md` |
| Why there is no in-app AI scoring | `adr/0006-no-in-app-llm-analysis.md` |
| What is *not* built | `ROADMAP.md` |
