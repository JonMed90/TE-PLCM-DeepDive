# Architecture — PLCM Inventory Deep Dive

## Solution Architecture

```text
┌────────────────────────────────┐     ┌────────────────────────────────┐
│  Power Platform Dataflows       │     │  Power BI Dataflows             │
│  (workspace 7e9a6bda)           │     │  (workspace f4ac28b7)           │
│                                 │     │                                 │
│  • Fact_ConsolidatedList        │     │  • Fact_Sales_Summary           │
│  • dim_Phase / PhaseActivity    │     │  • Calendar                     │
│  • dim_Role / fact_Assignments  │     │  • fact_Inventory_FG_Summary    │
│  • Fact_EO (E&O)                │     │  • Dim_GIMItem                  │
└────────────┬────────────────────┘     └────────────┬────────────────────┘
             │                                       │
             │     ┌────────────────────────────┐    │
             │     │  Power Platform Dataflows   │    │
             │     │  (workspace 7370e662)       │    │
             │     │                             │    │
             │     │  • DemantraCloud Dataflow   │    │
             │     └──────────────┬─────────────┘    │
             │                    │                   │
             └────────────┬───────┴───────────┬──────┘
                          │                   │
                          ▼                   ▼
              ┌────────────────────────────────────────────┐
              │         Power BI Semantic Model             │
              │         (Import Mode, TMDL format)          │
              │                                            │
              │  15 Tables • 12 Relationships • 42 Measures│
              └─────────────────────┬──────────────────────┘
                                    │
                                    ▼
              ┌────────────────────────────────────────────┐
              │         Power BI Report                     │
              │         (.pbip format)                      │
              │                                            │
              │  11 Pages • Stryker Theme • HTML Tooltips   │
              │  17 Bookmarks • Custom Visuals              │
              └────────────────────────────────────────────┘
```

## Technology Stack

| Component       | Technology                 | Purpose                                |
| --------------- | -------------------------- | -------------------------------------- |
| ETL / Prep      | Power Query (M)            | Data transformation, schema alignment  |
| Dataflows       | Power Platform + Power BI  | Source data from GIM, sales, inventory |
| Modeling        | TMDL (Tabular Model)       | Semantic model definitions             |
| Measures        | DAX                        | Business logic & KPIs (42 measures)    |
| Visualization   | Power BI Report            | Interactive dashboards (11 pages)      |
| Version Control | PBIP format + Azure DevOps | Git-friendly project structure         |

## Query Groups

| Group              | Tables / Queries                             |
| ------------------ | -------------------------------------------- |
| Calendar           | Calendar                                     |
| Inventory          | Inventory                                    |
| Sales/Demand       | Sales, Historical Sales, DemantraDemand      |
| Products           | Product, Exit Tracker                        |
| PLCM RACI Playbook | Phase, Phase Activity, Role, Task Assignment |
