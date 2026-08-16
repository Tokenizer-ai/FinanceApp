# Contributing

Single-maintainer project. These conventions exist so that a change made six months from now is
still legible — and so that AI-assisted sessions produce consistent artifacts rather than a new
style each time.

## Working agreement: plan before build

1. **Plan mode.** Analyse, propose, enumerate trade-offs. No files written, no builds run.
2. **Explicit release.** The maintainer releases to build mode by saying so.
3. **Build.** Implement exactly what was agreed. Surprises go back to step 1.

This is not ceremony. Every incident in the defect ledger that cost more than an hour traces to a
change made without a plan step.

## Branching

| Branch | Purpose |
|---|---|
| `main` | Always coherent. Documentation here describes the app as it actually is. |
| `feat/<slug>` | New capability documentation |
| `fix/<slug>` | Corrections to existing docs |
| `verify/<id>` | Clearing a `V-*` item against live source |
| `adr/<nnnn>-<slug>` | A new architecture decision record |

## Commits

Conventional Commits, with the stable ID in the scope when one applies.

```
<type>(<scope>): <imperative summary>

<body — why, not what>

Refs: FA-CAP-206, V-002
```

| Type | Use |
|---|---|
| `feat` | New capability documented |
| `fix` | Corrected an inaccuracy |
| `docs` | Prose, formatting, structure |
| `adr` | Architecture decision record |
| `verify` | Cleared or updated a verify-ledger item |
| `chore` | Tooling, CI, meta |

Examples:

```
feat(FA-CAP-206): document analysis markdown export
verify(V-007): confirm holdings_snapshots DDL against live schema
fix(FA-DQ-001): correct owned/unvested split figures
adr(0006): record no-in-app-LLM decision and accepted alternative
```

## Stable IDs

IDs are permanent. Never renumber, never reuse. When something is removed, mark it superseded and
leave the ID in place with a pointer.

| Prefix | Domain | Assigned in |
|---|---|---|
| `FA-CAP-*` | Capabilities | `docs/FEATURES.md` |
| `FA-DM-*` | Tables | `docs/DATA-MODEL.md` |
| `FA-INV-*` | Invariants | `docs/DATA-MODEL.md` |
| `FA-BUG-*` | Resolved defects | `docs/TROUBLESHOOTING.md` |
| `FA-OPEN-*` | Open gaps | `docs/ROADMAP.md` |
| `FA-DQ-*` | Provider data-quality traps | `docs/SIMPLEFIN-INTEGRATION.md` |
| `FA-TB-*` | Trust boundaries | `docs/ARCHITECTURE.md` |
| `V-*` | Unverified claims | `docs/VERIFY-LEDGER.md` |

Numbering: capabilities use hundreds by domain (100 sync, 200 portfolio, 300 dashboard, 400
pages, 500 runtime). Leave gaps.

## Verify flags

Any claim not read directly from current source gets **[VERIFY]** inline plus a row in
`docs/VERIFY-LEDGER.md` containing a one-line command that settles it. A `verify/` branch that
clears an item must, in the same commit, either confirm the claim or correct it — never delete the
row silently.

## Documentation style

- **Engineering register.** Declarative, specific, no marketing voice.
- **Tables over paragraphs** for anything enumerable.
- **Mermaid** for diagrams — it renders in GitHub and in Obsidian, which is the point.
- **Code verbatim** when reproducing schema or interfaces. Paraphrased DDL is a defect vector.
- **Concede limitations plainly.** "History cannot be backfilled" is more useful than an omission.
- Line length 100 for prose; tables and code blocks exempt (`.markdownlint.json`).

## Vault parity

`vault/Finance App — Capabilities and Structure.md` is the consolidated note that lives in Obsidian.
When a `docs/` file changes materially, update the corresponding section of the vault note in the
same PR, and bump its `version` and `updated` front-matter. The two must not drift.

## Pull requests

Even solo. The PR body is the change record.

- Fill in the template.
- Verify-ledger delta stated explicitly (opened / cleared / unchanged).
- CI must pass (link check, markdownlint, Mermaid parse).
- Squash-merge; the squash message is the commit convention above.

## Releases

Documentation is versioned semantically against its own contract, not the app's.

| Bump | Meaning |
|---|---|
| Major | Restructure — files moved, ID scheme changed |
| Minor | New documented capability or ADR |
| Patch | Corrections, verify-ledger clearing, prose |

Tag as `docs-vX.Y.Z` and add a `CHANGELOG.md` entry.
