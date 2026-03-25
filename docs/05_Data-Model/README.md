# Data Model — PLCM Inventory Deep Dive

## Overview

The semantic model uses **Import** mode with 14 tables organized into query groups:

- **Calendar** — `Dim_Calendar`
- **Inventory** — `Fact_Inventory`
- **Sales/Demand** — `Fact_Sales`, `DemantraDemand`, `Historical Sales`
- **PLCM RACI Playbook** — `Dim_Phase`, `Dim_PhaseActivity`, `Dim_Role`, `Fact_TaskAssignments`
- **Disabled/PPR Tracker** — SharePoint tracker queries (Bio, F&A, Trauma, UE)

## Star Schema

```text
                    ┌──────────────┐
                    │  Dim_Calendar │
                    │  (Date Key)   │
                    └──────┬───────┘
                           │
    ┌──────────────┐       │        ┌──────────────┐
    │  Dim_Regions  │◄──────┼───────►│    Budget     │
    └──────┬───────┘       │        └──────────────┘
           │               │               ▲
           │        ┌──────┴───────┐       │
           ├───────►│  Fact_Sales   │       │
           │        └──────────────┘       │
           │                               │
           │        ┌──────────────┐       │
           ├───────►│Fact_Inventory │       │
           │        └──────┬───────┘       │
           │               │               │
           │        ┌──────┴───────┐       │
           └───────►│   Dim_GIM    ├───────┘
                    └──────┬───────┘
                           │
                    ┌──────┴────────────┐
                    │Fact_ConsolidatedList│
                    └───────────────────┘

    ┌──────────┐    ┌──────────────────┐    ┌───────────────┐
    │ Dim_Phase │◄───│Fact_TaskAssignments│───►│Dim_PhaseActivity│
    └──────────┘    └────────┬─────────┘    └───────────────┘
                             │
                      ┌──────┴──────┐
                      │  Dim_Role    │
                      └─────────────┘
```

## Dimension Details

### Dim_GIM — GIM Product Master

Key columns and display folders:

| Display Folder | Columns                                                                              |
| -------------- | ------------------------------------------------------------------------------------ |
| PLCM Decision  | PLCM Status, US/EU/ASPAC Decision, Global Decision (Brand/SubBrand), Roadmap Updated |
| SKU Dates      | PPR.Last Buy, PPR.Last Sell, GIM.InitialReleaseDate, GIM.LastTransferredDate         |
| Flag           | DeleteFlag, activeflag, substituteitem                                               |
| Keys           | ItemId                                                                               |
| Other          | Stocking Type Code, LCC Description, Life Cycle Code                                 |
| _(root)_       | Business Unit, Brand, SubBrand, Product Line, Catalog Number, Manufacturing Cost     |

### Dim_Calendar — Date Table

- Range: January 2022 – December 2030
- Columns: Date, MonthStart, MonthEnding, Year, Quarter & Year, MonthShortName, Month-Year

### Dim_Regions

- Static lookup: US, EMEA, ASPAC, LATAM, etc.
- Index column for foreign key joins
