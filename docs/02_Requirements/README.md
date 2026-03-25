# Requirements — PLCM Inventory Deep Dive

## Functional Requirements

1. **GIM Product Visibility** — Display full GIM item master with PLCM status, lifecycle codes, stocking types, and regional decisions
2. **Sales Analysis** — Historical actuals and forecasts by BU, Brand, SubBrand, and Region with dynamic KPI selection (Revenue, Units, COGS)
3. **Demand Forecasting** — Next 12-month demand units and trailing 12-month trend analysis
4. **Inventory Snapshot** — On-hand quantity, statutory cost, and management cost by site, warehouse, and region
5. **Exit Tracking** — Consolidated PLCM phaseout list with MDM request, ECR, LTS date, and batch status
6. **Margin Analysis** — Trailing 12M gross profit and profit margin vs. budgeted growth margin
7. **PLCM Playbook** — RACI matrix with phase-based activities and role accountability
8. **Dynamic Decisions** — Brand-level and SubBrand-level global PLCM decision rollups
9. **DSI Calculation** — Days Sales in Inventory from statutory cost and TTM COGS

## Non-Functional Requirements

- Data refresh on a scheduled cadence (Import mode)
- Stryker-branded theme applied across all visuals
- Report-level filter on `DeleteFlag` and `Business Unit`
- Bookmark-based navigation between playbook views
