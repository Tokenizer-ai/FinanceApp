# ADR-0001 — Local-first architecture on SQLite

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** none

## Context

The application holds a complete picture of one person's finances: every account balance, every
transaction, every position, plus employer equity detail that is material non-public information
about that person's compensation. It exists to support a specific decision — a retirement transition
dated March 1, 2027 — and its outputs feed tax and allocation planning.

Commercial alternatives (Monarch, Copilot, Empower) each require the data to live in a vendor's
tenancy. They also model an RSU-heavy pre-retirement balance sheet poorly and export in shapes that
are awkward to analyse externally.

The workload is one person opening an app a few times a week.

## Decision

Run the entire system locally: a single Next.js process on `localhost:3000` backed by a single
SQLite file at `data/finance.db`. No cloud component, no hosted database, no service tier. The only
outbound calls are to SimpleFIN Bridge for aggregation and Stooq for prices.

## Consequences

**Positive**

- The data does not leave the machine. This is the property the whole design exists to protect.
- Backup is `cp`. Restore is `cp`. There is no state anywhere else to reconcile.
- No hosting cost, no vendor account, no terms-of-service risk to the data.
- SQLite's synchronous access model removes an entire class of async complexity from the domain code.
- The schema can change as fast as the owner's thinking changes, with no migration coordination.

**Negative**

- **Single point of failure.** One file. Losing it loses everything, which is why the backup rule is
  stated as non-negotiable in three separate documents.
- **No access from other devices.** The app exists where the Mac is.
- **No scheduler.** Sync runs on app open, so snapshot history is sparse rather than daily
  (`OPERATIONS.md` §5). A launchd job would fix it and add a background process to supervise.
- Credentials at rest in the database file rather than in a managed secret store.

**Neutral**

- The provider abstraction (`src/lib/sync/provider.ts`) means this decision does not lock in
  SimpleFIN specifically.

## Alternatives considered

| Option | Why rejected |
|---|---|
| Commercial aggregator (Monarch, Copilot) | Data in vendor tenancy; poor employer-equity modelling; export shapes unsuitable for external analysis |
| Self-hosted on a VPS with Postgres | Reintroduces a network boundary and a credential store for no benefit at this scale; the data would leave the machine |
| Local app with cloud backup of the DB | Viable, but the backup becomes the weakest link in the threat model. Encrypted off-machine copies handled manually instead |
