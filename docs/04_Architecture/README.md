# Architecture — PLCM Inventory Deep Dive

## Solution Architecture

```text
┌──────────────────┐   ┌──────────────────────┐   ┌────────────────────────┐
│  Azure Synapse   │   │  SharePoint Online    │   │  Power Platform        │
│  Analytics       │   │  (PLCM Tracker)       │   │  Dataflows             │
│                  │   │                        │   │  (Inventory, Playbook) │
│  • dim_gimitem   │   │  • Bio Tracker         │   │  • fact_Inventory      │
│  • fact_sales    │   │  • F&A Tracker         │   │  • dim_Phase           │
│  • demantra      │   │  • Trauma Tracker      │   │  • dim_PhaseActivity   │
│                  │   │  • UE Tracker           │   │  • dim_Role            │
│                  │   │  • SKU list             │   │  • fact_Assignments    │
└────────┬─────────┘   └──────────┬─────────────┘   └──────────┬─────────────┘
         │                        │                             │
         └─────────────┬──────────┴──────────────┬──────────────┘
                       │                         │
                       ▼                         ▼
              ┌────────────────────────────────────────────┐
              │         Power BI Semantic Model             │
              │         (Import Mode, TMDL format)          │
              │                                            │
              │  14 Tables • 10 Relationships • 30+ Measures│
              └─────────────────────┬──────────────────────┘
                                    │
                                    ▼
              ┌────────────────────────────────────────────┐
              │         Power BI Report                     │
              │         (.pbip / .pbix)                     │
              │                                            │
              │  11 Pages • Stryker Theme • HTML Tooltips   │
              │  17 Bookmarks • Custom Visuals              │
              └────────────────────────────────────────────┘
```

## Technology Stack

| Component       | Technology                | Purpose                        |
| --------------- | ------------------------- | ------------------------------ |
| Data Warehouse  | Azure Synapse Analytics   | GIM master, sales, demand data |
| Collaboration   | SharePoint Online         | PLCM tracker workbooks         |
| ETL / Prep      | Power Query (M)           | Data transformation & merge    |
| Dataflows       | Power BI + Power Platform | Inventory & playbook data      |
| Modeling        | TMDL (Tabular Model)      | Semantic model definitions     |
| Measures        | DAX                       | Business logic & KPIs          |
| Visualization   | Power BI Report           | Interactive dashboards         |
| Version Control | PBIP format               | Git-friendly project structure |
