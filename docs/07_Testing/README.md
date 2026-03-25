# Testing — PLCM Inventory Deep Dive

## Validation Checklist

| #   | Area             | Check                                                          | Status |
| --- | ---------------- | -------------------------------------------------------------- | ------ |
| 1   | Data Refresh     | All tables refresh without errors                              | ▢      |
| 2   | GIM Completeness | `# GIM SKUs` matches source count in Synapse                   | ▢      |
| 3   | Sales Totals     | Revenue/Units/COGS match Demantra + Historical source queries  | ▢      |
| 4   | Inventory Match  | `Inventory QoH` and `Ext Statutory Cost` match dataflow output | ▢      |
| 5   | PLCM Decisions   | Brand rollup logic matches expected values for test brands     | ▢      |
| 6   | TTM Calculations | TTM Revenue/Units/COGS verified against manual 12-month sum    | ▢      |
| 7   | DSI              | DSI (COGS) spot-checked against manual calculation             | ▢      |
| 8   | Margin vs Budget | Profit Margin minus Budget aligns with BU-specific targets     | ▢      |
| 9   | Exit Tracker     | Consolidated list count matches SharePoint source              | ▢      |
| 10  | Playbook RACI    | Task assignments match Dataflow source for all phases          | ▢      |
| 11  | Filters          | DeleteFlag and Business Unit report filters work correctly     | ▢      |
| 12  | Bookmarks        | All 17 bookmarks navigate to correct views                     | ▢      |
| 13  | Dynamic KPI      | KPI slicer switches between Revenue, Units, COGS correctly     | ▢      |
| 14  | Cross-filter     | Bidirectional filters on ConsolidatedList↔GIM and GIM↔Budget   | ▢      |
