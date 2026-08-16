---
name: Application defect
about: Something in finance-app is broken
title: "[BUG] "
labels: bug
---

## Symptom

<!-- Exact error text, page, and what was on screen. Paste, don't paraphrase. -->

## Reproduction

1.
2.
3.

## Diagnostics

Run these and paste the output:

```bash
cd /Users/jpperez/finance-app
tail -30 ~/Library/Logs/finance-app.log
sqlite3 data/finance.db "SELECT name FROM sqlite_master WHERE name='holdings_snapshots';"
sqlite3 data/finance.db "SELECT COUNT(*) FROM recurring_items WHERE typeof(expected_amount)='real';"
ls .next/BUILD_ID
```

## Pre-flight

- [ ] `npm run build` was run after the most recent source change
- [ ] `npm run db:generate && npm run db:migrate` was run if `schema.ts` changed
- [ ] `data/finance.db` backed up
- [ ] Checked `docs/TROUBLESHOOTING.md` for a matching `FA-BUG-*`

## Suspected area

- [ ] Sync / SimpleFIN
- [ ] Portfolio / holdings / snapshots
- [ ] Dashboard / widgets
- [ ] Budget / recurring
- [ ] Reports
- [ ] Launcher / runtime
- [ ] Documentation is wrong
