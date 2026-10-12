# Rental Mediator ERP — Development Tool Setup

This guide is for the `rental-erp-rebuild` branch. The production `main` branch is not changed by this guide.

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

## Current project status
The ERP UI is a prototype and currently stores records in browser localStorage. It is not multi-user, is not connected to Supabase, and should not contain real confidential financial data. The SQL file in `supabase/rental_erp_schema.sql` is a draft only; it has not been applied to a database.

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
