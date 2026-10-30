# Rental Mediator ERP

This branch changes the ZenGhunt website frontend into a first-stage Rental Mediator ERP prototype.

## What is included
- Responsive project-control dashboard and staff navigation.
- Customer and vendor master records, machine records, projects, monthly customer invoices, vendor bills, payments, document references and follow-ups.
- One Project ID linking project records.
- Project closure checklist requiring machine return, commercial settlement, document completion and reconciliation.
- Browser JSON backup export.

## Important current limitation
The current prototype saves records in the browser's localStorage. That means data is local to that browser/device and is not shared with other staff. It is not production-ready for real customer, tax, bank or confidential data. It currently does not authenticate staff, upload files, or connect the screens to Supabase.

## Supabase schema blueprint
`supabase/rental_erp_schema.sql` is a database schema draft for review and test deployment. `supabase/rental_erp_security_hardening.sql` is a separate draft migration for a private document bucket and row-change audit trail. `supabase/rental_erp_payment_allocation_checks.sql` drafts database checks to prevent cross-project or wrong-side allocations and prevent allocations exceeding the recorded payment. It is not automatically applied to the existing Supabase project. It now requires an explicitly provisioned active staff profile for ERP table access, but active staff currently have broad access; role-specific permissions, private Storage policies, audit history and accounting safeguards still need implementation and review. Test in a separate project, then apply deliberately. Do not place the service-role key in browser code.

## Next implementation steps
1. Confirm the screens and fields against the existing master workbook and agreed workflow.
2. Test the schema in a separate Supabase project; add staff authentication, roles, audit history and private document storage.
3. Connect the UI to Supabase using the publishable key and authenticated sessions.
4. Migrate existing source data with a backup and a reconciliation report; keep ambiguous historical values marked Verify/Pending.
5. Test one complete project end-to-end before moving the production website to this branch.

## Existing project
This is a separate branch named `rental-erp-rebuild`. The `main` branch has not been changed by this conversion, so the current ZenGhunt site remains intact until a reviewed deployment is explicitly made.
Cloudflare preview deployment test
