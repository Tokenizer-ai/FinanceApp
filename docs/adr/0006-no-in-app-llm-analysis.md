# ADR-0006 — No in-app LLM analysis; export-and-paste instead

**Status:** Accepted · **Date:** 2026 (reconstructed) · **Supersedes:** none

## Context

A requested feature: a button on the Portfolio page that sends all current and historical portfolio
data to Claude Opus and returns a **0–100 resilience score** — the likelihood the portfolio loses
minimal value through a sustained one-year drawdown of roughly 10%.

The intent was to use the existing claude.ai Pro subscription.

## Decision

**Do not build in-app model calls.** Ship `FA-CAP-206` instead: a button that generates a structured
markdown document containing all current and historical portfolio data, downloaded to `~/Downloads`
and pasted into a chat session by hand.

## Rationale

The blocker is structural, not technical.

**A claude.ai Pro subscription and the Anthropic API are separate products.** Pro covers the chat
surfaces — claude.ai, desktop, mobile, Claude Code. It does not include API access, and there is no
supported way for a local Next.js app to authenticate as "this user, on Pro." Any in-app call would
require a separately billed API key.

Given that, the trade is: pay separately and store an API key inside an app that already holds a
bank credential, in exchange for saving a copy-paste — against an analysis run occasionally, not
continuously.

## Consequences

**Positive**

- No API key in the application. `FA-TB-004` stays a **manual** boundary, which means no automated
  path exists by which portfolio data leaves the machine.
- No incremental cost.
- The export is model-agnostic and reusable — any analysis tool, any session, no integration to
  maintain.
- The operator sees exactly what is being sent, every time. With an in-app call, the payload would
  be invisible.

**Negative**

- Manual step in the loop; no scheduled or triggered analysis.
- The score is not stored in the app, so there is no scoring history alongside the position history.
- The prompt lives outside version control unless deliberately kept somewhere.

**Neutral**

- Reversible. If API access is ever separately provisioned, the export format is already the payload
  — the change would be transport only.

## Alternatives considered

| Option | Why rejected |
|---|---|
| Anthropic API key in the app | Separate billing; a second high-value credential in a database that already holds a bank credential; automates an exfiltration path that currently does not exist |
| Local model via Ollama | Viable and worth revisiting. Portfolio-resilience reasoning is exactly the kind of task where a small local model's output quality would need validating before it informed a retirement decision |
| Rule-based scoring in the app | Deterministic and auditable, but encodes one fixed model of resilience. The value of the LLM path was the reasoning, not the number |
