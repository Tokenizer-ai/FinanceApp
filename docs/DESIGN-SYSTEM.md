# Design system

**Status:** active · **Version:** 1.0.0 · **Updated:** 2026-08-16

The visual language is deliberately derivative of Monarch Money: calm surfaces, generous radius,
soft elevation, and typography that makes columns of money legible. The goal was an app that does
not feel like a hobby project when opened next to a commercial one.

---

## 1. Tokens

| Token | Value | Rationale |
|---|---|---|
| Canvas | Off-white (not `#fff`) | Lets white cards float; pure white on white has no depth |
| Surface | White cards | Content lives on cards, never directly on canvas |
| Elevation | Soft, low-opacity, large blur radius | Suggestion of depth, not a drop shadow |
| Corner radius | **16px** | Applied consistently — cards, inputs, pills, buttons |
| Typeface | **Inter** | Neutral, excellent at small sizes, has tabular figures |
| Numerals | **Tabular** | Non-negotiable: digits must align vertically in every money column |
| Accent | **Orange** | Reserved for the aggregate/total series. Not a general-purpose brand colour |
| Asset-class palette | One distinct hue per class | Applied consistently across the trend chart and breakdown widget |

Tokens are CSS custom properties; components reference variables, never literals. A hard-coded
colour in a component is a defect.

---

## 2. Colour semantics

| Use | Colour |
|---|---|
| Total / net worth series | Orange — one series only |
| Asset classes (stock, bond, cash, crypto, other) | Distinct hue each, stable across every chart |
| Positive / negative deltas | Conventional green / red, used sparingly |

The rule that matters: **orange means "the total."** If a second series takes it, the dashboard
stops being readable at a glance.

---

## 3. Component patterns

### Cards

The base unit. White surface, 16px radius, soft shadow, generous internal padding. Content is
grouped into cards before anything else is decided.

### Accordion groups

Applied on Accounts (grouped by account type) and Budget (grouped by category group). Each group
header carries a **subtotal**, so the collapsed state is still informative — that is the whole point.
A collapsed group that shows only a name wastes the interaction.

### View-scope pill

All / Cash / Investments / Debt. Cookie-backed, read server-side, filters aggregates before render.

**Current inconsistency:** only the Dashboard honours it. Reports, Transactions, and Portfolio show
the pill's state but ignore it, which is worse than not showing it. `FA-OPEN-002`.

### Widget grid

Four dashboard widgets — net worth, breakdown, trend, accounts — drag-and-drop reorderable, with
visibility toggles. Order and visibility persist **server-side** (ADR-0005), so the layout is a
property of the account, not the browser.

### Charts

| Chart | Type | Notes |
|---|---|---|
| Net worth trend | Multi-series line/area | One colour per asset class, total in orange |
| Breakdown | Proportional | Asset-class palette |
| Per-symbol value | Multi-line | One line per ticker |
| Cash flow (Reports) | Sankey | Node keys namespaced by level — see `FA-BUG-003` |

---

## 4. Dark mode

Requires **both**:

1. `color-scheme` declarations, so the user agent styles native controls correctly
2. Explicit global CSS rules for form controls

Omitting either produces unreadable inputs (`FA-BUG-004`). Test every new form control in dark mode
before shipping; the failure is invisible in light mode.

---

## 5. Typography rules

- Money always uses tabular figures. No exceptions, including inside charts and tooltips.
- Numbers right-align in tables; labels left-align.
- Subtotals are visually distinguished from line items by weight, not by colour alone.

---

## 6. Adding UI — checklist

- [ ] Colours come from CSS variables, no literals
- [ ] Radius 16px, matching existing cards
- [ ] Money rendered through `formatCents`, tabular figures applied
- [ ] Dark mode verified, including every form control
- [ ] If it aggregates, it respects the view scope — or documents why not
- [ ] Grouped content collapses with an informative subtotal in the header
