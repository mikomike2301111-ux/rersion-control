# Farmtrack ERP Upgrade Log

This file is the working record for all future Farmtrack ERP changes.

## Change Rule

From this point forward, every change should be treated as a targeted upgrade. Each upgrade should record:

- Target area
- Reason for change
- Files changed
- What improved
- Verification performed
- Follow-up risks or next steps

Avoid vague edits. Prefer focused improvements to one area at a time.

## Upgrade Format

```md
## YYYY-MM-DD - Upgrade Title

Target area:

Reason:

Files changed:

Improvements:

Verification:

Notes / next steps:
```

## 2026-06-10 - Supabase Settings Control Panel

Target area:
Settings workspace, Supabase diagnostics, normalized sync operations

Reason:
The ERP backend had Supabase bridge and normalized sync checks, but users needed a visible in-app place to confirm what is connected and what still needs schema setup.

Files changed:
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added a Settings > Supabase tab with connection cards for the JSON bridge, normalized tables, and last normalized sync.
- Added refresh and normalized-sync actions directly inside Settings.
- Added a missing-table checklist that points to `supabase-normalized-core.sql` before full normalized sync.
- Added a page integration map so Dashboard, Analytics, CRM, Sales, Inventory, Purchases, Manufacturing, Finance, Reports, and Settings show their current Supabase mode.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.

Notes / next steps:
- Full normalized mode still requires creating the missing tables in Supabase by running `supabase-normalized-core.sql` with database-owner privileges.

## 2026-06-10 - Normalized Supabase Integration Layer

Target area:
Backend persistence, Supabase readiness checks, normalized table sync

Reason:
The ERP was connected to Supabase through `erp_state`, but every page needed a path toward full normalized Supabase tables and an exact diagnostic for missing schema pieces.

Files changed:
- `api/rpc.js`
- `supabase-normalized-core.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added safer Supabase REST request handling with clear missing-table errors.
- Added deterministic UUID mapping so current ERP records can sync into UUID-based Supabase tables.
- Added normalized mapping for tenants, profiles, customers, suppliers, products, warehouses, inventory items, sales orders, sales order items, invoices, payments, purchase orders, production jobs, journal entries, and business events.
- Added automatic normalized sync after JSON bridge persistence when the normalized schema is available.
- Added `getSupabaseIntegrationStatus` to show per-page integration mode and missing Supabase tables.
- Added `syncSupabaseNormalized` to trigger a full core-record sync once `supabase-schema.sql` has been installed.
- Added `supabase-normalized-core.sql`, a clean minimal schema matched to the live sync layer and analytics views.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Deployed to Vercel production.
- Called `getSupabaseIntegrationStatus` live and confirmed `erp_state` bridge is connected.
- Called `syncSupabaseNormalized` live and confirmed it reports missing normalized tables cleanly.

Notes / next steps:
- Full normalized sync requires the Supabase SQL schema to exist in the target database. REST service keys can upsert rows but cannot create missing tables.

## 2026-06-10 - Accounts Sidebar and Logo Polish

Target area:
Sidebar navigation, logo assets, browser favicon, typography weights, accounts workspace

Reason:
The top logo did not present cleanly, the browser icon needed a closer crop, the UI still had overly bold spots, and Accounts needed its own side-panel entry and working screen.

Files changed:
- `index.html`
- `public/unity-erp-favicon.png`
- `public/unity-erp-mark.png`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added a 40% zoomed browser favicon.
- Added a cleaner cropped sidebar logo mark.
- Added Accounts to the sidebar with its own route and workspace.
- Built the Accounts workspace from live finance data: chart of accounts, receivables, payables, bank accounts, trial balance, journals, and posting actions.
- Added a final de-bold typography pass across labels, controls, headings, and status elements.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Opened local Vite preview at `#/accounts` and captured a viewport screenshot.

Notes / next steps:
- GitHub push still depends on local Git credentials being available.

## 2026-06-10 - Softer Typography Weight Pass

Target area:
Global UI typography

Reason:
Several labels, buttons, headings, and helper texts were too bold, making the ERP feel heavy and harder to scan.

Files changed:
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Reduced body text from medium-heavy to regular weight.
- Softened headings, panel titles, sidebar brand text, tabs, buttons, labels, badges, and report controls.
- Kept KPI and numeric values readable with tabular figures and moderate emphasis.

Verification:
- Ran `npm run build`.

Notes / next steps:
- Review live pages visually and tune individual module weights if any specific area still feels too heavy.

## 2026-06-10 - ERP Reliability Foundation Pass

Target area:
Backend validation, sales-to-inventory sync, operational integrity checks

Reason:
The ERP needed stronger guardrails so records entered from forms do not create stale, invalid, or disconnected data across sales, inventory, reports, analytics, and finance.

Files changed:
- `api/rpc.js`
- `UPGRADE_LOG.md`

Improvements:
- Added shared validation helpers for required fields and positive quantities.
- Added backend validation for customers, suppliers, products, inventory, and users.
- Blocked inventory adjustments and transfers that would create negative stock.
- Added transfer-in and transfer-out inventory transaction records for stock movements.
- Strengthened sales order creation so every line requires a product, quantity, price, and available stock.
- Added automatic inventory deduction and sale-out transaction records when sales are saved.
- Added `runERPIntegrityChecks` for admin/manager health checks across inventory, sales invoices, deliveries, journals, reports, and business events.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.

Notes / next steps:
- Continue expanding module-specific validation as each workspace receives deeper input workflows.

## 2026-06-10 - Sidebar Route Persistence and Report Declutter

Target area:
Navigation, report center layout

Reason:
Refreshing the ERP returned users to the default dashboard, and the Available Reports panel was too crowded to scan comfortably.

Files changed:
- `src/main.jsx`
- `src/styles.css`

Improvements:
- Added hash routes for sidebar pages, such as `#/dashboard`, `#/reports`, `#/crm`, `#/purchases`, and `#/manufacturing`, so refresh keeps the current workspace.
- Added report search and module-aware filtering to Available Reports.
- Reworked report grids, filter rows, library lists, and export buttons to wrap and scroll cleanly instead of clustering.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Verified built Vite preview returns 200 for `#/reports` and `#/crm`.

Notes / next steps:
- Hash routes are intentionally used for Vercel-safe refresh behavior without requiring server-side route rewrites.

## 2026-06-10 - Workspace Sub-Routes and Clutter Cleanup Continuation

Target area:
Module tab routing, responsive workspace layout

Reason:
After sidebar routes were added, inner workspace tabs still reset on refresh and several older fixed-column grids could still feel crowded.

Files changed:
- `src/main.jsx`
- `src/styles.css`

Improvements:
- Added tab-level hash routes for Analytics, CRM, Sales, Purchases, Inventory, Manufacturing, and Finance.
- Examples now include `#/sales/orders`, `#/crm/pipeline`, `#/finance/reports`, and `#/inventory/stock`.
- Converted crowded KPI, analytics, report, pipeline, county, procurement, and manufacturing grids to responsive `auto-fit` layouts.
- Kept existing clickable tab behavior while making refresh restore the same section.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Verified built Vite preview returns 200 for `#/sales/orders`, `#/crm/pipeline`, `#/finance/reports`, and `#/inventory/stock`.

Notes / next steps:
- Future deep links can add record-level routes, such as `#/sales/orders/:id`, when detail drawers become route-aware.

## 2026-06-10 - Enterprise Settings Control Center

Target area:
Settings, administration, system controls

Reason:
Settings needed to become the ERP master control center instead of a small company profile page.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`

Improvements:
- Added `getSettingsWorkspaceData` backend aggregation for company settings, users, roles, permissions, departments, warehouses, rules, notifications, templates, integrations, audit, security, backups, API settings, system health, and advanced flags.
- Added `saveSettingsSection` for editable company/system settings and `saveSettingsUser` for user creation.
- Rebuilt Settings as a tabbed enterprise control center with deep links like `#/settings/users`, `#/settings/security`, and `#/settings/backup`.
- Added editable company settings and a working new-user modal.
- Added administration panels for permissions, departments, warehouses, business rules, notifications, documents, integrations, audit, security, recovery, data management, APIs, health, and advanced flags.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Verified built Vite preview returns 200 for `#/settings/company`, `#/settings/users`, `#/settings/security`, and `#/settings/backup`.

Notes / next steps:
- Future upgrades can make each settings rule button open its own detailed policy editor.

## 2026-06-10 - Settings Usability and Readability Fix

Target area:
Settings company form, settings actions, typography

Reason:
Company Settings looked cramped, Settings controls did not give enough feedback, and the text needed to be larger and easier to read.

Files changed:
- `src/main.jsx`
- `src/styles.css`

Improvements:
- Split Company Settings into grouped fieldsets: identity, contact, tax, localization, banking, and documents.
- Increased Settings field, tab, table, card, and button typography by roughly 20%.
- Widened company fields and rule cards to prevent cramped layouts.
- Added save confirmation feedback for Company Settings.
- Made Settings rule Configure buttons call the backend and show saving feedback.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.

Notes / next steps:
- The next upgrade can replace rule Configure quick-save actions with detailed modal editors for each policy.

## 2026-06-10 - ERP Logo Branding Update

Target area:
Branding, login, sidebar

Reason:
The ERP should use the supplied black-and-gold horse logo instead of the temporary text mark.

Files changed:
- `public/erp-logo-black.png`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added the supplied ERP logo as a public app asset.
- Replaced the login page ERP text mark with the logo.
- Replaced the sidebar text/icon mark with the logo.
- Adjusted brand sizing and object-fit so the logo scales cleanly.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.

Notes / next steps:
- A transparent or cropped logo variant would improve small-sidebar readability further.

## 2026-06-10 - Universal Sans and IBM Plex Mono Typography

Target area:
Typography, code/technical text

Reason:
The ERP should use a cleaner x.ai/Grok-style main text stack and a proper monospace for technical/code-like values.

Files changed:
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Set body, controls, headings, and main UI text to prefer `Universal Sans`.
- Added strong fallbacks for systems where Universal Sans is not installed.
- Added IBM Plex Mono from Google Fonts for code, badges, status tags, report metadata, and technical values.
- Kept tabular numeric alignment for KPI and financial values.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.

Notes / next steps:
- If a licensed Universal Sans font file is supplied later, add it through `@font-face` for exact rendering.

## 2026-06-10 - Unity ERP Brand and Collapsible Sidebar

Target area:
Branding, browser metadata, sidebar navigation

Reason:
The top-left brand needed to read Unity / ERP, the browser needed the ERP logo, and the side panel needed a stable retract/expand control.

Files changed:
- `index.html`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Changed the browser title to `Unity ERP`.
- Added the ERP logo as favicon and Apple touch icon.
- Updated the sidebar brand to show the logo with `Unity` and `ERP` underneath.
- Added a desktop sidebar retract/expand button with persisted state.
- Removed hover translation that caused sidebar twitching.
- Added responsive safeguards so the mobile drawer stays full width even when desktop collapsed mode is active.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.

Notes / next steps:
- A transparent/cropped version of the logo can make the small collapsed icon even sharper.

## 2026-06-09 - Componentized Vercel Frontend

Target area:
Frontend architecture, dashboard UI, deployment

Reason:
The old frontend was a single compressed Apps Script HTML file, which made exact UI matching and long-term maintenance difficult.

Files changed:
- `index.html`
- `src/main.jsx`
- `src/styles.css`
- `package.json`
- `vercel.json`

Improvements:
- Replaced the compressed inline React/Babel app with a Vite React app.
- Added componentized layout, sidebar, topbar, KPI cards, panels, charts, tables, login, and module pages.
- Moved styling into `src/styles.css`.
- Added professional icons via `lucide-react`.
- Added Recharts-based dashboard charts.
- Kept the existing `/api/rpc` backend path working.
- Deployed to `https://erpftc.vercel.app`.

Verification:
- Ran `npm install`.
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Verified live login and dashboard rendering in browser.
- Confirmed live API health returned Supabase persistence.

Notes / next steps:
- Future frontend upgrades should target specific screens/components.
- Consider adding code splitting if the frontend bundle grows further.
- Continue replacing broad demo bridge behavior with normalized Supabase table access.

## 2026-06-09 - Supabase Enterprise Schema Foundation

Target area:
Database architecture, event-driven ERP foundation

Reason:
The ERP needs a single source of truth and connected business workflow foundation instead of disconnected module tables.

Files changed:
- `supabase-schema.sql`

Improvements:
- Added tenant-aware ERP tables.
- Added `business_events` event bus.
- Added `audit_logs`.
- Added CRM, inventory, sales, procurement, production, delivery, and accounting foundation tables.
- Added inventory availability view.
- Added deterministic `reserve_inventory_for_order` workflow function.
- Added `seed_farmtrack_demo()` demo data function.
- Kept `erp_state` for the current Vercel demo bridge.

Verification:
- Reviewed schema structure for key tables/functions.
- Confirmed no secret values were stored in source files.

Notes / next steps:
- Run the SQL in Supabase SQL Editor if not already applied.
- Start migrating `/api/rpc` from JSON bridge state to normalized Supabase tables module by module.

## 2026-06-09 - Module 1A Executive Command Center

Target area:
Dashboard / Executive Command Center

Reason:
The dashboard must answer what is happening now, what needs attention, what is likely next, and what actions should be taken. It should not feel like a static reporting page.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added command-center API payload: greeting, role profile, attention queue, recommended actions, forecast, cash position, inventory value, sales pipeline, production status, and purchase order signals.
- Reworked the dashboard UI into an executive control center with a dark live-signal hero, six control KPIs, attention panel, recommended actions, and forecast panel.
- Added Supabase preference tables: `dashboard_widgets`, `dashboard_layouts`, and `dashboard_preferences`.
- Kept dashboard business data read-only from source modules; preference tables store layout metadata only.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Deployed to `https://erpftc.vercel.app`.
- Verified live API returns `commandCenter` data.
- Verified live API still reports `persistence: "supabase"`.
- Verified dashboard shows `Needs Attention` and `Recommended Actions`.
- Captured `module-1a-command-center.png`.

Notes / next steps:
- Wire role-specific dashboard layout loading from Supabase preference tables.
- Add realtime subscriptions for sales, inventory, production, and delivery updates.

## 2026-06-09 - Analytics Executive Intelligence Center

Target area:
Analytics, Reports, Supabase analytics foundation

Reason:
Analytics needs to work as an executive intelligence command center, not a basic metrics page. It should turn sales, inventory, customer, procurement, production, and finance data into decisions.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added `getAnalyticsData` API output for revenue waterfall, revenue heatmap, customer value, inventory health, supplier scorecards, production efficiency, sales funnel, finance risk, AI insights, war room risks, and report categories.
- Added a dedicated Analytics page with executive intelligence sections, preserving the Farmtrack enterprise theme.
- Added Report Generation Center cards for board, sales, inventory, procurement, production, finance, customer, risk, and forecast reports.
- Added Supabase `analytics` schema with materialized views for revenue, inventory, customers, procurement, production, risks, and executive summaries.
- Added analytics materialized-view indexes and `analytics.refresh_all()` for fast aggregated reads at scale.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getAnalyticsData` API returns revenue waterfall, heatmap, customer intelligence, inventory intelligence, procurement, production, finance, AI insights, war room, and reports data.
- Verified live Analytics navigation renders `Executive Analytics Center`, `Revenue Waterfall`, `AI Business Intelligence`, `Executive War Room`, and `Report Generation Center`.
- Browser screenshot capture timed out during the screenshot operation, but the live page snapshot verified the rendered sections.

Notes / next steps:
- Apply `supabase-schema.sql` in Supabase SQL Editor if the analytics materialized views are not already present.
- Next upgrade can move `getAnalyticsData` from the current Supabase JSON bridge to direct reads from normalized analytics materialized views.

## 2026-06-09 - Sales GeoSales Territory Intelligence Center

Target area:
Sales, Territory Intelligence, Supabase GeoSales foundation

Reason:
Farmtrack field sales teams move physically across Kenya, so Sales needs territory coverage, county performance, GPS visit verification, route intelligence, and expansion opportunity scoring instead of a simple sales-order table.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Replaced the Sales page with a Sales module containing `Territory Intelligence` and `Sales Orders` views.
- Added GeoSales API data for all 47 Kenya counties, county coverage status, county drill-downs, visit tracking, GPS check-ins, sales routes, rep comparisons, opportunity scoring, AI territory intelligence, and territory reports.
- Added automatic demo-state upgrading so existing Supabase-backed demo state gains counties, visits, routes, assignments, check-ins, and targets.
- Added Supabase normalized tables: `counties`, `sub_counties`, `sales_visits`, `territory_assignments`, `territory_performance`, `sales_checkins`, `sales_routes`, and `county_targets`.
- Added Supabase materialized views: `analytics.mv_county_revenue`, `analytics.mv_county_profitability`, `analytics.mv_county_coverage`, `analytics.mv_sales_routes`, and `analytics.mv_sales_rep_coverage`.
- Added RLS/service-role/tenant-read policy coverage for the new territory tables.
- Added seed data for all 47 counties, county targets, sub-counties, a sample assignment, GPS visit, check-in, and route.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Ran `getGeoSalesData` 9 times locally; each run returned 47 counties, 95 visits, rep comparisons, and territory status signals.
- Confirmed Supabase schema contains GeoSales tables, indexes, materialized views, refresh calls, RLS, and seed entries.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getGeoSalesData` API returns 47 counties, 95 visits, 11 active counties, 26 neglected counties, and 10 reports.
- Verified live Sales page renders `GeoSales Intelligence Center`, Kenya territory coverage, county profile, visit tracking, rep comparison, movement routes, opportunity map, AI territory intelligence, and territory reports.
- Verified `Sales Orders` tab still renders the sales-order table.

Notes / next steps:
- Apply the updated `supabase-schema.sql` in Supabase SQL Editor so the normalized GeoSales tables and materialized views exist in the database.
- Next upgrade can add real mobile check-in/check-out actions and real map geometry once county boundary assets are introduced.

## 2026-06-09 - Analytics Data-Source Stabilization

Target area:
Analytics backend, Supabase cooperation, UI diagnostics

Reason:
Analytics was rendering, but the looks/function/database layers were not cooperating clearly. The page needed to stop pretending every value came from normalized analytics tables when the live app may still be using the Supabase JSON bridge fallback.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Diagnosed Analytics as not blank, not slow, and not a build/runtime error.
- Identified the actual issue as data-source mismatch: UI existed, but backend fell back to bridge/demo calculations unless materialized views were applied.
- Changed `getAnalyticsData` to prefer public Supabase analytics views backed by materialized views.
- Added fallback metadata so the API clearly reports whether it is using `Supabase materialized views`, `Supabase JSON bridge`, or local demo memory.
- Added an Analytics page data-source badge so the UI tells the truth about the current data layer.
- Added public Supabase wrapper views: `analytics_revenue_summary`, `analytics_inventory_health`, `analytics_customer_value`, `analytics_procurement_metrics`, `analytics_production_metrics`, `analytics_risk_center`, and `analytics_executive_summary`.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Confirmed live pre-fix Analytics rendered without console errors and loaded in under 2 seconds.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Deployed to `https://erpftc.vercel.app`.
- Verified live Analytics API reports `mode: "Supabase JSON bridge"` and `normalized: false` until the Supabase SQL views are applied.
- Verified live Analytics page displays the data-source badge and no longer hides the database cooperation issue.

Notes / next steps:
- Apply `supabase-schema.sql` in Supabase SQL Editor, then run `select analytics.refresh_all();` so Analytics switches from bridge fallback to materialized-view mode.

## 2026-06-09 - Unified Sales Workspace Stabilization

Target area:
Sales module, revenue operations workflow

Reason:
Sales was behaving like disconnected pages instead of one ERP revenue system. Orders, territory, reports, analytics, quotations, and invoices needed to share one workspace payload, filters, and tab state.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added `getSalesWorkspaceData` as one backend payload for Overview, Pipeline, Quotes, Orders, Invoices, Team, Territory, Reports, Analytics, and AI.
- Rebuilt Sales as a single workspace with top tabs and shared filters for date range, territory, sales rep, and product.
- Added Overview KPIs: revenue, profit, orders, invoices, pipeline, expenses.
- Added large revenue operations chart and metric toggle for revenue, profit, customers, invoices, expenses, and pipeline.
- Added quotation workflow cards with next actions.
- Added order and invoice live-status tables.
- Preserved territory intelligence inside the unified workspace instead of isolating it.
- Added sales-only analytics for revenue trend, profit trend, team comparison, territory comparison, product comparison, customer growth, quotation conversion, pipeline value, and forecast.
- Added non-empty report cards with PDF, Excel, CSV, and Email actions.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Ran `getSalesWorkspaceData` 10 times locally; each run returned valid overview, pipeline, quotes, orders, invoices, team, territory, reports, analytics, and AI data.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getSalesWorkspaceData` API returns 42 orders, 42 invoices, 47 counties, and 6 reports.
- Verified live Sales Workspace renders Overview, Quotes, Orders, Invoices, Territory, Reports, and Analytics tabs without page reloads.
- Verified Sales Analytics tab renders revenue trend, profit trend, territory comparison, product comparison, customer growth, quotation conversion, pipeline value, and forecast.

Notes / next steps:
- Next Sales upgrade should wire quote action buttons into real mutations: send quote, convert to order, generate invoice, and refresh workspace state.

## 2026-06-09 - Analytics Tab Functionality Repair

Target area:
Analytics tab engine, filters, reports, KPIs, charts, AI insights

Reason:
Analytics tabs looked clickable but were static. Clicking Revenue, Sales, Inventory, Production, Procurement, Customer, Financial, AI, or Forecasting did not load independent tab data, refresh charts, preserve filters, or regenerate reports.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added `getAnalyticsTabData` endpoint for lazy per-tab analytics payloads.
- Added state-driven active Analytics tab selection while preserving the existing visual layout.
- Added per-tab filter state, last-refresh display, KPIs, trend chart, reports, and AI insights.
- Kept the existing Analytics cards and layout intact while making the horizontal tabs functional.
- Added active-tab styling and responsive KPI/filter rows.

Verification:
- Ran `npm run build`.
- Ran `node --check api/rpc.js`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Ran Analytics tab engine 10 times locally; every run loaded all 9 tabs with KPIs, trends, reports, insights, filters, and refresh timestamps.
- Deployed to `https://erpftc.vercel.app`.
- Verified live API returns functional data for all 9 Analytics tabs.
- Verified live browser tab clicks update active state, tab KPIs, tab chart heading, reports, AI insights, filters, and refresh time.

Notes / next steps:
- Once `supabase-schema.sql` is applied in Supabase, tab payloads can be switched from bridge-derived records to dedicated materialized-view queries per tab.

## 2026-06-09 - Procurement Operations Center Rebuild

Target area:
Purchases module, procurement workflow, supplier operations, receiving, AP, reports, analytics

Reason:
Purchases was only rendering a Purchase Orders table. It did not operate as a connected ERP procurement system for requests, approvals, supplier assignment, deliveries, goods receiving, credit purchases, accounts payable, reports, analytics, or AI insights.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added `ensureProcurementData` to upgrade existing ERP state with procurement records without wiping current data.
- Added `getProcurementWorkspaceData` as one backend payload for Overview, Requests, Orders, Suppliers, Deliveries, Receiving, Credit, Payables, Reports, Analytics, and AI.
- Added working backend workflow actions: create purchase request, approve request, generate purchase order, receive goods, and record supplier payment.
- Replaced the static Purchases table with a unified Procurement Operations Center with top tabs and shared filters.
- Added procurement search across requests, POs, suppliers, products, deliveries, invoices, GRNs, counties, warehouses, and statuses.
- Added procurement KPIs, main metric graph, workflow tracker, supplier scorecards, Kenya delivery intelligence, GRN variance tables, credit risk, AP aging, report exports, analytics, and AI insights from ERP records.
- Expanded `supabase-schema.sql` with procurement tables, indexes, RLS policies, and materialized views for spend, supplier performance, delivery performance, credit exposure, AP, forecasts, and replenishment.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Ran `getProcurementWorkspaceData` 10 times locally; every run returned valid POs, requests, suppliers, deliveries, GRNs, credit purchases, AP, reports, analytics, AI insights, and search index.
- Ran the full local workflow: create request -> approve request -> generate PO -> receive goods -> generate supplier invoice/AP -> record partial supplier payment.

Notes / next steps:
- Apply the updated `supabase-schema.sql` in Supabase SQL Editor to create the normalized procurement tables and materialized views. Until then, the live app uses the Supabase JSON bridge for this module.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getProcurementWorkspaceData` returns 8 POs, 8 requests, 8 deliveries, 4 GRNs, 8 credit purchases, 8 AP rows, 12 reports, 6 trend points, 3 AI insights, and 36 searchable records.
- Verified live Purchases browser route renders the Procurement Operations Center overview with KPI cards, shared filters, main chart, and workflow tracker.
- Verified live Receiving, Payables, Reports, and Analytics tabs open without errors.
- Verified live procurement search returns connected PO, GRN, and AP records for supplier search.

## 2026-06-09 - Inventory Intelligence Platform Rebuild

Target area:
Inventory module, stock management, warehouse operations, movements, adjustments, transfers, reorder alerts, reports, analytics, forecasting, Supabase inventory schema

Reason:
Inventory needed to become an operational stock control workspace, not a static table. The business needs working stock visibility, low-stock alerts, adjustment posting, stock transfers, warehouse intelligence, expiry and damaged stock tracking, report exports, analytics, and reorder actions connected to procurement.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added `ensureInventoryData` to enrich existing ERP state with warehouses, locations, inventory transactions, batches, alerts, reorder rules, slow/dead stock, damage records, audits, costs, documents, forecasts, reports, and health scores without wiping existing records.
- Added `getInventoryWorkspaceData` as one connected backend payload for Overview, Stock, Warehouses, Movements, Adjustments, Transfers, Receiving, Dispatch, Audits, Expiry, Damaged, Alerts, Reports, Analytics, Forecasting, and AI.
- Replaced the generic Inventory table with a unified Inventory Intelligence Platform using tabs, shared filters, global inventory search, KPI cards, a main metric graph, and operational tables.
- Added working backend mutations for stock adjustment, stock transfer, and inventory-triggered purchase request creation.
- Added alert-center actions so low-stock items can create procurement requests from Inventory.
- Added report export buttons for Inventory Valuation, Stock Movement, Low Stock, Expiry, Damage, Warehouse Utilization, Audit Variance, Reorder, Forecasting, Cost, Dead Stock, Slow Moving, Batch Traceability, and Stock Accuracy reports.
- Added Supabase inventory tables, indexes, RLS policies, and materialized views for summaries, value, movements, turnover, expiry, damage, reorders, forecasts, costs, and health scoring.
- Added inventory-specific visual styling and currency formatting for all major stock/cost fields.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Ran `getInventoryWorkspaceData` 10 times locally; every pass returned 10 SKUs, 10 stock items, 4 warehouses, 40 movements, 10 alerts, 14 reports, 10 forecasts, 10 health scores, and 70 searchable records.
- Validated local workflow: post stock adjustment -> movement created; transfer stock -> transfer record created; low-stock item -> purchase request created.

Notes / next steps:
- Apply the updated `supabase-schema.sql` in Supabase SQL Editor to create the normalized inventory tables and materialized views. Until then, the live app uses the Supabase JSON bridge for this module.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getInventoryWorkspaceData` returns 10+ SKUs, 10+ stock items, 4 warehouses, 40+ movements, 10 alerts, 14 reports, 10 forecasts, 10 health scores, and 70 searchable records.
- Verified live workflow: stock adjustment creates a movement and stock transfer creates a transfer record.
- Verified live Inventory browser route renders the Inventory Intelligence Platform with Overview, Stock, Alerts, Reports, Analytics, Stock Adjustment modal, and Transfer Stock modal.

## 2026-06-09 - Enterprise Reporting Engine Date Range & Export Upgrade

Target area:
Reports module, embedded Sales reports, Inventory reports, Procurement reports, date-range filters, exports, scheduling, email queue, Supabase reporting audit schema

Reason:
Reports needed start-date/end-date selection and working exports across modules. The previous Reports page only showed sales KPIs, and several report buttons on module pages did not generate filtered files.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added a full Enterprise Report Center with module selection, report selection, start date, end date, warehouse, and status filters.
- Added auto-regenerated KPIs, trend chart, report table, archive table, and schedule table based on the selected filters.
- Added server-side `getReportCenterData`, `generateReportExport`, `scheduleReport`, and `emailReport` endpoints.
- Added CSV, Excel-compatible, PDF/print-ready HTML, PowerPoint-ready HTML, and print actions with non-empty filtered content.
- Added working email queue and scheduled report creation flows with audit logging in the ERP state.
- Added start/end date controls and real export behavior to Sales, Inventory, and Procurement embedded report tabs.
- Added Supabase tables, indexes, and RLS policies for `report_templates`, `report_exports`, `report_archive`, `report_schedules`, `report_recipients`, `report_email_logs`, `report_generation_logs`, `report_download_logs`, `report_filters`, and `report_permissions`.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Validated report-center generation for Executive, Sales, Inventory, Procurement, Financial, Production, Customer, Employee, and Analytics modules.
- Validated CSV, Excel-compatible, and PDF/print-ready exports return populated files.
- Validated schedule creation and email queue endpoints.
- Rechecked module defaults so Sales exports Sales Performance Report, Inventory exports Inventory Valuation Report, Procurement exports Supplier Performance Report, and Financial exports Financial Summary Report by default.

Notes / next steps:
- True binary PDF/XLSX/PPTX generation should move to a server-side export worker when the normalized Supabase schema is applied. The current implementation generates populated CSV/XLS-compatible files and professional print-ready HTML packages for PDF/PowerPoint workflows.
- Deployed to `https://erpftc.vercel.app`.
- Verified live `getReportCenterData` for Inventory with `2026-01-01` to `2026-12-31` returns Inventory Valuation Report, 10+ rows, 10 reports, and populated export content.
- Verified live Reports browser route renders module/report selectors, start date, end date, warehouse/status filters, export actions, filtered data table, archive table, and scheduled reports area.

## 2026-06-09 - Typography Foundation Upgrade

Target area:
Global app typography, internal pages, forms, tables, buttons, report controls

Reason:
The app interior needed to use Bahnschrift while preserving the existing page header hierarchy and dashboard layout.

Files changed:
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Updated the global app font stack to Bahnschrift with Windows-friendly fallbacks.
- Extended inherited font behavior to selects and textareas so forms and filters match the rest of the ERP.
- Preserved existing heading sizes, weights, spacing, and layout behavior.

Verification:
- Ran `npm run build`.

## 2026-06-09 - Interaction Repair: Analytics, Dashboard Actions, Sales Orders, Delivery Confirmation

Target area:
Analytics tabs, Dashboard command buttons, Sales workspace actions, order-to-delivery workflow, Supabase delivery confirmation

Reason:
Analytics tab switching changed state but much of the visible content stayed generic. Dashboard action buttons and Sales workflow buttons were mostly visual. Sales also needed a working path to create new records and connect orders to deliveries with a delivered confirmation checkbox.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Made Dashboard attention and recommended-action buttons navigate to the relevant ERP modules.
- Made Analytics tabs show active-tab drilldowns and active-tab reports so switching tabs visibly changes content beyond the chart.
- Added a global New Sales Order flow from the topbar and Sales workspace.
- Added sales order creation that creates sale, sale item, invoice, invoice item, delivery, delivery items, and inventory deduction in one backend transaction flow.
- Added quotation Send and Convert actions wired to backend mutations.
- Added Sales Orders + Delivery Confirmation table with delivered checkbox tied to the generated delivery record.
- Added backend delivery confirmation endpoint that updates delivery status and linked order delivery status.
- Added Supabase delivery confirmation columns, indexes, and `confirm_sales_delivery` function.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel or Supabase secrets are stored in source files.
- Validated local workflow: create sales order -> generated invoice and delivery -> confirm delivered -> Sales workspace shows Delivered.
- Validated all 9 Analytics tabs return unique payloads with KPIs, trends, and reports.
- Deployed to `https://erpftc.vercel.app`.
- Verified live API creates a sales order, generated invoice, generated delivery, and confirms delivery as Delivered.
- Verified live Analytics tab switching changes active KPIs, chart title, drilldown title, active reports, and AI status.
- Verified live Sales Orders tab shows the delivery confirmation table and delivery queue.
- Verified live New Sales Order button opens the modal form.

## 2026-06-09 - Backend Backbone, Input Center, Finance Posting Upgrade

Target area:
ERP backend reliability, data input, event trail, Finance integration, Sales-to-Delivery-to-Ledger flow, Supabase schema readiness

Reason:
The ERP needed one dependable operational backbone so new data inputs do not remain trapped inside isolated modules. Sales, Procurement, Inventory, Finance, Reports, Dashboard, and Audit needed to cooperate through shared events, generated records, and balanced finance posting.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added an Input Center with dynamic forms for customers, suppliers, products, inventory, sales orders, purchase requests, expenses, payments, manual journals, tasks, and production jobs.
- Added backend `getInputCenterData` and `submitERPInput` endpoints with live lookup data and recent event/audit visibility.
- Added business-event recording for created/updated records and submitted input workflows.
- Added Finance projection data for chart of accounts, journals, ledger, banking, receivables, payables, tax, payroll, assets, budgets, cost centers, forecasts, reports, audit logs, and AI insights.
- Added balanced finance posting for new sales orders: revenue, VAT, COGS, inventory, receivables, and customer receipts.
- Added balanced finance posting for procurement receiving and supplier payments.
- Added top-level return identifiers from input submissions so UI actions can use generated sale, invoice, and delivery IDs directly.
- Added Supabase-ready backend tables for finance records, financial materialized views, input batches, input records, validation logs, and event processing logs.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel/Supabase credential values are stored in source files.
- Ran a full workflow check: login -> load Input Center -> create sale input -> create manual journal -> Finance journals increased -> Sales workspace shows the order -> delivery confirmed Delivered -> business events recorded.
- Ran the workflow loop 10 times successfully. Each pass created a sales order, generated invoice and delivery, posted balanced finance journals, confirmed delivery, and returned report rows.
- Last 10-pass check result: 10/10 passes, finance journals reached 294, last delivery status was Delivered, and Sales report returned 28 rows.

Notes / next steps:
- The live app can run now through the existing Supabase JSON state bridge.
- For long-term scale, apply the expanded `supabase-schema.sql` in Supabase SQL Editor so the normalized finance/input/event tables and materialized views become the system of record.
- The next performance upgrade should split the large frontend bundle into route-level chunks.

## 2026-06-09 - Finance Visible Operating Center Upgrade

Target area:
Finance page UI, finance actions, ledger health, reconciliation, and direct posting workflows

Reason:
Finance had backend improvements, but the page did not visibly feel different enough. It still looked like normal tables behind tabs. Finance needed a clear operating-center layout with visible controls and direct actions.

Files changed:
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Renamed the page experience to `Finance Operating Center` with visible `Finance v2` status language.
- Added a finance health strip for journal balance, audit lock, trial balance, and posting coverage.
- Added direct Finance actions for Manual Journal, Record Expense, and Receive Payment.
- Added dashboard panels for Quick Posting Center, Trial Balance Check, Controls & Exceptions, Department Integration Flow, and Bank & Cash Position.
- Added a Reconciliation tab with bank reconciliation status and transaction workbench.
- Added working Finance Expense and Customer Payment modals directly inside Finance.
- Preserved the full Finance tab set: ledger, accounts, journals, receivables, payables, banking, cash, expenses, revenue, payroll, taxes, assets, budgeting, reconciliation, reports, audit, cost centers, forecasting, and AI.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Validated backend Finance actions: manual journal posting, finance expense posting, customer payment posting, report availability, audit availability, source-flow availability, and zero unbalanced journals.
- Finance validation result: journals increased from 204 to 207, accounts 20, ledger lines 414, reports 17, audit rows 207, unbalanced journals 0.

## 2026-06-09 - Manufacturing UOM, Batch Traceability, and Production Ecosystem Upgrade

Target area:
Manufacturing workspace, raw material input, unit conversion, production orders, batch traceability, inventory, finance posting, Supabase manufacturing schema

Reason:
Manufacturing was still a generic production table. It needed to become a real production ecosystem where raw materials are received in user-friendly units, converted automatically, reserved, consumed, traced by batch, converted into finished goods, and connected to Finance/Inventory/Reports.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `supabase-schema.sql`
- `UPGRADE_LOG.md`

Improvements:
- Added an advanced UOM conversion engine for KG, G, MG, TONNE, L, ML, PCS, BOTTLE, PACKET, BOX, CARTON, and BAG.
- Added automatic conversion preview and backend conversion validation. Example: `500 KG = 500,000 G`, consume `250 G`, remaining `499,750 G`.
- Added raw material storage records with material code, category, UOM, quantities, supplier, cost, warehouse, storage location, batch, manufacture date, expiry date, and status.
- Added raw material batch lot tracking and receiving input workflow.
- Added formula/version data for finished products and material requirements.
- Added production order creation, start/reservation, complete/consume workflow.
- Added immutable material consumption history with material, batch used, quantity, unit, operator, date, production order, and cost consumed.
- Added finished production batch records, production costs, yields, production storage history, quality checks, downtime, capacity planning, calendar, documents, recalls, and manufacturing health scores.
- Added production completion integration with finished-goods inventory and balanced Finance journal posting.
- Replaced the generic Manufacturing data table with a dedicated `Production Ecosystem` workspace with tabs for dashboard, materials, batches, formulas, orders, consumption, traceability, quality, capacity, calendar, downtime, documents, recalls, reports, and AI.
- Added Supabase manufacturing tables and materialized views for manufacturing health, batch profitability, and batch traceability.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Confirmed no Vercel/Supabase credential values are stored in source files.
- Validated UOM conversion: `500 KG -> 500,000 G`, consume `250 G`, remaining `499,750 G`.
- Validated raw material receiving stores `500 KG` as `500,000 G`.
- Validated production order creation, production start, production completion, material consumption, finished batch creation, storage history, and Finance balance.
- Finance remained balanced after production completion with `0` unbalanced journals.

## 2026-06-09 - Manufacturing 10x Validation and Repair Pass

Target area:
Manufacturing input reliability, production workflow persistence, traceability counts, repeated production completion, inventory and Finance integration

Reason:
Manufacturing needed a top-to-bottom validation pass to ensure inputs and workflows stay functional across repeated runs, not only a single happy-path test.

Files changed:
- `api/rpc.js`
- `UPGRADE_LOG.md`

Repairs:
- Hardened production completion so all manufacturing traceability arrays are initialized before writing.
- Added mutation-level traceability counts for consumption rows, finished production batches, and storage history.
- Verified completed batches are visible in the Manufacturing workspace after production completion.
- Verified each completion continues to update finished-goods inventory and posts a balanced Finance journal.

10x verification:
- Ran 10 manufacturing workflow passes successfully.
- Every pass validated `500 KG -> 500,000 G`, `250 G` consumption conversion, and `499,750 G` remaining math.
- Every pass received raw material input, created production order, started production, completed production, recorded material consumption, created finished batch, created storage history, updated inventory, and kept Finance balanced.
- Last pass result: `FG-1781015220326`, consumption rows `10`, production batches `10`, storage rows `10`, Finance journals `224`.
- Final build passed with only the existing bundle-size warning.

## 2026-06-09 - Candara Typography Readability Upgrade

Target area:
Global typography, thin labels, table headers, muted captions, form labels, hero support text

Reason:
Several thin text areas were hard to read. The app needed Candara as the main font and stronger weights/colors for muted supporting text without changing page layout.

Files changed:
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Changed the global font stack from Bahnschrift to Candara.
- Strengthened body text weight.
- Increased readability for thin captions, labels, table headers, form labels, muted text, hero subtitles, and helper text.
- Preserved existing layout, spacing, colors, and module structure.

Verification:
- Ran `npm run build`.
- Confirmed no `Bahnschrift` references remain in `src/styles.css`.

## 2026-06-09 - Bundle Split and Numeric Font Rollback

Target area:
Frontend production bundle, number typography

Reason:
The production build warned that the single app chunk was too large. The app also needed only numeric values to keep the previous number-font feel while the rest of the UI remains Candara.

Files changed:
- `vite.config.js`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added Vite manual chunk splitting for React, Recharts, D3, and Lucide icons.
- Removed the oversized single JavaScript bundle warning.
- Restored Bahnschrift-style typography for numeric values only, including KPI values, table values, hero stats, finance totals, manufacturing quantities, report values, and badges.
- Kept Candara as the main UI text font.

Verification:
- Ran `npm run build`.
- Build completed without the previous chunk-size warning.
- Output chunks included `index` around 100 KB, `recharts-vendor` around 340 KB, `react-vendor` around 172 KB, `d3-vendor` around 63 KB, and `icons-vendor` around 14 KB.

## 2026-06-10 - Input Overlay, Time Filters, and Responsive Topbar Upgrade

Target area:
Global data entry, Analytics filters, Reports date controls, mobile topbar, typography

Reason:
The top `New` action needed to open real input workflows from every page. Analytics tabs and report date controls needed visible weekly/monthly/quarterly/yearly switching and custom date ranges. The topbar also needed to stay usable on smaller screens.

Files changed:
- `src/main.jsx`
- `src/styles.css`
- `api/rpc.js`
- `UPGRADE_LOG.md`

Improvements:
- Changed the main UI font to a softer Aptos/Segoe UI stack while keeping numeric values in Bahnschrift.
- Added a global `New ERP Record` overlay that works from any page.
- Added live input modules for customers, suppliers, products, inventory, sales orders, purchase requests, expenses, payments, journals, tasks, production jobs, and raw material receipts.
- Added Supabase-backed raw material receipt routing through `submitERPInput`, including UOM conversion such as `500 KG -> 500,000 G`.
- Added lookup support for units of measure, warehouses, raw materials, production orders, accounts, customers, suppliers, products, and invoices.
- Added visible Analytics period controls for Weekly, Monthly, Quarterly, and Yearly plus custom `From` and `To` dates.
- Updated Analytics backend filtering so selected periods/date ranges change the returned data and trend labels.
- Added report quick-range controls for Weekly, Monthly, Quarterly, and Yearly alongside custom start/end dates.
- Reworked mobile topbar behavior so search, period controls, notifications, New, and user button wrap instead of disappearing.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Ran RPC workflow checks for login, input metadata, raw material receipt, sales order creation, analytics weekly filtering, and report CSV export.
- Local HTTP check returned `200` from `http://127.0.0.1:5173`.

## 2026-06-10 - Enterprise SaaS Typography Upgrade

Target area:
Global typography, headings, body text, numeric/KPI values

Reason:
The ERP needed a more polished high-end SaaS typography system. The selected stack is Plus Jakarta Sans for headings and Inter for body text and numbers.

Files changed:
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added Google Fonts import for Plus Jakarta Sans and Inter.
- Changed body, controls, forms, and tables to Inter.
- Changed headings, hero titles, panel titles, modal titles, and brand headings to Plus Jakarta Sans.
- Changed numeric/KPI values from Bahnschrift to Inter with tabular figures for clean alignment.

Verification:
- Ran `npm run build`.
- Build completed successfully with the new Plus Jakarta Sans / Inter typography stack.

## 2026-06-10 - CRM Workspace and Input Upgrade

Target area:
CRM dashboard, pipeline board, customer cards, CRM inputs, CRM reports/analytics

Reason:
CRM needed to become a real customer lifecycle workspace instead of a simple customer table. The new design follows the requested CRM reference direction with kanban pipeline, customer cards, activities, calls, reports, and working input modals.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added backend `getCRMWorkspaceData` with customer KPIs, funnel stages, activities, calls, top customers, monthly trends, and CRM reports.
- Replaced the generic CRM customer table with a dedicated CRM workspace.
- Added CRM overview, pipeline board, customer directory, leads, calls, activities, reports, and analytics tabs.
- Added CRM modals for New Customer, New Opportunity, and Log Call.
- Added CRM lead and call modules to the global Input Center and top `New` overlay.
- Styled CRM with a modern green SaaS layout, kanban columns, pipeline cards, customer cards, activity rows, and top customer panels.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Ran CRM RPC workflow checks for workspace loading, customer creation, lead/opportunity creation, call logging, and refreshed CRM counts.

## 2026-06-10 - Enterprise Report Document Factory Upgrade

Target area:
Reports, downloads, exports, report archive, source modules, official document outputs

Reason:
Reports needed to behave like an official document factory similar to QuickBooks: searchable, filterable, downloadable, printable, archived, and sourced from all departments rather than acting like another analytics page.

Files changed:
- `api/rpc.js`
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Expanded Report Center modules to Executive, Sales, Customer, Inventory, Procurement, Manufacturing, Financial, Payroll, Tax, Delivery, Employee, Analytics, and Custom.
- Added report categories and a structured report library.
- Added a larger report template catalog including sales, customer, inventory, procurement, manufacturing, delivery, payroll, tax, finance, employee, analytics, and custom reports.
- Expanded export outputs to 10 formats: PDF, Excel, CSV, PowerPoint, Word, JSON, XML, Print, Email Package, and ZIP Bundle.
- Added backend export generation for JSON, XML, Word-style document output, Email Package, and ZIP Bundle placeholder packages.
- Kept archive logging for every generated export.
- Updated the Report Center UI with QuickBooks-style report categories, template cards, date filters, export actions, archive, schedules, and filtered rows.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Ran 10 report export passes across Sales, Customer, Inventory, Procurement, Manufacturing, Financial, Tax, Delivery, Payroll, and Executive reports.
- Verified all 10 export formats generated downloadable files with archive records.

## 2026-06-10 - QuickBooks-Style Report Output Workflow Upgrade

Target area:
Report output actions, preview, download, print, packages, archive re-download

Reason:
Report outputs needed to feel complete, not just a grid of export buttons. The workflow now behaves more like a report output center: choose format, preview, download, print, email, schedule, package, and re-download from archive.

Files changed:
- `src/main.jsx`
- `src/styles.css`
- `UPGRADE_LOG.md`

Improvements:
- Added an Output Center panel with selectable output format.
- Added Preview action that opens the official report layout.
- Added Download action for the selected format.
- Added Print action that opens the print layout and triggers browser print.
- Added Package action for ZIP Bundle output.
- Added All Export Formats panel for direct one-click downloads.
- Replaced static archive table with a Report Archive list that can re-download archived reports.
- Added responsive styling for output actions and archive rows.

Verification:
- Ran `node --check api/rpc.js`.
- Ran `npm run build`.
- Ran focused output workflow test for PDF preview generation, JSON download, ZIP Bundle package, archive creation, and archive re-download.
