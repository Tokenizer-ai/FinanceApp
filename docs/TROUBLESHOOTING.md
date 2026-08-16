# Troubleshooting and defect ledger

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

---

## 1. First moves

Before diagnosing anything, rule out the two most common causes:

```bash
cd /Users/jpperez/finance-app
ls .next/BUILD_ID                                    # was the change built?
sqlite3 data/finance.db "SELECT name FROM sqlite_master WHERE name='holdings_snapshots';"
tail -30 ~/Library/Logs/finance-app.log
```

A missing build or a skipped migration explains the majority of incidents. For a readable stack
trace, stop the server and run `npm run dev`, then reproduce in the browser.

---

## 2. Symptom index

| Symptom | Go to |
|---|---|
| "My change did nothing" | §3 — missing build |
| `no such column` / `no such table` | §3 — skipped migration |
| Recurring page throws in `formatCents` | `FA-BUG-002` |
| Reports page: `RangeError: Maximum call stack size exceeded` | `FA-BUG-003` |
| Dock icon does nothing | `FA-BUG-005` |
| "Could not find a production build" | `FA-BUG-006` |
| Sync 403 | `SIMPLEFIN-INTEGRATION.md` §6 |
| Inputs unreadable in dark mode | `FA-BUG-004` |
| Numbers look wrong but nothing crashes | §4 — data quality, not code |

---

## 3. Environment-level failures

**Missing build.** The app serves the compiled bundle; source edits are inert until `npm run build`.

**Skipped migration.** Any page whose query touches a new column or table dies server-side.

```bash
cp data/finance.db data/finance.db.bak-$(date +%Y%m%d-fix)
npm run db:generate && npm run db:migrate && npm run build
```

---

## 4. When the numbers are wrong but nothing crashes

This is the more dangerous class. Check provider data quality before suspecting the code:

- `FA-DQ-001` — employer equity reported as owned + unvested combined
- `FA-DQ-002` — asset class mislabelled (a TIPS fund tagged as stock)
- `FA-DQ-003` — account type mislabelled (savings typed as brokerage)

All three were live at once and inverted an allocation conclusion. Full detail and mitigations in
`SIMPLEFIN-INTEGRATION.md` §5.

---

## 5. Resolved defect ledger

### `FA-BUG-001` — SimpleFIN requests fail with credentials in the URL

**Symptom:** authenticated bridge calls rejected.
**Root cause:** the access URL embeds Basic auth inline (`https://user:pass@host/...`); passing it
straight to `fetch` did not authenticate.
**Fix:** extract the credentials, send `Authorization: Basic`, request the stripped URL.
**Prevention:** any new call path to the bridge must do this explicitly — it is not implicit.

### `FA-BUG-002` — Recurring page crash in `formatCents`

**Symptom:** Recurring page throws server-side.
**Root cause:** the recurring-detection **median** produced a non-integer, written straight into
`recurring_items.expected_amount`. `formatCents` guards strictly against non-integers, so the render
threw. The corruption was at rest in the database, not in the render path.
**Fix:** round at write time; repair existing rows.

```bash
sqlite3 data/finance.db "SELECT COUNT(*) FROM recurring_items WHERE typeof(expected_amount)='real';"
cp data/finance.db data/finance.db.bak-$(date +%Y%m%d)
sqlite3 data/finance.db \
  "UPDATE recurring_items SET expected_amount = CAST(ROUND(expected_amount) AS INTEGER)
   WHERE typeof(expected_amount)='real';"
npm run build
```

**Prevention:** any aggregate producing a money value — median, mean, proration, split — must round
to integer cents before it reaches a column. `FA-INV-001`.

### `FA-BUG-003` — Reports crash: `RangeError: Maximum call stack size exceeded`

**Symptom:** Reports page fails to render; stack overflow in the Sankey layout.
**Root cause:** Sankey nodes were keyed by **display name** across levels. A category sharing its
group's name produced a node that linked to itself, creating a cycle the layout algorithm recursed
on forever.
**Fix:** namespace node keys by level (`level:name`) and add a hard self-link guard that drops any
link whose source equals its target.
**Prevention:** graph node keys must be structurally unique, never display strings. Data-dependent —
a sandbox with clean seed data will not reproduce it.

### `FA-BUG-004` — Dark-mode inputs unreadable

**Root cause:** missing `color-scheme`; form controls inherited light user-agent styling against a
dark surface.
**Fix:** `color-scheme` declarations plus explicit global rules for form controls. Both are needed.

### `FA-BUG-005` — Dock icon silently does nothing after launcher replacement

**Root cause:** the downloaded `launcher` carried `com.apple.quarantine`, and replacing the
executable inside an already-approved bundle invalidated Gatekeeper's approval.
**Fix:**

```bash
xattr -cr /Applications/FinanceApp.app
# then right-click → Open → Open, once
```

**Diagnostic that isolates it:** run the launcher directly. If that works and the icon does not, it
is Gatekeeper.

### `FA-BUG-006` — "Could not find a production build"

**Root cause:** launcher v1.0 tested for the `.next` **folder**. `npm run dev` also creates it, so
after any dev run the launcher chose `npm start` against a dev-mode folder.
**Fix:** launcher v1.1 tests `.next/BUILD_ID`, which only a real production build creates, and
auto-builds when it is missing.

---

## 6. Patterns worth carrying forward

| Pattern | Lesson |
|---|---|
| Corruption at rest, crash at render | `FA-BUG-002` — the strict guard was right; it surfaced a database defect at the render boundary. Check `typeof()` in SQLite, not just the code |
| Data-dependent bugs don't reproduce in a sandbox | `FA-BUG-003` — seeded data never had a category named after its group. Get the real error text before theorising |
| Environment beats logic as a cause | `FA-BUG-005`, `FA-BUG-006` — quarantine flags and build-state detection, not application code |
| Silent wrongness is worse than a crash | `FA-DQ-001`–`003` — the app faithfully reported bad provider data and nothing flagged it |
