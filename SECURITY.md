# Security

This is a single-user, local-first application holding a complete picture of one person's finances.
The threat model is accordingly narrow and the consequences of a mistake are accordingly high.

## What is sensitive

| Asset | Location | Sensitivity |
|---|---|---|
| `data/finance.db` | App directory | **Critical** — every balance, transaction, and position |
| `settings.simplefinAccessUrl` | Inside that database | **Critical** — a bearer credential granting read access to linked bank accounts |
| Portfolio / analysis exports | `~/Downloads` | High — full positions and history in plaintext |
| `~/Library/Logs/finance-app.log` | User library | Low–medium — may contain provider error strings and ticker symbols |

## Non-negotiables

1. **Never commit `data/`, `*.db`, or any export.** `.gitignore` covers these; do not override it.
2. **The SimpleFIN access URL is a credential, not a config value.** It embeds Basic auth. Treat the
   database file the way you would treat a password store: no unencrypted sync to shared drives, no
   attaching it to a ticket, no pasting its contents.
3. **Setup tokens are strictly single-use.** The claim consumes them. A failed claim means generating
   a fresh token — never retry with the old one.
4. **No API keys in the application.** See `docs/adr/0006-no-in-app-llm-analysis.md`. Analysis runs
   by exporting markdown and pasting it into a chat session by hand.
5. **Back up before every repair.** `cp data/finance.db data/finance.db.bak-$(date +%Y%m%d)`.

## Binding and access

The server is intended to bind loopback only and sits behind a password login. **[VERIFY — `V-004`]**

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN     # expect 127.0.0.1, not *
```

If it reports `*:3000`, the app is reachable from anything on the local network. Restrict it before
the next sync.

## Credential rotation

To rotate the SimpleFIN credential:

1. Revoke the existing access at the bridge.
2. Generate a fresh setup token.
3. Settings → SimpleFIN → paste → Connect. The claim overwrites `simplefinAccessUrl`.
4. Sync once and confirm the sync log is clean.

## Data handling when sharing for analysis

Exports contain real balances. Before pasting into any external tool, consider whether account
identifiers and institution names are needed for the question being asked — usually they are not,
and positions plus weights suffice.

## Reporting

Single-maintainer project; no external reporting channel. Findings go in the issue tracker with the
`security` label, or straight into the defect ledger.
