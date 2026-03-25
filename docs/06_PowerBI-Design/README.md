# Power BI Design — PLCM Inventory Deep Dive

## Report Configuration

- **Theme**: Stryker custom theme (`Stryker_Theme12518501200577214.json`)
- **Base Theme**: CY24SU10
- **Custom Visuals**: HTML Content (`htmlContent443BE3AD55E043BF878BED274D3A6855`)
- **Bookmarks**: 17 bookmarks for navigation and view toggling
- **Report Filters**: DeleteFlag (Dim_GIM), Business Unit (Dim_GIM — inverted selection)

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

Used in the PLCM Playbook tooltip page to render styled HTML cards showing:

- Activity name and detail
- Role and responsibility type badge
- Styled with Segoe UI font and PLM Blue accent (`#0078D4`)

## Dynamic KPI Pattern

The `Dynamic Sales KPI` measure uses a slicer on `Dim_KPI[KPI]` to switch between:

- **Revenue** → `[Revenue]`
- **Units** → `[Units Sold]`
- **COGS** → `[COGS]`
