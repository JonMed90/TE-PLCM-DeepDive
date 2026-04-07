# Changelog

All notable changes to the PLCM Inventory Deep Dive solution will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [2026-04-07] — E&O Integration, DAX Optimization & Repo Migration

### Added

- **Fact_E&O table**: New Excess & Obsolescence fact table sourced from Power Platform Dataflows (workspace `7e9a6bda`, dataflow `69e3d6cc`, entity `Fact_EO`)
- **E&O relationships**: `Fact_E&O.Region → Dim_Regions`, `Fact_E&O.ItemId → Dim_GIM`, `Fact_E&O.MonthEnding → Dim_Calendar`
- **E&O measures**: `E&O Total`, `E&O (Reserves)`, `E&O (Inventory)`, `E&O (Reserve Rate %)` in new `E&O` display folder
- **BLANK guards**: Added `IF(ISBLANK([Revenue]) || [Revenue] = 0, BLANK(), ...)` to `Budget Growth Margin %` and `Profit Margin minus Sum of Budgeted Growth Margin` to prevent misleading values when no revenue exists
- **Display folders**: Added `Demand`, `KPI Toggle`, `E&O` folders; moved `Next 12M Demand Units` to `Demand`

### Changed

- **Budget relationship**: Removed physical `Dim_GIM[Business Unit] → Budget[BU]` relationship and bidirectional filter; replaced with `TREATAS(VALUES(Dim_GIM[Business Unit]), Budget[BU])` in `Budget Growth Margin %` measure
- **Historical Sales source**: Changed from `PowerBI.Dataflows` to `PowerPlatform.Dataflows` connector (workspace `f4ac28b7`, dataflow `19ac5c01`)
- **DAX cleanup**: Removed unnecessary backtick blocks from simple one-line measures, removed dead code (unused VARs, commented-out lines), simplified `Forecast Sales - Start Date` to use `DATE()` instead of `DayinMonth` hack
- **DSI format**: Changed from `#,0` to `#,0.0` for decimal precision
- **Profit Margin format**: Changed from `0.00%` to `0.0%`
- **Folder rename**: Renamed project folder from `PLCM-Inventory-DeepDive` to `TE-PLCM-DeepDive`
- **Git remote**: Migrated from GitHub to Azure DevOps (`https://strykervsts-corp.visualstudio.com/BI%20Azure%20DevOps/_git/TE-PLCM-DeepDive`)
- **Removed legacy PBIX**: No longer maintaining `PLCM Deep Dive.pbix` — PBIP is the primary format

## [2026-03-25] — Post-Review Cleanup

### Changed

- **Dim_GIM summarizeBy**: Changed `packcontent`, `packagingunitofmeasure`, `cymarketingproductgroupcode`, and `Index` from `summarizeBy: sum` to `summarizeBy: none` — these are dimension attributes, not additive measures
- **Actual Sales - End Date**: Simplified measure by removing unused `DayinMonth` variable (dead code)
- **Profit Margin**: Removed commented-out formula line
- **README**: Updated data sources (Power Platform/BI Dataflows instead of Azure Synapse), corrected measure descriptions (TTM COGS, Gross Profit, Profit Margin), fixed relationship section to reflect current model, added missing measures
- **CHANGELOG**: Corrected entries that were reverted (dual storage mode, measure descriptions)

## [2026-03-25]

### Changed

- **DAX Performance**: Replaced `FILTER('Dim_Calendar', ...)` with `DATESBETWEEN` in `TTM Revenue` and `TTM Units` measures for storage engine optimization
- **TTM COGS**: Replaced `SUMX(Dim_GIM, [TTM Units] * Manufacturing Cost)` row iteration with `SUM(Fact_Sales[COGS])` using `DATESBETWEEN` — consistent anchor logic with other TTM measures
- **Data Type Fix**: Changed `Fact_Sales.ItemId` from `double` to `int64` to match `Dim_GIM.ItemId` and `Fact_Inventory.ItemId`, avoiding implicit type conversion on joins
- **Bidirectional Filter**: Removed `crossFilteringBehavior: bothDirections` from `Fact_ConsolidatedList → Dim_GIM` relationship to prevent ambiguous filter paths with other fact tables
- **Dynamic Calendar End Date**: Replaced hardcoded `#date(2030, 12, 1)` with `Date.EndOfYear(Date.AddYears(DateTime.LocalNow(), 3))` to auto-extend

### Added

- Display folders on all measures: Sales, Trailing 12M, Inventory, Profitability, PLCM

### Reverted

- **Dual Storage Mode**: Reverted `Dim_Calendar` and `Dim_Regions` from `dual` back to `import` — dual mode requires external datasource references, which local M queries don't have
- **Measure Descriptions**: Removed `description` property from all measures — not supported in TMDL at compatibility level 1600

### Initial

- Created README with solution overview, data model, measures, data sources, and folder structure
- Created documentation stubs for all `docs/` subfolders
- Created CHANGELOG

### Initial

- Power BI semantic model (14 tables, 10 relationships, 30+ DAX measures)
- Power BI report with Stryker theme, HTML Content custom visual, and 11 pages
- Data sources: Azure Synapse, SharePoint PLCM Tracker, Power BI Dataflows (Inventory), Power Platform Dataflows (Playbook)
- PLCM decision tracking at Brand and SubBrand level (Global Exit, Local Exit, Maintain, Out of Scope)
- RACI playbook with phase-based task assignments and HTML tooltip visualization
- Margin analysis with budgeted growth margin comparison by Business Unit
- PBIP format enabled for version control alongside legacy PBIX
