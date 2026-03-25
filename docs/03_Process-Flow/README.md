# Process Flow — PLCM Inventory Deep Dive

## Data Refresh Flow

```text
┌─────────────────────────┐
│   Azure Synapse         │
│   (GIM, Sales, Demand)  │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐     ┌───────────────────────────┐
│   SharePoint Online     │     │  Power BI Dataflows       │
│   (PLCM Tracker_LIVE)   │     │  (Inventory Snapshot)     │
└──────────┬──────────────┘     └──────────┬────────────────┘
           │                               │
           ▼                               ▼
┌──────────────────────────────────────────────────────────┐
│              Power BI Semantic Model                     │
│  (Import Mode — scheduled refresh)                       │
│                                                          │
│  ┌──────────┐ ┌──────────────┐ ┌──────────────────────┐ │
│  │ Dim_GIM  │ │ Fact_Sales   │ │ Fact_Inventory       │ │
│  │ Dim_Cal  │ │ Fact_CList   │ │ Fact_TaskAssignments │ │
│  │ Dim_Reg  │ │ Budget       │ │ Dim_Phase/Activity   │ │
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
2. SubBrand-level decisions are set in the PLCM Tracker (SharePoint)
3. Brand-level decisions are rolled up automatically via DAX logic
4. Exit candidates move through playbook phases with RACI assignments
5. Phaseout SKUs are tracked in the Consolidated List with MDM/ECR/LTS milestones
