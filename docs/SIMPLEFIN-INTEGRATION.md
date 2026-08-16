# SimpleFIN integration

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

SimpleFIN Bridge is the sole account-aggregation provider. It supplies accounts, transactions, and
— through an undocumented extension — investment holdings.

---

## 1. Connection flow

```mermaid
sequenceDiagram
    participant U as User
    participant S as Settings page
    participant A as Server action
    participant B as SimpleFIN Bridge
    participant D as SQLite

    U->>S: Paste base64 setup token
    S->>A: claim(token)
    A->>A: base64-decode → claim URL
    A->>B: POST claim URL  (token consumed — single use)
    B-->>A: Access URL (embeds Basic auth)
    A->>D: settings.simplefinAccessUrl = <access URL>
    Note over A,D: Setup token discarded

    U->>S: Sync now  (or app open if stale > 1h)
    A->>A: Extract credentials from URL
    A->>B: GET /accounts?pending=1&start-date=<unix>  + Authorization: Basic
    B-->>A: accounts[] · transactions[] · holdings[] · errors[]
    A->>D: upsert accounts → transactions → holdings
    A->>D: prices → snapshot → sync_log
```

**Setup steps for the operator:**

1. Create an account at the bridge (`beta-bridge.simplefin.org` or another instance) and link banks
   through their flow.
2. Generate a **setup token** — a base64 blob.
3. Settings → SimpleFIN → paste → Connect.
4. Sync now, or reopen the app.

**Testing without a real bank.** SimpleFIN publishes a demo token (base64 of their demo claim URL).
Pasting it claims and syncs fake accounts, which validates the entire pipeline before real
credentials are involved.

---

## 2. Hard constraints

| Constraint | Consequence |
|---|---|
| **Setup tokens are strictly single-use** | The claim consumes the token. A failed or partial claim requires a *fresh* token from the bridge — retrying the old one returns an error |
| **The access URL is a credential** | It embeds Basic auth. It lives in the SQLite settings table at rest. Treat the DB file accordingly |
| **Claim happens server-side** | The Next.js server needs outbound HTTPS to the bridge. No CORS surface, and no browser ever holds the credential |
| **History depth is bank-dependent** | First sync typically returns ~90 days. Deeper history requires the CSV import wizard (`FA-CAP-105`) |

### `FA-BUG-001` — credentials in the URL

The access URL arrives with inline Basic auth (`https://user:pass@host/...`). Passing that URL
straight to `fetch` did not authenticate. The fix extracts the credentials and sends them as a
proper `Authorization: Basic` header, requesting a credential-stripped URL. Any new call path to the
bridge must do the same — this is not handled implicitly.

---

## 3. Holdings — the undocumented extension

`/accounts` may include a `holdings` array per account. Nine fields, all optional except `id`:

```ts
interface SimpleFinHolding {
  id: string;
  created?: number;
  currency?: string;
  cost_basis?: string;
  description?: string;
  market_value?: string;
  purchase_price?: string;
  shares?: string;
  symbol?: string;
}
```

Normalised at the boundary into the provider-agnostic shape:

```ts
export interface ProviderHolding {
  externalId: string;
  accountExternalId: string;
  ticker: string;
  description?: string;
  /** Decimal string; MAY be fractional (e.g. "100.03"). Stored as text. */
  shares: string;
  /** Total cost basis in integer cents. */
  costBasisCents: number;
  /** Provider-reported total market value in integer cents, if given. */
  marketValueCents: number | null;
  /** Provider-reported purchase price in integer cents, if given. */
  purchasePriceCents: number | null;
  currency: string | null;
  createdAtUnixSeconds: number | null;
}
```

Money arrives as **strings** and is converted with `parseCents()` — never `parseFloat`. Shares stay
text (`FA-INV-002`).

Sync telemetry adds `holdingsSynced?: number` to `RunSyncResult`.

---

## 4. Merge semantics — Option A (ADR-0003)

> On accounts the provider reports holdings for, **provider data replaces** local holdings.
> On accounts the provider does not report holdings for, **manual holdings are preserved** untouched.

```mermaid
flowchart TD
    A[Sync returns account] --> B{holdings[] present<br/>for this account?}
    B -->|Yes| C[Delete local holdings for account]
    C --> D[Insert provider rows, source='simplefin']
    B -->|No| E[Leave local holdings untouched]
    D --> F[Snapshot]
    E --> F

    style C fill:#e76f51,color:#fff
    style E fill:#2a9d8f,color:#fff
```

This is what lets linked brokerage positions auto-maintain while manually tracked assets survive
every sync.

**The trap it creates:** a manual `assetClass` correction on a *reporting* account is destroyed by
the next sync, because that account's rows are replaced wholesale. Corrections only persist on
non-reporting accounts. If a provider-reported position needs a permanent classification override,
it needs a design change, not a manual edit.

---

## 5. Data-quality traps

These are not hypothetical. All three were live simultaneously and together inverted a portfolio
allocation conclusion.

| ID | Trap | Observed impact | Mitigation |
|---|---|---|---|
| `FA-DQ-001` | Employer equity reported as **owned + unvested combined** | NET showed ~$226K against a true split of ~$72K owned / ~$154.6K unvested — a ~3× overstatement of actual exposure | Split manually. Never take a single-line employer-equity position at face value |
| `FA-DQ-002` | Asset class mislabelled | VAIPX tagged `stock`; it is an intermediate TIPS bond fund. Equity/fixed-income ratio wrong | Override `assetClass`; audit every new position on first appearance |
| `FA-DQ-003` | Account type mislabelled | A savings account typed as brokerage — corrupts scope filters and the net-worth breakdown | Audit account types after the first sync of any new institution |

**Standing rule.** Any allocation conclusion drawn from a fresh sync is provisional until
`FA-DQ-001`–`003` have been re-checked. The first analysis run against this app concluded the
portfolio was aggressively positioned; the corrected picture was roughly **15% aggressive / 85%
conservative** — the opposite. The app was reporting exactly what the provider sent. The provider
was wrong, and nothing in the pipeline noticed.

**Design implication worth considering:** a data-quality panel that flags positions whose asset
class was never manually confirmed, and accounts whose type has not been reviewed, would convert
these silent defects into visible ones. Not currently built.

---

## 6. Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| `SimpleFIN claim failed: HTTP 403` at connect | Setup token already used — they are single-use | Generate a fresh token from the bridge |
| `SimpleFIN request failed: HTTP 403` on sync | Stored access URL revoked, or bridge session expired | Reconnect with a new token |
| Bank-side messages in the sync log | Provider `errors[]` passed straight through — e.g. connection needs attention, re-authenticate | Resolve at the bridge, then re-sync |
| Sync succeeds, holdings empty | Institution does not report positions to SimpleFIN | Expected. Track manually (`FA-CAP-202`) — Option A preserves those rows |
| Sync succeeds, balances stale | `balance-date` is older than expected | Bridge-side refresh issue; check the bridge's account status |
| No sync on app open | Last sync under 1 hour old — `onlyIfStale=1` skipped it | Use "Sync now" |

Diagnostics:

```bash
tail -30 ~/Library/Logs/finance-app.log
sqlite3 data/finance.db "SELECT * FROM sync_log ORDER BY id DESC LIMIT 5;"
sqlite3 data/finance.db "SELECT COUNT(*) FROM holdings WHERE source='simplefin';"
```

Never paste the output of `SELECT value FROM settings WHERE key='simplefinAccessUrl'` anywhere. It
is a credential.

---

## 7. Rotation

1. Revoke the existing access at the bridge.
2. Generate a fresh setup token.
3. Settings → SimpleFIN → paste → Connect (overwrites `simplefinAccessUrl`).
4. Sync once; confirm the sync log is clean and account count is unchanged.
