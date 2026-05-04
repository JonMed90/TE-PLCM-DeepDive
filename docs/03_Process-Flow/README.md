# Process Flow — PLCM Inventory Deep Dive

## Data Refresh Flow

```text
┌─────────────────────────────────┐     ┌─────────────────────────────────┐
│  Power Platform Dataflows       │     │  Power BI Dataflows             │
│  (Playbook, E&O, Exit Tracker)  │     │  (Calendar, Inventory, Sales)   │
│                                 │     │                                 │
│  • dim_Phase / PhaseActivity    │     │  • Calendar                     │
│  • dim_Role / fact_Assignments  │     │  • fact_Inventory_FG_Summary    │
│  • Fact_ConsolidatedList        │     │  • Fact_Sales_Summary           │
│  • Fact_EO                      │     │  • Dim_GIMItem                  │
└──────────────┬──────────────────┘     └──────────────┬──────────────────┘
               │                                       │
               │     ┌───────────────────────────┐     │
               │     │ Power Platform Dataflows   │     │
               │     │ (Demantra Demand Forecast) │     │
               │     │ • DemantraCloud Dataflow   │     │
               │     └──────────────┬────────────┘     │
               │                    │                   │
               └────────────┬───────┴───────────┬──────┘
                            │                   │
                            ▼                   ▼
┌──────────────────────────────────────────────────────────┐
│              Power BI Semantic Model                      │
│  (Import Mode — scheduled refresh)                       │
│                                                          │
│  ┌──────────┐ ┌──────────────┐ ┌──────────────────────┐ │
│  │ Product  │ │ Sales        │ │ Inventory            │ │
│  │ Calendar │ │ Exit Tracker │ │ Task Assignment      │ │
│  │ Region   │ │ _Budget      │ │ Excess and Obsolete  │ │
│  └──────────┘ └──────────────┘ └──────────────────────┘ │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│              Power BI Report (11 Pages)                   │
│  Landing → GIM → Sales → Demand → Inventory → Exit       │
│  → Margins → Playbook → Exec IBP                         │
└──────────────────────────────────────────────────────────┘
```

## PLCM Decision Flow

1. PLCM team reviews SKU data (GIM, sales, inventory, demand)
2. SubBrand-level decisions are tracked in the Consolidated List (Exit Tracker)
3. Brand-level decisions are rolled up via hierarchy in Exit Tracker
4. Exit candidates move through playbook phases (1-7) with RACI assignments
5. Phaseout SKUs are tracked with MDM/ECR/LTS milestones and batch status
6. E&O reserves and inventory exposure monitored through phaseout lifecycle
