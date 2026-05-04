# Data Model — PLCM Inventory Deep Dive

## Overview

The semantic model uses **Import** mode with **15 tables**, **12 relationships**, and **42 DAX measures** organized into query groups:

- **Calendar** — `Calendar`
- **Inventory** — `Inventory`
- **Sales/Demand** — `Sales` (combined from `Historical Sales` + `DemantraDemand`)
- **Products** — `Product`, `Exit Tracker`
- **PLCM RACI Playbook** — `Phase`, `Phase Activity`, `Role`, `Task Assignment`

## Star Schema

```text
                    ┌──────────────┐
                    │   Calendar    │
                    │  (Date Key)   │
                    └──────┬───────┘
                           │
    ┌──────────────┐       │        ┌──────────────┐
    │    Region     │◄──────┼───────►│   _Budget     │
    └──────┬───────┘       │        └──────────────┘
           │               │               ▲ (TREATAS)
           │        ┌──────┴───────┐       │
           ├───────►│    Sales      │       │
           │        └──────────────┘       │
           │                               │
           │        ┌──────────────┐       │
           ├───────►│  Inventory    │       │
           │        └──────────────┘       │
           │                               │
           │        ┌──────────────────┐   │
           ├───────►│Excess and Obsolete│   │
           │        └──────────────────┘   │
           │                               │
           │        ┌──────────────┐       │
           └───────►│   Product    ├───────┘
                    └──────┬───────┘
                           │
                    ┌──────┴───────┐
                    │ Exit Tracker  │
                    └──────────────┘

    ┌──────────┐    ┌──────────────────┐    ┌───────────────┐
    │  Phase    │◄───│ Task Assignment   │───►│Phase Activity  │
    └──────────┘    └────────┬─────────┘    └───────────────┘
                             │
                      ┌──────┴──────┐
                      │    Role      │
                      └─────────────┘
```

## Dimension Details

### Product — GIM Product Master

Key columns and display folders:

| Display Folder | Columns                                                                                               |
| -------------- | ----------------------------------------------------------------------------------------------------- |
| Lifecycle      | Stocking Type Code, LCC Description, Life Cycle Code, Pack Content, Manufacturing Cost, UOM Type Code |
| Classification | Current Product Line Code, Major/Minor/Sub Classification, Item Type Description                      |
| Dates          | Create Date, First Sale Date, Last Change Date, Last Sale Date, Last Transferred Date                 |
| Ownership      | Item Owner, Item Owner Name                                                                           |
| Flags          | Delete Flag, Active Flag, Deferred Charge Flag                                                        |
| Keys           | Item ID                                                                                               |
| _(root)_       | Business Unit, Brand, SubBrand, Product Line, Catalog Number, Long Description                        |

**Hierarchy:** Business Unit → Product Line → Brand → SubBrand → Catalog Number

### Calendar — Date Table

- Source: Power BI Dataflow (`Calendar` entity, filtered to Sales date range)
- Key Columns: Date (PK), Month Start, Month Ending, Year, Quarter and Year, Month Short Name, Month Year
- Sort keys: Date Integer, Month Year Number, Month of Year, QuarterOfYear (all hidden)

### Region

- Static lookup: US, EMEA, ASPAC, LATAM, etc.
- Index column (hidden) for foreign key joins

### Exit Tracker — PLCM Phaseout Tracking

| Display Folder | Columns                                                                                       |
| -------------- | --------------------------------------------------------------------------------------------- |
| PLCM           | PLCM Phaseout Batch, PLCM Status                                                              |
| Tracking       | MDM Request Number, Comments, ECR Number, Phase ID                                            |
| Dates          | Last Transfer Sale Date, Date Submitted                                                       |
| Product        | Business Unit, Brand, SubBrand, Catalog Number, Long Description, Item Owner, Life Cycle Code |
| Keys           | GIM_ID (Hide), GIM ID                                                                         |

**Hierarchy:** Business Unit → Brand → SubBrand → Catalog Number

### Excess and Obsolete

- Monthly E&O snapshot by Account type (Inventory vs. Reserves)
- Keys: Item ID, Region Index, MonthEnding (FK to Calendar)

### Inventory

- Finished goods inventory positions by ERP site, warehouse, and subinventory
- Keys: Item ID (FK to Product), Region Index (FK to Region)
- Cost columns: Ext Statutory Cost USD, Ext Management Cost USD

### Phase (7 phases)

- PLCM lifecycle phases with objectives and conditional formatting colors
- Calculated column: Phase Font Color (SWITCH on Phase BG Color)

### Phase Activity, Role, Task Assignment

- RACI matrix structure: Activities belong to Phases, Tasks link Activities to Roles with Assignment Type (Responsible/Accountable)
