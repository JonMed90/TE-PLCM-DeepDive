# Power BI Design — PLCM Inventory Deep Dive

## Report Configuration

- **Theme**: Stryker custom theme (`Stryker_Theme12518501200577214.json`)
- **Base Theme**: CY24SU10
- **Custom Visuals**: HTML Content (`htmlContent443BE3AD55E043BF878BED274D3A6855`)
- **Bookmarks**: 17 bookmarks for navigation and view toggling
- **Report Filters**: DeleteFlag (Product), Business Unit (Product — inverted selection)

## Pages

| Page                  | Key Visuals & Interactions                                 |
| --------------------- | ---------------------------------------------------------- |
| Landing Page          | Navigation buttons to all report sections                  |
| 1) GIM                | GIM master table, PLCM status slicers, lifecycle filters   |
| 2) Historical Sales   | Line/bar charts with Dynamic Sales KPI toggle              |
| 2) Roadmap Regional   | Regional breakdown of sales and PLCM decisions             |
| 3) Demand             | Demantra demand forecast, next 12M projection visuals      |
| 4) Inventory Snapshot | Inventory by region/site/warehouse, QoH and statutory cost |
| 5) Exit Tracker       | Consolidated list table with phaseout details              |
| 6) Margins            | Profit margin vs. budget gauge/KPI cards by BU             |
| 7) PLCM Playbook      | RACI matrix, phase activities, HTML tooltip cards          |
| Exec IBP              | Executive summary visuals                                  |
| Playbook Tooltip      | Hidden — HTML card tooltip for playbook activity hover     |

## Custom Visual: HTML Content

Used in the PLCM Playbook tooltip page to render a **7-step chevron progress tracker** showing:

- Header bar with Business Unit, Brand, Catalog Number, ECR, and key dates
- Color-coded phase indicators with orange marker under active phase
- Phase objective text for contextual detail
- Styled with Segoe UI font and Stryker brand colors

## Dynamic KPI Pattern

The `Dynamic Sales KPI` measure uses a slicer on `_KPI[KPI]` to switch between:

- **Revenue** → `[Revenue]`
- **Units** → `[Units Sold]`
- **COGS** → `[COGS]`

## Measure Organization (Display Folders)

| Display Folder              | Purpose                                   |
| --------------------------- | ----------------------------------------- |
| Sales                       | Base revenue, COGS, units aggregations    |
| Sales\Trailing 12M          | TTM calculations and date anchors         |
| Inventory                   | On-hand, cost, and DSI measures           |
| KPI Toggle                  | Dynamic KPI switch measures               |
| GIM                         | Product count measure                     |
| Demand                      | Forecast date ranges and 12M demand       |
| Profitability               | Gross profit, margin %, budget comparison |
| Excess and Obsolete         | E&O reserves, inventory, reserve rate     |
| PLCM                        | Exit tracker SKU count                    |
| PLCM\Exit Tracker Sales     | TTM sales metrics for exit items          |
| PLCM\Exit Tracker Inventory | Inventory/DSI/E&O for exit items          |
| PLCM Stage Phase            | HTML tracker and RACI department measures |
| _DQ_ (hidden)               | Data quality validation measures          |
| _Metrics_ (hidden)          | Monitoring/null percentage measures       |
