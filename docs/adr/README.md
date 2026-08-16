# Architecture decision records

Each ADR captures one decision: the context that forced it, the options weighed, what was chosen,
and what it costs. ADRs are immutable once accepted — a reversal is a **new** ADR that supersedes
the old one, never an edit.

Format: [Michael Nygard's template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

| # | Decision | Status |
|---|---|---|
| [0001](0001-local-first-sqlite.md) | Local-first architecture on SQLite | Accepted |
| [0002](0002-integer-cents.md) | All money as integer cents with a strict render guard | Accepted |
| [0003](0003-holdings-merge-option-a.md) | Option A holdings merge semantics | Accepted |
| [0004](0004-daily-holdings-snapshots.md) | Daily holdings snapshots as position history | Accepted |
| [0005](0005-server-persisted-dashboard-layout.md) | Server-persisted dashboard layout | Accepted |
| [0006](0006-no-in-app-llm-analysis.md) | No in-app LLM analysis; export-and-paste instead | Accepted |

## Writing a new one

```
docs/adr/NNNN-kebab-case-title.md
```

Sections: Status · Context · Decision · Consequences (positive, negative, neutral) · Alternatives
considered. Number sequentially; never reuse. Branch `adr/NNNN-slug`, commit `adr(NNNN): …`.
