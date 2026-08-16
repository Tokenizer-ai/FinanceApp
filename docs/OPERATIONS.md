# Operations runbook

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

---

## 1. The build discipline

The app runs in **production mode**. The executing artifact is the compiled bundle in `.next`.
Source edits are invisible until rebuilt. This is the most frequent trip-hazard in the project's
history.

### Standard install path

```bash
cd /Users/jpperez/finance-app

# 1. Back up state — always, no exceptions
cp data/finance.db data/finance.db.bak-$(date +%Y%m%d)

# 2. Stop the running server
lsof -ti :3000 | xargs kill

# 3. Apply the change
unzip -o ~/Downloads/<change>.zip -d .

# 4. Migrate — ONLY if the change touched src/db/schema.ts
npm run db:generate && npm run db:migrate

# 5. Rebuild — ALWAYS
npm run build
```

Then relaunch from the Dock.

### Decision table

| Change touched | `db:generate` + `db:migrate` | `npm run build` |
|---|---|---|
| Any `.ts` / `.tsx` source | No | **Yes** |
| `src/db/schema.ts` | **Yes** | **Yes** |
| CSS / tokens only | No | **Yes** |
| Nothing (config in the app UI) | No | No |

Two failure modes, both silent until they aren't:

- **Skipped build** → "my change did nothing." The old bundle is still serving.
- **Skipped migration** → server-side page crash: `no such column: …`, `no such table: …`. The
  browser shows a generic error; the real message is in the log.

---

## 2. Launcher v1.1

`FinanceApp.app` in `/Applications`, pinned to the Dock. Source preserved at
`reference/launcher-v1.1.sh`.

| Condition | Behaviour |
|---|---|
| Server already responding | Opens `http://localhost:3000` immediately |
| `.next/BUILD_ID` present | `npm start` |
| `.next` exists, no `BUILD_ID` (dev-mode residue) | Runs `npm run build`, then `npm start` |
| Build fails | Falls back to `npm run dev` |
| Not up within 60s | `osascript` alert pointing at the log |

**Why `BUILD_ID` and not the `.next` folder.** v1.0 checked for the folder. `npm run dev` also
creates `.next`, so after any dev run the launcher chose `npm start`, and Next refused with "Could
not find a production build" (`FA-BUG-006`). `BUILD_ID` exists only in a real production build.

### Replacing the launcher

Replacing the executable inside an approved bundle breaks Gatekeeper's approval, and a freshly
downloaded file carries the quarantine attribute — the icon then silently does nothing
(`FA-BUG-005`).

```bash
cp ~/Downloads/launcher /Applications/FinanceApp.app/Contents/MacOS/launcher
chmod +x /Applications/FinanceApp.app/Contents/MacOS/launcher
xattr -cr /Applications/FinanceApp.app
# then: right-click the app → Open → Open  (once)
```

Diagnosing a dead icon, in order:

```bash
ls -la /Applications/FinanceApp.app/Contents/MacOS/          # present and executable?
xattr /Applications/FinanceApp.app/Contents/MacOS/launcher   # com.apple.quarantine?
tail -20 ~/Library/Logs/finance-app.log                      # any new "--- launcher <date> ---"?
/Applications/FinanceApp.app/Contents/MacOS/launcher         # run directly, bypassing Gatekeeper
```

If the direct run works but the icon does not, it is Gatekeeper. If no launcher marker appears in
the log on click, the launcher is not being invoked at all — same fix, or the copy landed somewhere
other than the app being clicked.

---

## 3. Health checks

```bash
cd /Users/jpperez/finance-app

# Runtime
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000
ls .next/BUILD_ID
tail -30 ~/Library/Logs/finance-app.log

# Schema state
sqlite3 data/finance.db "PRAGMA table_info(holdings);" | grep -c market_value_cents   # expect 1
sqlite3 data/finance.db "SELECT name FROM sqlite_master WHERE name='holdings_snapshots';"

# Invariant FA-INV-001 — expect 0
sqlite3 data/finance.db "SELECT COUNT(*) FROM recurring_items WHERE typeof(expected_amount)='real';"

# Sync freshness
sqlite3 data/finance.db "SELECT * FROM sync_log ORDER BY id DESC LIMIT 3;"

# Snapshot accrual — should gain rows on days the app is opened
sqlite3 data/finance.db "SELECT date, COUNT(*) FROM holdings_snapshots GROUP BY date ORDER BY date DESC LIMIT 7;"
```

---

## 4. Backup policy

`data/finance.db` is the entire system. No replica, no cloud copy, no undo.

| When | Command |
|---|---|
| Before any repair | `cp data/finance.db data/finance.db.bak-$(date +%Y%m%d)` |
| Before any migration against real data | Same, with a `-reason` suffix |
| Periodically | Copy off-machine — encrypted. The file contains every balance and position |

Restore: stop the server, `cp` the backup over `data/finance.db`, then re-run `npm run db:migrate`
if the build has advanced past the backup's schema.

---

## 5. Snapshot cadence

Snapshots are written **on sync**, and sync happens **on app open**. There is no scheduler.

**Consequence:** days the app is not opened have no snapshot row. History is therefore sparse, not
daily, and monthly analysis reads "the last snapshot in each month" rather than a true month-end. On
a month where the app was last opened on the 12th, the "month-end" position is the 12th.

Mitigation is behavioural: open the app on or near the first of each month. Automating it would mean
a launchd job, which trades a documented gap for a background process to supervise — not currently
judged worth it.

---

## 6. Log reference

`~/Library/Logs/finance-app.log`

| Marker | Meaning |
|---|---|
| `--- launcher <date> ---` | One per Dock click |
| `No production build found; running npm run build...` | Self-heal path engaged |
| `Build failed; falling back to dev mode.` | Investigate — the build is broken |
| Next.js server output | Startup, request errors, server-component stack traces |

For a full in-browser stack trace, stop the server and run `npm run dev`, then reproduce.

---

## 7. Routine calendar

| Cadence | Task |
|---|---|
| On open | Auto-sync if stale > 1h; check the sync log for provider errors |
| Weekly | Confirm snapshot rows are accruing |
| Monthly (near the 1st) | Open the app to force a month-boundary snapshot; export current positions and archive |
| On any new position | Audit `assetClass` — `FA-DQ-002` |
| On any new institution | Audit account types — `FA-DQ-003` |
| Before any allocation decision | Re-check `FA-DQ-001`–`003` in full |
| Quarterly | Off-machine encrypted backup; review `docs/VERIFY-LEDGER.md` |
