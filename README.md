# Rental Mediator ERP

This branch changes the ZenGhunt website frontend into a first-stage Rental Mediator ERP prototype.

## What is included
- Responsive project-control dashboard and staff navigation.
- Customer and vendor master records, machine records, projects, monthly customer invoices, vendor bills, payments, document references and follow-ups.
- One Project ID linking project records.
- Project closure checklist requiring machine return, commercial settlement, document completion and reconciliation.
- Browser JSON backup export.

## Current test status
This branch is connected only to the dedicated **Trident ERP Test** Supabase project. After an active staff member signs in, the master-data screens load and save through Supabase. The browser retains a `localStorage` fallback from the original prototype; it is not a shared source of truth and must not be used for real customer, tax, bank or confidential data.

This is **not production-ready**. Test data only: role policies, document permissions, accounting controls, migration reconciliation and full end-to-end tests still require deliberate review.

## Supabase schema blueprint
`supabase/rental_erp_schema.sql` is a database schema draft for review and test deployment. `supabase/rental_erp_security_hardening.sql` is a separate draft migration for a private document bucket and row-change audit trail. `supabase/rental_erp_payment_allocation_checks.sql` drafts database checks to prevent cross-project or wrong-side allocations and prevent allocations exceeding the recorded payment. It is not automatically applied to the existing Supabase project. It now requires an explicitly provisioned active staff profile for ERP table access, but active staff currently have broad access; role-specific permissions, private Storage policies, audit history and accounting safeguards still need implementation and review. Test in a separate project, then apply deliberately. Do not place the service-role key in browser code.

## Next implementation steps
1. Confirm the screens and fields against the existing master workbook and agreed workflow.
2. Test the schema in a separate Supabase project; add staff authentication, roles, audit history and private document storage.
3. Connect the UI to Supabase using the publishable key and authenticated sessions.
4. Migrate existing source data with a backup and a reconciliation report; keep ambiguous historical values marked Verify/Pending.
5. Test one complete project end-to-end before moving the production website to this branch.

## Branch safety
This work is isolated on `test/supabase-isolation` and the Test Supabase project. The `main` branch, production Supabase project, public website, Google Sheets and unrelated equipment systems are out of scope and must remain untouched.
