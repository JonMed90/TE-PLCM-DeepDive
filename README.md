# PLCM Inventory Deep Dive

## Purpose

Power BI analytics solution for the **Trauma & Extremities (T&E) Product Life Cycle Management (PLCM)** team. The report provides deep-dive visibility into T&E SKUs across inventory on hand, historical sales, demand forecasts, GIM product master details, profit margins, and PLCM playbook tracking. It supports data-driven PLCM decisions (Exit, Maintain, Out of Scope) at the Brand and SubBrand level across global regions.

## Platforms

| Platform                           | Usage                                                                            |
| ---------------------------------- | -------------------------------------------------------------------------------- |
| **Power BI** (`.pbip`)     | Semantic model (15 tables, 42 DAX measures, 12 relationships) and 11-page report |
| **Power Platform Dataflows** | GIM product master, Demantra demand, Consolidated List, Playbook RACI, E&O data  |
| **Power BI Dataflows**       | Calendar, inventory snapshot, and historical sales data                          |

## Key Features

- **GIM Product Master** — Full GIM item catalog with lifecycle codes, stocking types, and brand/subbrand classification
- **Historical Sales** — Actuals (AC) by Business Unit, Brand, SubBrand, and Region with dynamic KPI toggle (Revenue / Units / COGS)
- **Demand Forecasting** — Next 12-month demand units from Demantra forecast (FC) by Business Unit, Brand, SubBrand, and Region with dynamic KPI toggle
- **Inventory Snapshot** — On-hand quantity, extended statutory & management cost by site, warehouse, and subinventory
- **Exit Tracker** — PLCM phaseout consolidated list with MDM/ECR tracking, LTS dates, batch status, and phase tracking
- **Margin Analysis** — Actual gross margin vs. budgeted growth margin by Business Unit with BLANK-guarded comparisons
- **PLCM Playbook** — RACI matrix with 7-phase task assignments, accountability tracking, and HTML chevron progress tracker
- **Excess & Obsolescence (E&O)** — Reserves, inventory, and reserve rate analysis by region and product (both portfolio-wide and exit-scoped)
- **DSI Calculation** — Days Sales in Inventory computed from statutory cost and TTM COGS
- **Exit Tracker Metrics** — Dedicated TTM revenue, COGS, units, gross margin, demand, inventory, and DSI for phaseout SKUs
- **Data Quality Monitoring** — Hidden measures tracking duplicate keys, unmatched FKs, and null region percentages

## Report Pages

| #  | Page                  | Description                                                  |
| -- | --------------------- | ------------------------------------------------------------ |
| — | Landing Page          | Navigation hub and report overview                           |
| 1  | GIM                   | GIM product master details, PLCM status, lifecycle codes     |
| 2  | Historical Sales      | Actuals vs. forecast trends by BU/Brand/SubBrand             |
| 3  | Demand                | Demantra demand forecast and next 12-month projections       |
| 4  | Inventory Snapshot    | On-hand inventory by region, site type, warehouse            |
| 5  | Exit Tracker          | PLCM phaseout consolidated list with ECR and MDM tracking    |
| 6  | Margins               | Trailing 12M revenue, gross profit, profit margin vs. budget |
| 7  | PLCM Playbook         | RACI matrix — phases, activities, and role assignments      |
| — | Exec IBP              | Executive IBP summary                                        |
| — | PLCM Playbook Tooltip | HTML tooltip card for playbook activity details (hidden)     |

## Data Model

### Tables (15)

| Table                    | Type      | Mode       | Source                                                           |
| ------------------------ | --------- | ---------- | ---------------------------------------------------------------- |
| `Product`              | Dimension | Import     | Power BI Dataflow —`Dim_GIMItem` (workspace `f4ac28b7`)     |
| `Calendar`             | Dimension | Import     | Power BI Dataflow —`Calendar` entity (workspace `f4ac28b7`) |
| `Region`               | Dimension | Import     | Static region lookup (US, EMEA, ASPAC, LATAM, etc.)              |
| `_KPI`                 | Dimension | Import     | Static KPI selector (Revenue, Units, COGS)                       |
| `Phase`                | Dimension | Import     | Power Platform Dataflow —`dim_Phase`                          |
| `Phase Activity`       | Dimension | Import     | Power Platform Dataflow —`dim_PhaseActivity`                  |
| `Role`                 | Dimension | Import     | Power Platform Dataflow —`dim_Role`                           |
| `Sales`                | Fact      | Import     | Combined `DemantraDemand` (FC) + `Historical Sales` (AC)     |
| `Inventory`            | Fact      | Import     | Power BI Dataflow —`fact_Inventory_FG_Summary`                |
| `Exit Tracker`         | Fact      | Import     | Power Platform Dataflow —`Fact_ConsolidatedList`              |
| `Task Assignment`      | Fact      | Import     | Power Platform Dataflow —`fact_Assignments`                   |
| `Excess and Obsolete`  | Fact      | Import     | Power Platform Dataflow —`Fact_EO`                            |
| `_Budget`              | Reference | Calculated | DAX `DATATABLE` — BU budgeted growth margin %                 |
| `_Playbook Navigation` | Reference | Calculated | DAX `DATATABLE` — playbook tab navigation                     |
| `_Measures`            | Measures  | Calculated | Central measures table (42 DAX measures)                         |

### Relationships (12)

```text
Sales[Date]                       → Calendar[Date]
Sales[Item ID]                    → Product[Item ID]
Sales[Region Index]               → Region[Index]
Inventory[Item ID]                → Product[Item ID]
Inventory[Region Index]           → Region[Index]
Excess and Obsolete[Item ID]      → Product[Item ID]
Excess and Obsolete[MonthEnding]  → Calendar[Date]
Excess and Obsolete[Region Index] → Region[Index]
Exit Tracker[Phase ID]            → Phase[Phase ID]
Task Assignment[Role Name]        → Role[Role Name]
Task Assignment[Phase Activity ID]→ Phase Activity[Phase Activity ID]
Task Assignment[Phase ID]         → Phase[Phase ID]
```

> **Note:** The `_Budget` table has no physical relationship. `Budget Gross Margin %` uses `TREATAS(VALUES(Product[Business Unit]), _Budget[Business Unit])` to propagate filters virtually.

### Key Measures (42 total)

| Measure                                | Display Folder              | Description                                                        |
| -------------------------------------- | --------------------------- | ------------------------------------------------------------------ |
| `Revenue`                            | Sales                       | `SUM(Sales[Revenue])`                                            |
| `Units Sold`                         | Sales                       | `SUM(Sales[Quantity])`                                           |
| `COGS`                               | Sales                       | `SUM(Sales[COGS])`                                               |
| `Actual Revenue`                     | Sales                       | Revenue filtered to Scenario = AC                                  |
| `Actual Units Sold`                  | Sales                       | Units filtered to Scenario = AC                                    |
| `Actual COGS`                        | Sales                       | COGS filtered to Scenario = AC                                     |
| `TTM Revenue`                        | Sales\Trailing 12M          | Trailing 12-month revenue from last actual sales date              |
| `TTM Units`                          | Sales\Trailing 12M          | Trailing 12-month units from last actual sales date                |
| `TTM COGS`                           | Sales\Trailing 12M          | Trailing 12-month COGS from last actual sales date                 |
| `TTM Start Date`                     | Sales\Trailing 12M          | 12 months prior to TTM End Date                                    |
| `TTM End Date`                       | Sales\Trailing 12M          | Last actual sales date (global, unfiltered)                        |
| `AC - Start Date`                    | Sales\Trailing 12M          | First actual sales date in context                                 |
| `AC - End Date`                      | Sales\Trailing 12M          | Last actual sales date in context                                  |
| `Inventory Qty on Hand`              | Inventory                   | `SUM(Inventory[Quantity On Hand])`                               |
| `Ext Statutory Cost`                 | Inventory                   | `SUM(Inventory[Ext Statutory Cost USD])`                         |
| `Ext Management Cost`                | Inventory                   | `SUM(Inventory[Ext Management Cost USD])`                        |
| `Days Sales of Inventory`            | Inventory                   | `(Ext Statutory Cost / TTM COGS) × 365`                         |
| `Dynamic Sales KPI`                  | KPI Toggle                  | Switches between Revenue, Units, COGS based on `_KPI` slicer     |
| `Dynamic Sales KPI Selection`        | KPI Toggle                  | Returns the selected KPI name                                      |
| `# Product SKUs`                     | GIM                         | `DISTINCTCOUNT(Product[Item ID])`                                |
| `FC - Start Date`                    | Demand                      | First forecast date                                                |
| `FC - End Date`                      | Demand                      | Last forecast date                                                 |
| `Next 12M Demand Units`              | Demand                      | Forecast units for next 12 months from first FC date               |
| `Actual Gross Profit`                | Profitability               | `Actual Revenue − Actual COGS`                                  |
| `Actual Gross Margin %`              | Profitability               | `Actual Gross Profit / Actual Revenue`                           |
| `Budget Gross Margin %`              | Profitability               | Target margin by BU via `TREATAS` (BLANK-guarded)                |
| `Margin Delta %`                     | Profitability               | `Actual Gross Margin % − Budget Gross Margin %` (BLANK-guarded) |
| `Excess and Obsolete Total`          | Excess and Obsolete         | `SUM(Excess and Obsolete[Amount])` (hidden)                      |
| `Excess and Obsolete Reserves`       | Excess and Obsolete         | E&O filtered to Reserves account                                   |
| `Excess and Obsolete Inventory`      | Excess and Obsolete         | E&O filtered to Inventory account                                  |
| `Excess and Obsolete Reserve Rate %` | Excess and Obsolete         | `Reserves / Inventory`                                           |
| `# Exit Tracker SKUs`                | PLCM                        | `DISTINCTCOUNT(Exit Tracker[GIM_ID (Hide)])`                     |
| `Exit TTM Revenue`                   | PLCM\Exit Tracker Sales     | TTM Revenue for Exit Tracker items via `TREATAS`                 |
| `Exit TTM COGS`                      | PLCM\Exit Tracker Sales     | TTM COGS for Exit Tracker items via `TREATAS`                    |
| `Exit TTM Units`                     | PLCM\Exit Tracker Sales     | TTM Units for Exit Tracker items via `TREATAS`                   |
| `Exit Gross Profit`                  | PLCM\Exit Tracker Sales     | `Exit TTM Revenue − Exit TTM COGS`                              |
| `Exit Gross Margin %`                | PLCM\Exit Tracker Sales     | `Exit Gross Profit / Exit TTM Revenue`                           |
| `Exit Next 12M Demand Units`         | PLCM\Exit Tracker Sales     | Demand for Exit Tracker items                                      |
| `Exit Inventory Qty on Hand`         | PLCM\Exit Tracker Inventory | Inventory for Exit Tracker items via `TREATAS`                   |
| `Exit Ext Statutory Cost`            | PLCM\Exit Tracker Inventory | Statutory cost for Exit Tracker items                              |
| `Exit Days Sales of Inventory`       | PLCM\Exit Tracker Inventory | DSI for Exit Tracker items                                         |
| `Phase Tracker HTML`                 | PLCM Stage Phase            | HTML chevron progress tracker for playbook tooltip                 |

> **Data Quality Measures** (hidden `_DQ_` folder): Duplicate ItemIDs, unmatched FK checks, invalid scenario validation.
> **Monitoring Measures** (hidden `_Metrics_` folder): Null region percentage tracking for Sales and Inventory.

## Data Sources

| Source                                    | Connection                        | Objects                                                                                    |
| ----------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------ |
| Power Platform Dataflows (GIM & Demantra) | PowerPlatform.Dataflows connector | `Dim_GIMItem`, `DemantraCloud Dataflow` (workspace `7370e662`)                       |
| Power Platform Dataflows (Sales)          | PowerPlatform.Dataflows connector | `Fact_Sales_Summary` (workspace `f4ac28b7`, dataflow `19ac5c01`)                     |
| Power BI Dataflows (Calendar & Inventory) | PowerPlatform.Dataflows connector | `Calendar`, `fact_Inventory_FG_Summary` (workspace `f4ac28b7`)                       |
| Power Platform Dataflows (Consolidated)   | PowerPlatform.Dataflows connector | `Fact_ConsolidatedList` (workspace `7e9a6bda`, dataflow `0da45554`)                  |
| Power Platform Dataflows (Playbook)       | PowerPlatform.Dataflows connector | `dim_Phase`, `dim_PhaseActivity`, `dim_Role`, `fact_Assignments` (ws `7e9a6bda`) |
| Power Platform Dataflows (E&O)            | PowerPlatform.Dataflows connector | `Fact_EO` (workspace `7e9a6bda`, dataflow `69e3d6cc`)                                |

## Folder Structure

```text
TE-PLCM-DeepDive/
├── README.md                                      # This file
├── CHANGELOG.md                                   # Release history
├── OPTIMIZATION_REVIEW.md                         # Data model optimization notes
├── PLCM Deep Dive.pbip                            # PBIP project entry point
├── docs/                                          # Documentation
│   ├── 01_Business-Overview/
│   ├── 02_Requirements/
│   ├── 03_Process-Flow/
│   ├── 04_Architecture/
│   ├── 05_Data-Model/
│   ├── 06_PowerBI-Design/
│   ├── 07_Testing/
│   └── 08_Release-Notes/
├── PLCM Deep Dive.SemanticModel/                  # Semantic model (TMDL)
│   ├── definition/
│   │   ├── tables/                                # 15 table definitions
│   │   │   ├── _Measures.tmdl                     # Central measures table (42 measures)
│   │   │   ├── _Budget.tmdl                       # BU budget margins (calculated)
│   │   │   ├── _KPI.tmdl                          # KPI selector (static)
│   │   │   ├── _Playbook Navigation.tmdl          # Tab navigation (calculated)
│   │   │   ├── Calendar.tmdl                      # Date dimension
│   │   │   ├── Product.tmdl                       # GIM product master
│   │   │   ├── Region.tmdl                        # Region lookup (static)
│   │   │   ├── Sales.tmdl                         # Sales & demand fact
│   │   │   ├── Inventory.tmdl                     # Inventory snapshot fact
│   │   │   ├── Exit Tracker.tmdl                  # PLCM phaseout list
│   │   │   ├── Excess and Obsolete.tmdl           # E&O fact
│   │   │   ├── Phase.tmdl                         # Playbook phases
│   │   │   ├── Phase Activity.tmdl               # Playbook activities
│   │   │   ├── Role.tmdl                          # Playbook roles
│   │   │   └── Task Assignment.tmdl              # RACI assignments
│   │   ├── model.tmdl                             # Model metadata & query groups
│   │   ├── relationships.tmdl                     # 12 relationships
│   │   └── expressions.tmdl                       # Power Query / M-code
│   └── DAXQueries/                                # Ad-hoc DAX queries
├── PLCM Deep Dive.Report/                         # Report pages & visuals
│   ├── definition/
│   │   ├── report.json                            # Report configuration
│   │   ├── pages/                                 # 11 report pages
│   │   └── bookmarks/                             # Navigation bookmarks (17)
│   ├── CustomVisuals/                             # HTML Content visual
│   └── StaticResources/                           # Stryker theme
└── MyConnectionSDK/                               # Custom connector project
```

## Getting Started

### Prerequisites

- **Power BI Desktop** (March 2026 or later recommended for PBIP/TMDL support)
- Access to Power BI / Power Platform Dataflows for GIM, sales, inventory, demand, and playbook data

### Opening the Report

1. Open `PLCM Deep Dive.pbip` in Power BI Desktop (Developer Mode)
2. Authenticate to Power Platform Dataflows when prompted
3. Refresh the dataset to load current data
