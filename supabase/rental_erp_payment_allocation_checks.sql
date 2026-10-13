-- Rental Mediator ERP: payment allocation integrity checks (DRAFT).
-- Apply only after rental_erp_schema.sql in a dedicated test project.
-- Validates that allocations match payment side/project and do not exceed the payment.
begin;

create or replace function public.erp_validate_invoice_allocation()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  p_project uuid;
  p_side text;
  p_amount numeric(14,2);
  target_project uuid;
  allocated_elsewhere numeric(14,2);
begin
  select project_id, side, amount
    into p_project, p_side, p_amount
  from public.erp_payments
  where id = new.payment_id
  for update;

  if not found then
    raise exception 'Payment record not found';
  end if;

  if new.customer_invoice_id is not null then
    if p_side <> 'customer' then
      raise exception 'Only customer receipts can be allocated to customer invoices';
    end if;
    select project_id into target_project
    from public.erp_customer_invoices where id = new.customer_invoice_id;
  else
    if p_side <> 'vendor' then
      raise exception 'Only vendor payments can be allocated to vendor bills';
    end if;
    select project_id into target_project
    from public.erp_vendor_bills where id = new.vendor_bill_id;
  end if;

  if target_project is null then
    raise exception 'Target invoice or bill not found';
  end if;
  if target_project <> p_project then
    raise exception 'Payment and invoice/bill must belong to the same Project ID';
  end if;

  if new.allocated_amount < 0 then
    raise exception 'Allocated amount cannot be negative';
  end if;

  select coalesce(sum(a.allocated_amount), 0)
    into allocated_elsewhere
  from public.erp_invoice_allocations a
  where a.payment_id = new.payment_id
    and a.id <> coalesce(new.id, '00000000-0000-0000-0000-000000000000'::uuid);

  if allocated_elsewhere + new.allocated_amount > p_amount then
    raise exception 'Total allocations cannot exceed the payment amount';
  end if;

  return new;
end;
$$;
revoke all on function public.erp_validate_invoice_allocation() from public;

drop trigger if exists erp_validate_invoice_allocation on public.erp_invoice_allocations;
create trigger erp_validate_invoice_allocation
before insert or update on public.erp_invoice_allocations
for each row execute function public.erp_validate_invoice_allocation();

-- A payment can allocate to either a customer invoice or a vendor bill, never both.
-- The table's existing check constraint enforces exactly one target per allocation.
-- Prevent later edits to a payment from invalidating its existing allocations.
create or replace function public.erp_validate_payment_update_against_allocations()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $
declare
  allocated_total numeric(14,2);
  invalid_target_count integer;
begin
  select coalesce(sum(a.allocated_amount), 0)
    into allocated_total
  from public.erp_invoice_allocations a
  where a.payment_id = new.id;

  if allocated_total > new.amount then
    raise exception 'Payment amount cannot be reduced below its allocated total';
  end if;

  select count(*)
    into invalid_target_count
  from public.erp_invoice_allocations a
  left join public.erp_customer_invoices ci on ci.id = a.customer_invoice_id
  left join public.erp_vendor_bills vb on vb.id = a.vendor_bill_id
  where a.payment_id = new.id
    and (
      (a.customer_invoice_id is not null and (new.side <> 'customer' or ci.project_id is distinct from new.project_id))
      or
      (a.vendor_bill_id is not null and (new.side <> 'vendor' or vb.project_id is distinct from new.project_id))
    );

  if invalid_target_count > 0 then
    raise exception 'Payment side/project cannot change while incompatible allocations exist';
  end if;

  return new;
end;
$;
revoke all on function public.erp_validate_payment_update_against_allocations() from public;

drop trigger if exists erp_validate_payment_update_against_allocations on public.erp_payments;
create trigger erp_validate_payment_update_against_allocations
before update of amount, side, project_id on public.erp_payments
for each row execute function public.erp_validate_payment_update_against_allocations();

commit;

-- Test cases to run in the dedicated test project:
-- 1. Customer payment -> customer invoice, same project: succeeds.
-- 2. Customer payment -> vendor bill: fails.
-- 3. Payment allocated to a different project: fails.
-- 4. Two allocations whose total exceeds payment amount: second allocation fails.
-- 5. Updating an allocation while remaining under payment amount: succeeds.
