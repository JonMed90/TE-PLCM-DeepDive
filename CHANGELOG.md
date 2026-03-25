# Changelog

All notable changes to the PLCM Inventory Deep Dive solution will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [2026-03-25]

### Added

- Created README with solution overview, data model, measures, data sources, and folder structure
- Created documentation stubs for all `docs/` subfolders
- Created CHANGELOG

### Initial

- Power BI semantic model (14 tables, 10 relationships, 30+ DAX measures)
- Power BI report with Stryker theme, HTML Content custom visual, and 11 pages
- Data sources: Azure Synapse, SharePoint PLCM Tracker, Power BI Dataflows (Inventory), Power Platform Dataflows (Playbook)
- PLCM decision tracking at Brand and SubBrand level (Global Exit, Local Exit, Maintain, Out of Scope)
- RACI playbook with phase-based task assignments and HTML tooltip visualization
- Margin analysis with budgeted growth margin comparison by Business Unit
- PBIP format enabled for version control alongside legacy PBIX
