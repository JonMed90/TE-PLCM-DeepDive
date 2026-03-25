# PLCM Inventory Deep Dive

## Purpose

Power BI analytics solution for the **Trauma & Extremities (T&E) Product Life Cycle Management (PLCM)** team. The report provides deep-dive visibility into T&E SKUs across inventory on hand, historical sales, demand forecasts, GIM product master details, profit margins, and PLCM playbook tracking. It supports data-driven PLCM decisions (Exit, Maintain, Out of Scope) at the Brand and SubBrand level across global regions.

## Platforms

| Platform                         | Usage                                                                                |
| -------------------------------- | ------------------------------------------------------------------------------------ |
| **Power BI** (`.pbip` / `.pbix`) | Semantic model (14 tables, 30+ DAX measures) and 11-page report                      |
| **Azure Synapse Analytics**      | Source for GIM product master (`dim_gimitem`) and Demantra sales/demand data         |
| **SharePoint Online**            | PLCM Tracker workbook (`PLCM Tracker_LIVE.xlsx`) with BU-specific tracker sheets     |
| **Power Platform Dataflows**     | Inventory snapshot data and PLCM Playbook RACI tables (Phase, Role, TaskAssignments) |

## Key Features

- **GIM Product Master** — Full GIM item catalog with PLCM status, lifecycle codes, stocking types, and regional decisions
- **Historical Sales** — Actuals and forecasts by Business Unit, Brand, SubBrand, and Region with dynamic KPI toggle (Revenue / Units / COGS)
- **Demand Forecasting** — Next 12-month demand units from Demantra with trailing 12-month (TTM) trend analysis
- **Inventory Snapshot** — On-hand quantity, extended statutory & management cost by site, warehouse, and subinventory
- **Exit Tracker** — Consolidated list of PLCM phaseout SKUs with MDM request tracking, LTS dates, and batch status
- **Margin Analysis** — Trailing 12M gross profit, profit margin vs. budgeted growth margin by Business Unit
- **PLCM Playbook** — RACI matrix with phase-based task assignments, accountability tracking, and HTML tooltip cards
- **Exec IBP Summary** — Executive-level Integrated Business Planning view
- **Dynamic PLCM Decisions** — Brand-level and SubBrand-level global PLCM decision rollups (Exit, Maintain, Out of Scope)
- **DSI Calculation** — Days Sales in Inventory computed from statutory cost and TTM COGS

## Report Pages

| #   | Page                  | Description                                                  |
| --- | --------------------- | ------------------------------------------------------------ |
| —   | Landing Page          | Navigation hub and report overview                           |
| 1   | GIM                   | GIM product master details, PLCM status, lifecycle codes     |
| 2   | Historical Sales      | Actuals vs. forecast trends by BU/Brand/SubBrand             |
| 2R  | Roadmap Regional      | Regional roadmap view of sales and PLCM decisions            |
| 3   | Demand                | Demantra demand forecast and next 12-month projections       |
| 4   | Inventory Snapshot    | On-hand inventory by region, site type, warehouse            |
| 5   | Exit Tracker          | PLCM phaseout consolidated list with ECR and MDM tracking    |
| 6   | Margins               | Trailing 12M revenue, gross profit, profit margin vs. budget |
| 7   | PLCM Playbook         | RACI matrix — phases, activities, and role assignments       |
| —   | Exec IBP              | Executive IBP summary                                        |
| —   | PLCM Playbook Tooltip | HTML tooltip card for playbook activity details (hidden)     |

## Data Model

### Tables

| Table                   | Type      | Mode       | Source                                              |
| ----------------------- | --------- | ---------- | --------------------------------------------------- |
| `Dim_GIM`               | Dimension | Import     | Azure Synapse — `dim_gimitem`                       |
| `Dim_Calendar`          | Dimension | Import     | Generated date table (2022–2030)                    |
| `Dim_Regions`           | Dimension | Import     | Static region lookup (US, EMEA, ASPAC, LATAM, etc.) |
| `Dim_KPI`               | Dimension | Import     | Static KPI selector (Revenue, Units, COGS)          |
| `Dim_Phase`             | Dimension | Import     | Dataflow — PLCM playbook phases                     |
| `Dim_PhaseActivity`     | Dimension | Import     | Dataflow — PLCM playbook phase activities           |
| `Dim_Role`              | Dimension | Import     | Dataflow — PLCM playbook roles                      |
| `Fact_Sales`            | Fact      | Import     | Combined Demantra demand + historical sales         |
| `Fact_Inventory`        | Fact      | Import     | Dataflow — finished goods inventory snapshot        |
| `Fact_ConsolidatedList` | Fact      | Import     | SharePoint — PLCM phaseout consolidated list        |
| `Fact_TaskAssignments`  | Fact      | Import     | Dataflow — PLCM playbook RACI assignments           |
| `Budget`                | Reference | Calculated | DAX `DATATABLE` — BU budgeted growth margin %       |
| `Playbook Navigation`   | Reference | Calculated | DAX `DATATABLE` — playbook tab navigation           |
| `_Measures`             | Measures  | Calculated | Central measures table (30+ DAX measures)           |

### Key Relationships

```text
Fact_Sales[Date]              → Dim_Calendar[Date]
Fact_Sales[ItemId]            → Dim_GIM[ItemId]
Fact_Sales[Dim_Regions.Index] → Dim_Regions[Index]
Fact_Inventory[ItemId]        → Dim_GIM[ItemId]
Fact_Inventory[Region]        → Dim_Regions[Region]
Fact_ConsolidatedList[ItemId] → Dim_GIM[ItemId]         (bidirectional)
Dim_GIM[Business Unit]        → Budget[BU]              (bidirectional)
Fact_TaskAssignments[Role Name]         → Dim_Role[Role Name]
Fact_TaskAssignments[Phase Activity ID] → Dim_PhaseActivity[Phase Activity ID]
Fact_TaskAssignments[Phase ID]          → Dim_Phase[Phase ID]
```

### Key Measures

| Measure                        | Description                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| `Revenue`                      | `SUM(Fact_Sales[Revenue])`                                        |
| `Units Sold`                   | `SUM(Fact_Sales[Quantity])`                                       |
| `COGS`                         | `SUM(Fact_Sales[COGS])`                                           |
| `Inventory QoH`                | `SUM(Fact_Inventory[QuantityOnHand])`                             |
| `Ext Statutory Cost`           | `SUM(Fact_Inventory[ERP_Extended_Statutory_Cost_USD])`            |
| `TTM Revenue`                  | Trailing 12-month revenue from last actual sales date             |
| `TTM Units`                    | Trailing 12-month units from last actual sales date               |
| `TTM COGS`                     | TTM units × manufacturing cost per GIM item                       |
| `DSI (COGS)`                   | Days Sales in Inventory — `(Ext Statutory Cost / TTM COGS) × 365` |
| `Dynamic Sales KPI`            | Switches between Revenue, Units, COGS based on slicer             |
| `Dynamic Global PLCM Decision` | Brand vs. SubBrand-level PLCM decision based on drill level       |
| `Trailing 12M Revenue`         | Revenue for 12 months ending last month                           |
| `Gross Profit`                 | `Trailing 12M Revenue − COGS`                                     |
| `Profit Margin`                | `Gross Profit / Trailing 12M Revenue`                             |
| `Next 12M Demand Units`        | Forecast units for next 12 months from current month              |
| `# GIM SKUs`                   | `DISTINCTCOUNT(Dim_GIM[ItemId])`                                  |
| `# ConsolidatedList SKUs`      | `COUNTROWS(Fact_ConsolidatedList)`                                |

## Data Sources

| Source                              | Connection                        | Objects                                                                                     |
| ----------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------- |
| Azure Synapse (`gda_glbsyndb`)      | ActiveDirectoryInteractive        | `dim_gimitem`, `demantra_cld_fact_sales`, Demantra demand tables                            |
| SharePoint Online (T&E PLCM site)   | Excel workbook via Power Query    | `PLCM Tracker_LIVE.xlsx` — Bio, F&A, Trauma, UE tracker sheets + SKU list                   |
| Power BI Dataflows (Inventory)      | PowerBI.Dataflows connector       | `fact_Inventory` (workspace `f4ac28b7-...`)                                                 |
| Power Platform Dataflows (Playbook) | PowerPlatform.Dataflows connector | `dim_Phase`, `dim_PhaseActivity`, `dim_Role`, `fact_Assignments` (workspace `7e9a6bda-...`) |

## Folder Structure

```text
PLCM-Inventory-DeepDive/
├── README.md                                      # This file
├── CHANGELOG.md                                   # Release history
├── .gitignore                                     # Git ignore rules
├── PLCM Deep Dive.pbip                            # PBIP project entry point
├── PLCM Deep Dive.pbix                            # Legacy PBIX file
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
│   │   ├── tables/                                # 14 table definitions
│   │   │   ├── _Measures.tmdl                     # Central measures table
│   │   │   ├── Dim_GIM.tmdl                       # GIM product master
│   │   │   ├── Dim_Calendar.tmdl                  # Date table
│   │   │   ├── Dim_Regions.tmdl                   # Region lookup
│   │   │   ├── Dim_KPI.tmdl                       # KPI selector
│   │   │   ├── Dim_Phase.tmdl                     # Playbook phases
│   │   │   ├── Dim_PhaseActivity.tmdl             # Playbook activities
│   │   │   ├── Dim_Role.tmdl                      # Playbook roles
│   │   │   ├── Fact_Sales.tmdl                    # Sales & demand
│   │   │   ├── Fact_Inventory.tmdl                # Inventory snapshot
│   │   │   ├── Fact_ConsolidatedList.tmdl         # PLCM exit list
│   │   │   ├── Fact_TaskAssignments.tmdl          # RACI assignments
│   │   │   ├── Budget.tmdl                        # BU budget margins
│   │   │   └── Playbook Navigation.tmdl           # Tab navigation
│   │   ├── model.tmdl                             # Model metadata & query groups
│   │   ├── relationships.tmdl                     # 10 relationships
│   │   └── expressions.tmdl                       # Power Query / M-code
│   └── DAXQueries/                                # Ad-hoc DAX queries
└── PLCM Deep Dive.Report/                         # Report pages & visuals
    ├── definition/
    │   ├── report.json                            # Report configuration
    │   ├── pages/                                 # 11 report pages
    │   └── bookmarks/                             # Navigation bookmarks (17)
    ├── CustomVisuals/                             # HTML Content visual
    └── StaticResources/                           # Stryker theme
```

## Getting Started

### Prerequisites

- **Power BI Desktop** (June 2024 or later recommended for PBIP support)
- Access to Azure Synapse Analytics (`gda_glbsyndb`) via Azure AD
- Access to the T&E PLCM SharePoint site (`stryker.sharepoint.com/sites/TEPLCM`)
- Access to Power BI / Power Platform Dataflows for inventory and playbook data

### Opening the Report

1. Open `PLCM Deep Dive.pbip` in Power BI Desktop (Developer Mode)
2. Authenticate to Azure Synapse, SharePoint, and Dataflow sources when prompted
3. Refresh the dataset to load current data

### Legacy PBIX

The `PLCM Deep Dive.pbix` file is maintained for backward compatibility. The `.pbip` format is the primary development format for version control support.
