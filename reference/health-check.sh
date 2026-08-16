#!/bin/bash
# finance-app health check — read-only. Safe to run any time.
set -u
APP_DIR="/Users/jpperez/finance-app"
DB="$APP_DIR/data/finance.db"
cd "$APP_DIR" || { echo "App directory not found: $APP_DIR"; exit 1; }

hr() { printf '%s\n' "------------------------------------------------------------"; }

hr; echo "RUNTIME"
printf 'HTTP status      : '; curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000 || echo "not responding"
printf 'Production build : '; [ -f .next/BUILD_ID ] && echo "present ($(cat .next/BUILD_ID))" || echo "MISSING — run npm run build"

hr; echo "SCHEMA"
printf 'holdings.market_value_cents : '; sqlite3 "$DB" "PRAGMA table_info(holdings);" | grep -c market_value_cents
printf 'holdings_snapshots table    : '; sqlite3 "$DB" "SELECT COALESCE(name,'MISSING') FROM sqlite_master WHERE name='holdings_snapshots';"

hr; echo "INVARIANT FA-INV-001 (expect 0)"
printf 'recurring_items non-integer cents : '
sqlite3 "$DB" "SELECT COUNT(*) FROM recurring_items WHERE typeof(expected_amount)='real';"

hr; echo "SNAPSHOT COVERAGE (last 7 recorded dates)"
sqlite3 -column -header "$DB" \
  "SELECT date, COUNT(*) AS rows FROM holdings_snapshots GROUP BY date ORDER BY date DESC LIMIT 7;"

hr; echo "RECENT SYNCS"
sqlite3 -column -header "$DB" "SELECT * FROM sync_log ORDER BY id DESC LIMIT 3;" 2>/dev/null \
  || echo "sync_log not readable — confirm table name (V-005)"

hr; echo "BACKUPS"
ls -1t data/finance.db.bak-* 2>/dev/null | head -3 || echo "NO BACKUPS FOUND — run: cp data/finance.db data/finance.db.bak-\$(date +%Y%m%d)"

hr; echo "LOG TAIL"
tail -10 ~/Library/Logs/finance-app.log 2>/dev/null || echo "no log yet"
hr
