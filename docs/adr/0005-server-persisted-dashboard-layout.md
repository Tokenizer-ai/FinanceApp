# ADR-0005 — Server-persisted dashboard layout

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** none

## Context

The dashboard is a drag-and-drop grid of four widgets — net worth, breakdown, trend, accounts — with
reorderable positions and visibility toggles. That arrangement has to persist somewhere. The
conventional choice for a browser app is `localStorage`.

## Decision

Persist widget order and visibility **server-side**, in the `settings` table, and render the
dashboard in the arranged order from the server.

## Consequences

**Positive**

- The layout is a property of the account, not of a browser profile. It survives cache clears,
  browser changes, and profile resets.
- The server renders the correct arrangement on first paint. No flash of default layout followed by
  a client-side reorder.
- Consistent with the same principle applied to the view-scope filter, which is a cookie read
  server-side so that aggregates are computed — not merely displayed — under the active scope.

**Negative**

- A write to the database on every reorder, where `localStorage` would have been free.
- Adds a settings key and a server action for what is purely presentational state.

**Neutral**

- Single-user app, so there is no per-user keying to design.

## Alternatives considered

| Option | Why rejected |
|---|---|
| `localStorage` | Layout lost on cache clear; flash of default order on first paint; state that exists nowhere the server can see |
| Cookie | Works (and is what the view-scope pill uses), but layout is richer structured data and belongs in a table |
| No persistence | Rearranging on every visit is not a feature |
