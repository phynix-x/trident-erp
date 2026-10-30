# Rental Mediator ERP — Development Tool Setup

This guide applies to the Trident ERP repository. Development changes should be reviewed in a feature branch and pull request before production deployment.

## Use now
- **VS Code**: edit and review application files.
- **Git + GitHub**: keep changes on the `rental-erp-rebuild` branch and review them in the draft pull request.
- **PowerShell / Windows Terminal**: run local checks and CLI commands.
- **7-Zip**: extract workbook backups and archive dated copies.
- **Postman**: test the API after the backend endpoints and authentication are configured.
- **DBeaver**: inspect database tables only after a dedicated test database has been provisioned and credentials are available.
- **WinMerge**: compare the original workbook/export with migration output before importing.

## Install only when needed
- **Docker Desktop**: useful if we run ERPNext or other container-based services locally. It is not required for editing the current static prototype.
- **WinSCP / PuTTY**: only needed if a separately managed server is selected. Do not create a server or share SSH credentials just to use these tools.
- **Notepad++**: optional; VS Code can already edit text, CSV, JSON and logs.
- **Wireshark**: optional network troubleshooting tool; not part of the normal build/test cycle.

## Safe environment rules
1. Keep the existing ZenGhunt Supabase project separate from the Rental ERP test database unless an explicit migration decision is made.
2. Never put a Supabase service-role/secret key in browser JavaScript, GitHub Pages files, screenshots, Postman shared collections, or commits.
3. Do not import historical workbook data until a dated backup and row-count/reconciliation report exist.
4. Keep ambiguous historic amounts, invoice allocations and missing documents marked `Verify/Pending`; do not invent values.
5. Do not merge the draft pull request or replace the live site until database, staff access, document permissions, migration and end-to-end tests pass.

## Current project status (verified 2026-10-31)
- The browser app authenticates with Supabase and the ERP JavaScript loads/saves records through Supabase; localStorage is used as a browser cache, not as the shared source of truth in live mode.
- The production Supabase project has the ERP schema, staff profiles, RLS, audit history, and a private document bucket from earlier approved setup. Do not assume every end-to-end workflow has been browser-tested.
- A separate **test** Supabase project is being used for role-policy and workflow validation. It has role-specific RLS policies, private document storage policies, payment function execution restrictions, and the `erp_activity_log` deletion-audit foundation.
- The test project currently has no provisioned staff profiles/test logins. Follow [First Admin Bootstrap](first-admin-bootstrap.md) before role testing.
- The test project's security advisor returned zero findings after the latest changes. Performance findings are INFO-level unused-index notices on an empty test database; no role-policy initplan or multiple-permissive-policy warning remained in the last check.
- No production migration for the test-only payment-allocation validation SQL has been applied. Do not apply it to production until tested separately.
- `supabase/rental_erp_schema.sql` is a blueprint/reference, not proof that production schema is created from that file.
- Do not use real confidential business data in the test project. Do not touch the separate Trident website or its equipment tables.

## Test checklist once backend is available
- Sign in as staff and verify access is restricted.
- Create one customer, vendor, site, machine and project.
- Verify all records remain linked to the same Project ID.
- Create a customer invoice and vendor bill; verify tax and TDS rules against approved business rules.
- Record a payment and explicitly allocate it to the intended invoice/bill.
- Upload a document and verify another unauthorized user cannot access it.
- Attempt project closure with each checklist item incomplete; closure must be blocked.
- Complete return, commercial settlement, documents and reconciliation; then verify closure is allowed.
- Export a backup and compare record counts and totals before/after a restore test.
