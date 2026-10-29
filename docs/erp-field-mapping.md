# Trident ERP field mapping

Scope: ERP tables only. Do not modify the separate Trident website or equipment_categories, equipment, and equipment_enquiries.

## Existing Excel-to-ERP mapping
- Project code, name, status -> erp_projects.
- Customer / Lease To -> erp_customers, linked by erp_projects.customer_id.
- Vendor / Lease From -> erp_vendors, linked by erp_projects.vendor_id.
- Site, city, state -> erp_sites and project site snapshot fields.
- Machine and assignment dates -> erp_machines and erp_project_machines.
- Customer invoices -> erp_customer_invoices.
- Supplier invoices -> erp_vendor_bills.
- Payments, advances and TDS -> erp_payments.
- Payment-to-invoice allocations -> erp_invoice_allocations.
- PO, PR, invoice and certificate files -> erp_documents and private rental-erp-documents storage.
- Follow-up tasks -> erp_followups.
- PO revisions -> erp_po_revisions.

## Fields needing structured support
Quantity/UOM per line, tax rates, freight, transporter charges, operator terms, payment terms, days per month, work hours per day, de-hire notice, debit notes and inter-project transfers may need dedicated fields/tables before automated reports are reliable.

## Validation flags
1. Missing project/customer/vendor or invoice details.
2. Rental dates disagree with the billing period.
3. Invoice total differs from subtotal plus GST.
4. Payment is unallocated or allocated beyond its available balance.
5. Customer/vendor advance exceeds invoices/bills; show as provisional credit/advance, not profit.
6. Closed projects have incomplete machine return, documents, bills, payments or reconciliation.
7. Hold projects have new billing/payment activity.
8. Duplicate invoice numbers or missing debit-note/freight/transporter details.
9. Payment references another project and may require explicit transfer classification.

## Workbook cases to test
- PRJ001: payment/reference associated with PRJ003; verify whether this is an inter-project transfer.
- PRJ002: supplier/rate details incomplete while marked Closed.
- PRJ003: Hold status with advance/transfer entries.
- PRJ004: debit-note/invoice follow-up and incomplete transporter details.
- PRJ005: September billing period vs rental dates 2026-09-24 to 2026-10-04. Recorded customer payment INR 200000 vs invoice total INR 173460 gives a provisional difference INR 26540 before considering other entries.

No workbook records have been imported by this document. The current frontend still uses localStorage prototype data; live Supabase CRUD and testing are required before production use. Never put service-role credentials in frontend code.
