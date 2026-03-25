# Release Notes — PLCM Inventory Deep Dive

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

- 14 tables (7 dimensions, 4 fact tables, 3 reference/measures tables)
- 10 relationships including bidirectional cross-filters
- 30+ DAX measures covering sales, inventory, margins, TTM, and DSI
- Import mode with Power Query transformations

### Data Sources

- Azure Synapse Analytics (GIM, Sales, Demand)
- SharePoint Online (PLCM Tracker_LIVE.xlsx)
- Power BI Dataflows (Inventory)
- Power Platform Dataflows (Playbook RACI)

### Theme & Visuals

- Stryker custom theme applied
- HTML Content custom visual for playbook tooltips
- 17 bookmarks for navigation
