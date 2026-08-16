#!/bin/bash
# Finance App launcher v1.1 — starts the Next.js server if needed, then opens the app.
# v1.1: detects a *valid* production build via .next/BUILD_ID (not just the folder),
# auto-builds when missing, and extends the wait window accordingly.
#
# Installed at: /Applications/FinanceApp.app/Contents/MacOS/launcher
# After replacing this file:  xattr -cr /Applications/FinanceApp.app
#                             then right-click the app -> Open -> Open (once)

APP_DIR="/Users/jpperez/finance-app"
PORT=3000
URL="http://localhost:${PORT}"
LOG="$HOME/Library/Logs/finance-app.log"

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.nvm/versions/node/*/bin:/usr/bin:/bin:$PATH"

is_up() {
  curl -s -o /dev/null --max-time 2 "$URL"
}

if ! is_up; then
  cd "$APP_DIR" || { osascript -e 'display alert "Finance App" message "App directory not found at '"$APP_DIR"'"'; exit 1; }

  echo "--- launcher $(date) ---" >> "$LOG"

  # A valid production build has .next/BUILD_ID; a dev-mode .next folder does not.
  if [ ! -f ".next/BUILD_ID" ]; then
    echo "No production build found; running npm run build..." >> "$LOG"
    if ! npm run build >> "$LOG" 2>&1; then
      echo "Build failed; falling back to dev mode." >> "$LOG"
      nohup npm run dev >> "$LOG" 2>&1 &
    else
      nohup npm start >> "$LOG" 2>&1 &
    fi
  else
    nohup npm start >> "$LOG" 2>&1 &
  fi

  # Wait up to 60s (dev-mode first boot can be slow)
  for _ in $(seq 1 60); do
    sleep 1
    if is_up; then break; fi
  done
fi

if is_up; then
  open "$URL"
else
  osascript -e 'display alert "Finance App" message "Server did not start within 60 seconds. Check ~/Library/Logs/finance-app.log"'
fi
