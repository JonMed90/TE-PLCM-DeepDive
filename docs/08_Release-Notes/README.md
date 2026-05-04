# Release Notes — PLCM Inventory Deep Dive

## [2026-04-07] — E&O Integration, DAX Optimization & Repo Migration

### Added

- **Excess and Obsolete** fact table sourced from Power Platform Dataflows (`Fact_EO`)
- **E&O relationships**: Item ID → Product, MonthEnding → Calendar, Region Index → Region
- **E&O measures**: `Excess and Obsolete Total`, `Reserves`, `Inventory`, `Reserve Rate %`
- **Exit Tracker E&O measure**: `Exit Excess and Obsolete Total`, `Exit E&O Reserve Rate %`
- **BLANK guards** on `Budget Gross Margin %` and `Margin Delta %` to prevent misleading values when no revenue exists
- **Display folders**: `Demand`, `KPI Toggle`, `Excess and Obsolete` folders
- **Data quality measures** (`_DQ_` folder): Duplicate ItemIDs, unmatched FK checks, invalid scenario validation
- **Monitoring measures** (`_Metrics_` folder): Null region percentage tracking

### Changed

- **Budget relationship**: Removed physical relationship; replaced with `TREATAS` virtual mapping in measure
- **Historical Sales source**: Migrated from `PowerBI.Dataflows` to `PowerPlatform.Dataflows` connector
- **DAX cleanup**: Removed unnecessary backtick blocks, dead code, simplified date logic
- **DSI format**: Changed from `#,0` to `#,0.0` for decimal precision
- **Profit margin format**: Changed from `0.00%` to `0.0%`
- **Git remote**: Migrated from GitHub to Azure DevOps
- **Removed legacy PBIX**: PBIP is the sole format

---

## [2026-03-25] — Post-Review Cleanup & Performance Optimization

### Changed

- **Product summarizeBy**: Changed `packcontent`, `packagingunitofmeasure`, etc. from `sum` to `none`
- **TTM measures**: Replaced `FILTER('Calendar', ...)` with `DATESBETWEEN` for storage engine optimization
- **TTM COGS**: Replaced `SUMX` row iteration with direct `SUM(Sales[COGS])` using `DATESBETWEEN`
- **Data type fix**: Changed `Sales[Item ID]` from `double` to `int64` to match Product/Inventory keys
- **Bidirectional filter**: Removed `bothDirections` from Exit Tracker → Product relationship
- **Calendar end date**: Replaced hardcoded `#date(2030,12,1)` with dynamic `Date.EndOfYear(Date.AddYears(DateTime.LocalNow(), 3))`

### Added

- Display folders on all measures: Sales, Trailing 12M, Inventory, Profitability, PLCM, etc.

---

## v1.0.0 — Initial Release

### Report Pages

- Landing Page with navigation hub
- GIM product master with PLCM status and lifecycle details
- Historical Sales with dynamic KPI toggle (Revenue, Units, COGS)
- Roadmap Regional view for regional PLCM decisions
- Demand forecasting with next 12-month projections
- Inventory Snapshot by region, site, and warehouse
- Exit Tracker for PLCM phaseout consolidated list
- Margins analysis with profit margin vs. budgeted growth margin
- PLCM Playbook RACI matrix with HTML tooltip cards
- Exec IBP executive summary

### Data Model

- 15 tables (7 dimensions, 4 fact tables, 4 reference/utility tables)
- 12 relationships (star schema, no fact-to-fact joins)
- 42 DAX measures covering sales, inventory, margins, TTM, DSI, E&O, and data quality
- Import mode with Power Query transformations

### Data Sources

- Power Platform Dataflows (GIM, Demantra, Consolidated List, Playbook, E&O)
- Power BI Dataflows (Calendar, Inventory, Historical Sales)

### Theme & Visuals

- Stryker custom theme applied
- HTML Content custom visual for playbook tooltips
- 17 bookmarks for navigation
