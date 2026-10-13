-- Rental Mediator ERP security hardening migration (DRAFT).
-- Apply only after rental_erp_schema.sql has been reviewed and applied to a dedicated TEST project.
-- Review role rules with the business owner before production.
begin;

-- Private document bucket. Never use public document URLs for invoices, POs, GST/TDS files.
insert into storage.buckets (id, name, public)
values ('rental-erp-documents', 'rental-erp-documents', false)
on conflict (id) do update set public = false;

drop policy if exists "active staff read ERP documents" on storage.objects;
create policy "active staff read ERP documents"
on storage.objects for select to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid() and p.is_active = true
  )
);

drop policy if exists "active staff upload ERP documents" on storage.objects;
create policy "active staff upload ERP documents"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'rental-erp-documents'
  and exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid() and p.is_active = true
  )
);

drop policy if exists "active staff update ERP documents" on storage.objects;
create policy "active staff update ERP documents"
on storage.objects for update to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid() and p.is_active = true
  )
)
with check (
  bucket_id = 'rental-erp-documents'
  and exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid() and p.is_active = true
  )
);

drop policy if exists "active staff delete ERP documents" on storage.objects;
create policy "active staff delete ERP documents"
on storage.objects for delete to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid() and p.is_active = true
  )
);

-- Audit trail for key business records. Stores row snapshots; do not store secrets in these tables.
create table if not exists public.erp_audit_log (
  id bigint generated always as identity primary key,
  table_name text not null,
  record_id text,
  action text not null check (action in ('INSERT','UPDATE','DELETE')),
  actor_user_id uuid,
  changed_at timestamptz not null default now(),
  old_row jsonb,
  new_row jsonb
);
alter table public.erp_audit_log enable row level security;
drop policy if exists "admin manager read ERP audit log" on public.erp_audit_log;
create policy "admin manager read ERP audit log"
on public.erp_audit_log for select to authenticated
using (
  exists (
    select 1 from public.erp_staff_profiles p
    where p.user_id = auth.uid()
      and p.is_active = true
      and p.role in ('admin','manager')
  )
);

create or replace function public.erp_write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_old jsonb;
  v_new jsonb;
  v_id text;
begin
  if TG_OP = 'INSERT' then
    v_new := to_jsonb(NEW);
    v_id := coalesce(v_new->>'id', v_new->>'project_code', v_new->>'customer_code', v_new->>'vendor_code');
  elsif TG_OP = 'UPDATE' then
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
    v_id := coalesce(v_new->>'id', v_new->>'project_code', v_new->>'customer_code', v_new->>'vendor_code');
  else
    v_old := to_jsonb(OLD);
    v_id := coalesce(v_old->>'id', v_old->>'project_code', v_old->>'customer_code', v_old->>'vendor_code');
  end if;

  insert into public.erp_audit_log(table_name, record_id, action, actor_user_id, old_row, new_row)
  values (TG_TABLE_NAME, v_id, TG_OP, auth.uid(), v_old, v_new);

  if TG_OP = 'DELETE' then return OLD; end if;
  return NEW;
end;
$$;
revoke all on function public.erp_write_audit_log() from public;

do $$
declare t text;
begin
  foreach t in array array[
    'erp_customers','erp_vendors','erp_sites','erp_machines','erp_projects',
    'erp_project_machines','erp_customer_invoices','erp_vendor_bills','erp_payments',
    'erp_invoice_allocations','erp_documents','erp_followups','erp_po_revisions'
  ]
  loop
    execute format('drop trigger if exists erp_audit_row_change on public.%I', t);
    execute format('create trigger erp_audit_row_change after insert or update or delete on public.%I for each row execute function public.erp_write_audit_log()', t);
  end loop;
end $$;

commit;

-- Still required before production:
-- 1. Replace broad active-staff table policies with role-specific permissions.
-- 2. Restrict file operations by project membership/assignment where appropriate.
-- 3. Add tests for role escalation, unauthorized reads/writes, document access and audit immutability.
-- 4. Confirm retention rules for financial and personal data.
