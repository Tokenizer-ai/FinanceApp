# ADR-0003 — Option A holdings merge semantics

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** none

## Context

SimpleFIN reports investment holdings for some accounts and not others — reporting depends on the
institution. Assets that matter to this portfolio exist on both sides of that line: linked brokerage
positions on one side, and TIAA Traditional, unvested employer equity, and anything outside a linked
institution on the other, all tracked manually.

Each sync must reconcile provider holdings against local rows without destroying manual work.

## Decision

**Option A:**

> On accounts the provider reports holdings for, provider data **replaces** local holdings.
> On accounts the provider does not report holdings for, manual holdings are **preserved** untouched.

The `source` column (`manual` | `simplefin`) and the presence or absence of a `holdings[]` array per
account make this decidable at sync time.

## Consequences

**Positive**

- Linked accounts stay accurate with zero maintenance; the provider is authoritative where it speaks.
- Manually tracked assets survive every sync, so the portfolio is complete rather than partial.
- The rule is stated in one sentence and is inspectable per account.

**Negative**

- **A manual `assetClass` correction on a reporting account is destroyed by the next sync.** This is
  the sharp edge, and it matters because provider asset classes are demonstrably wrong (`FA-DQ-002`:
  VAIPX, a TIPS bond fund, arrived tagged `stock`). Corrections only persist on non-reporting
  accounts.
- No way to pin a provider-reported position's classification without a design change.
- Provider holdings arriving for an account that previously had manual rows silently discards them.

**Neutral**

- A future override table keyed by ticker would resolve the negative without changing the merge rule.

## Alternatives considered

| Option | Why rejected |
|---|---|
| **Option B** — merge field-by-field, preferring local edits | Ambiguous: no reliable way to distinguish "the user corrected this" from "this is stale." Divergence accumulates invisibly |
| **Option C** — provider replaces everything | Destroys manually tracked assets, which are a large share of this portfolio's value |
| Per-position lock flags | Correct long-term answer; disproportionate complexity for the current position count |
