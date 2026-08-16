# Changelog

All notable changes to this documentation set. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning is semantic against the
documentation contract, not the application version.

## [1.0.0] — 2026-08-16

Initial consolidated documentation, reconstructed from the build sessions that produced the
application. Seven claims remain unverified against live source — see `docs/VERIFY-LEDGER.md`.

### Added

- `README.md` — front door, four operating rules, ID conventions, adoption paths
- `vault/Finance App — Capabilities and Structure.md` — canonical consolidated note (Obsidian-ready)
- `docs/ARCHITECTURE.md` — layers, sync ordering, trust boundaries `FA-TB-001`–`004`
- `docs/DATA-MODEL.md` — table inventory `FA-DM-001`–`011`, invariant `FA-INV-001`,
  verbatim `holdings_snapshots` DDL, ER diagram
- `docs/FEATURES.md` — capability catalogue `FA-CAP-101`–`504`
- `docs/SIMPLEFIN-INTEGRATION.md` — protocol flow, nine holdings fields, Option A merge semantics,
  data-quality traps `FA-DQ-001`–`003`
- `docs/DESIGN-SYSTEM.md` — Monarch-derived token set and component patterns
- `docs/OPERATIONS.md` — install runbook, build discipline, launcher v1.1 behaviour, backup policy
- `docs/TROUBLESHOOTING.md` — defect ledger `FA-BUG-001`–`006` with symptoms and fixes
- `docs/ROADMAP.md` — open gaps `FA-OPEN-001`–`009`
- `docs/VERIFY-LEDGER.md` — seven open items `V-001`–`007` with clearing commands
- `docs/adr/0001`–`0006` — local-first SQLite, integer cents, Option A holdings merge,
  daily snapshots, server-persisted layout, no in-app LLM
- `CONTRIBUTING.md`, `SECURITY.md`, `.github/` templates and CI workflow
- `reference/launcher-v1.1.sh` — preserved launcher source

### Documented defects (already fixed in the application)

`FA-BUG-001` SimpleFIN credential-in-URL · `FA-BUG-002` fractional cents in `recurring_items` ·
`FA-BUG-003` Sankey node-key cycle · `FA-BUG-004` dark-mode inputs · `FA-BUG-005` launcher
quarantine · `FA-BUG-006` `.next` folder vs. `BUILD_ID`

### Known limitations of this release

- Structure in `docs/ARCHITECTURE.md` §4 is reconstructed, not enumerated from the live tree
- Table inventory may be incomplete until `V-005` is cleared
- No application source is included; this is a documentation repository
