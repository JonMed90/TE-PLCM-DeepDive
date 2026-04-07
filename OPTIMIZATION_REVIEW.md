# Data Model Optimization Review

## Scope Reviewed

- Semantic model metadata (`model.tmdl`, `relationships.tmdl`)
- Core fact/dimension tables (`Fact_Sales`, `Fact_Inventory`, `Fact_ConsolidatedList`, `Dim_GIM`, `Dim_Calendar`, `Dim_Regions`, `Budget`)
- Core Power Query transformations (`expressions.tmdl`)
- Core measures (`_Measures.tmdl`)

---

## Executive Summary

The model is functional and already follows many good practices (centralized measures table, explicit date dimension, hidden technical keys, and consolidated sales fact).

The biggest optimization opportunity is to move from a **partially star-like model with fact-to-fact joins** to a **clean star schema with conformed dimensions**. This will reduce ambiguity, improve DAX reliability, and make refresh/performance tuning much easier.

Top priorities:

1. Remove direct relationships from `Fact_Sales` and `Fact_Inventory` to `Fact_ConsolidatedList`.
2. Normalize region mapping before joining to `Dim_Regions` (there are currently ordering issues in the M steps).
3. Ensure date and numeric types are correctly typed in source facts (especially Consolidated List date columns).
4. Eliminate model-level settings that conflict with the actual storage mode and schema intent.

---

## Detailed Findings & Recommendations

## 1) Remove fact-to-fact relationships (highest priority)

### What I observed

`relationships.tmdl` includes:

- `Fact_Sales[ItemId] -> Fact_ConsolidatedList[GIM_ID (Hide)]`
- `Fact_Inventory[ItemId] -> Fact_ConsolidatedList[GIM_ID (Hide)]`

This creates a non-standard pattern where one fact can filter another directly.

### Why this matters

- Increases filter-path ambiguity.
- Can produce unexpected totals when slicers are applied from multiple fact sources.
- Makes measures harder to reason about and maintain.

### Recommendation

- Keep `Dim_GIM` as the conformed product dimension.
- Remove fact-to-fact relationships.
- If users need “in consolidated list vs not” analytics, create a small bridge dimension such as `Dim_ExitListStatus` keyed by `ItemId`, or enrich `Dim_GIM` with an exit-list flag.

Expected benefits: better semantic clarity, fewer DAX edge cases, and cleaner query plans.

---

## 2) Fix region standardization order before dimension merge

### What I observed

- `Fact_Inventory` merges to `Dim_Regions` and only afterwards replaces `EUROPE -> EMEA`.
- `DemantraDemand` normalizes `EUROPE/EEMEA` before being consumed in `Fact_Sales`, but `Historical Sales` only replaces empty region with `UNKNOWN`.

### Why this matters

If normalization happens after lookup expansion (or inconsistently across inputs), region keys can be null/misaligned and produce silent filtering gaps.

### Recommendation

- Standardize region text in each source query before dimension joins.
- Create one canonical reusable mapping step/function and apply across `DemantraDemand`, `Historical Sales`, and `Fact_Inventory`.
- Add a validation query that surfaces unmatched region values.

Expected benefits: fewer orphan keys, more reliable regional slicing.

---

## 3) Convert string dates in `Fact_ConsolidatedList` into typed date columns

### What I observed

`Fact_ConsolidatedList` stores fields like `LTS Date` and `Date Submitted` as `string`.

### Why this matters

- Limits time intelligence and date comparisons.
- Forces expensive runtime parsing (or prevents it entirely in visuals/measures).

### Recommendation

- Parse to `date` in Power Query with locale-safe conversion.
- Keep original text only if needed for audit display.
- Connect typed dates to `Dim_Calendar` via role-playing dates if analysis requires trend tracking by submitted/LTS timing.

Expected benefits: better time-based analytics and cleaner DAX.

---

## 4) Clean up model setting mismatch (`defaultMode: directQuery`)

### What I observed

`model.tmdl` sets `defaultMode: directQuery` while table partitions are consistently `mode: import`.

### Why this matters

Even when behavior is currently import-based, this mismatch is confusing and increases risk when future tables are added.

### Recommendation

- Set `defaultMode` to import (or explicitly document why directQuery is retained intentionally).
- Add a short modeling convention in docs so new tables follow the intended mode.

Expected benefits: governance clarity and fewer accidental modeling errors.

---

## 5) Simplify BU-to-budget logic and avoid relationship confusion

### What I observed

Budget uses a small DATATABLE and measures already use `TREATAS(VALUES(Dim_GIM[Business Unit]), Budget[BU])` for mapping.

### Why this matters

The measure pattern is good, but if a bidirectional model relationship is used in parallel, behavior can become hard to predict.

### Recommendation

- Prefer one strategy: either no physical relationship + `TREATAS`, or a single-direction one-to-many relationship from Budget to a proper BU dimension.
- Consider introducing `Dim_BusinessUnit` and connecting both `Dim_GIM` and `Budget` to it.

Expected benefits: deterministic filter propagation and easier model reasoning.

---

## 6) Tighten time-intelligence base measures for robustness

### What I observed

TTM measures compute EndDate via `MAX(Fact_Sales[Date])` under `ALL()` with scenario filter. This is valid but global.

### Recommendation

- Consider anchoring to the current filter context where needed (e.g., by BU/region) or clearly naming global variants as `TTM Revenue (Global Last Actual Date)`.
- Add a date coverage guard measure (e.g., if missing actual data then return blank with diagnostic).

Expected benefits: prevents interpretation drift when users expect context-specific trailing windows.

---

## 7) Data quality and cardinality guardrails

### Recommendation

Add lightweight validation tables/measures for:

- Duplicate `ItemId` in `Dim_GIM`.
- Unmatched `ItemId` between facts and `Dim_GIM`.
- Unmatched region values prior to keying into `Dim_Regions`.
- Unexpected scenario values outside `AC/FC`.

These checks can be hidden from report users but are extremely useful for deployment confidence.

---

## Proposed Implementation Plan (Phased)

### Phase 1 — Low-risk/high-impact

1. Normalize region mapping before joins.
2. Convert consolidated-list date strings to typed dates.
3. Align `defaultMode` with import behavior.

### Phase 2 — Structural improvements

4. Remove fact-to-fact relationships.
5. Add bridge/conformed dimension for exit-list membership.
6. Rationalize Budget filtering through conformed BU dimension.

### Phase 3 — Reliability hardening

7. Add data quality validation artifacts.
8. Add naming conventions for global vs context-relative date window measures.

---

## Success Metrics to Track

- % of fact rows with null/missing region key after mapping.
- Count of unmatched `ItemId` by fact table.
- DAX query duration on high-traffic pages (before/after model cleanup).
- Refresh duration and compressed model size after schema simplification.

---

## Final Note

This model already contains solid foundations; most gains now come from **schema hygiene and consistency** rather than major redesign. Prioritizing relationship cleanup and conformed dimension usage should deliver the largest reliability and maintainability improvements with minimal report redesign.
