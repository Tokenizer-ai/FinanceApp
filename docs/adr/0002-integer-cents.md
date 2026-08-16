# ADR-0002 — All money as integer cents with a strict render guard

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** none

## Context

Money in floating point produces errors that compound silently across aggregation. In a personal
finance app the failure is not a crash — it is a number that looks right and is wrong. Provider data
arrives as **strings** (SimpleFIN returns `balance`, `cost_basis`, `market_value` as text), so there
is a natural point of conversion at the boundary.

## Decision

Every monetary value is an **integer number of cents**, everywhere: in the database, in domain code,
in interfaces.

```
Ingest:  parseCents(string)   string math, never parseFloat
Store:   INTEGER              cents
Render:  formatCents(int)     throws on non-integer input
```

`formatCents` guards **strictly** and throws rather than rounding. A violation surfaces as a page
crash.

## Consequences

**Positive**

- No accumulated float error in any aggregate, ever.
- Corruption is detectable at rest: `typeof(col) = 'real'` in SQLite is a positive signal that
  something upstream wrote a non-integer.
- The provider boundary has one obvious place where conversion happens.

**Negative**

- **The strict guard turns a data defect into a page crash.** This happened: `FA-BUG-002`, where the
  recurring-detection median wrote fractional cents and the Recurring page died on render.
- Every aggregate producing a money value — median, mean, proration, split — must round explicitly.
  This is easy to forget, and forgetting it is invisible until the render.
- Shares cannot follow the same rule; they are genuinely fractional and are stored as text
  (`FA-INV-002`), which means two different numeric conventions coexist.

**Neutral**

- Throwing is the right trade despite `FA-BUG-002`. A crash is loud and got fixed in a day. A
  silently wrong balance in a retirement projection could survive to the decision.

## Alternatives considered

| Option | Why rejected |
|---|---|
| Floats with rounding at render | The error is already in the stored aggregate by then |
| Decimal library | Adds a dependency and a wrapper type at every boundary for a precision need that integer cents already covers |
| Lenient `formatCents` that rounds | Would have prevented the crash and hidden the database corruption. The corruption is the actual problem |
