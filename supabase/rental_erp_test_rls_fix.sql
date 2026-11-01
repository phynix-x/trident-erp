-- Trident ERP TEST-only RLS recursion fix
-- Apply only after the base ERP schema and role policies exist.
-- This uses a private security-definer helper so RLS policies never query
-- erp_staff_profiles recursively. It changes no business rows.

begin;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.erp_current_staff_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.role
  from public.erp_staff_profiles p
  where p.user_id = (select auth.uid())
    and p.is_active = true
  limit 1
$$;

revoke all on function private.erp_current_staff_role() from public;
grant execute on function private.erp_current_staff_role() to authenticated;

drop policy if exists "staff profile delete" on public.erp_staff_profiles;
drop policy if exists "staff profile insert" on public.erp_staff_profiles;
drop policy if exists "staff profile read" on public.erp_staff_profiles;
drop policy if exists "staff profile update" on public.erp_staff_profiles;

create policy "staff profile read"
on public.erp_staff_profiles for select to authenticated
using (
  user_id = (select auth.uid())
  or (select private.erp_current_staff_role()) = 'admin'
);
create policy "staff profile insert"
on public.erp_staff_profiles for insert to authenticated
with check ((select private.erp_current_staff_role()) = 'admin');
create policy "staff profile update"
on public.erp_staff_profiles for update to authenticated
using ((select private.erp_current_staff_role()) = 'admin')
with check ((select private.erp_current_staff_role()) = 'admin');
create policy "staff profile delete"
on public.erp_staff_profiles for delete to authenticated
using ((select private.erp_current_staff_role()) = 'admin');

do $$
declare
  t text;
begin
  foreach t in array array[
    'erp_customers','erp_vendors','erp_sites','erp_machines','erp_projects',
    'erp_project_machines','erp_customer_invoices','erp_vendor_bills','erp_payments',
    'erp_invoice_allocations','erp_documents','erp_followups','erp_po_revisions'
  ]
  loop
    execute format('drop policy if exists "active staff read" on public.%I', t);
    execute format('drop policy if exists "role insert" on public.%I', t);
    execute format('drop policy if exists "role update" on public.%I', t);
    execute format('drop policy if exists "role delete" on public.%I', t);

    execute format(
      'create policy "active staff read" on public.%I for select to authenticated using ((select private.erp_current_staff_role()) is not null)',
      t
    );
    execute format(
      'create policy "role insert" on public.%I for insert to authenticated with check ((select private.erp_current_staff_role()) = any (array[''admin'', ''manager'', ''operations'']))',
      t
    );
    execute format(
      'create policy "role update" on public.%I for update to authenticated using ((select private.erp_current_staff_role()) = any (array[''admin'', ''manager'', ''operations''])) with check ((select private.erp_current_staff_role()) = any (array[''admin'', ''manager'', ''operations'']))',
      t
    );
    execute format(
      'create policy "role delete" on public.%I for delete to authenticated using ((select private.erp_current_staff_role()) = any (array[''admin'', ''manager'']))',
      t
    );
  end loop;
end $$;

drop policy if exists "erp_activity_log_admin_manager_insert" on public.erp_activity_log;
drop policy if exists "erp_activity_log_admin_read" on public.erp_activity_log;
create policy "erp_activity_log_admin_read"
on public.erp_activity_log for select to authenticated
using ((select private.erp_current_staff_role()) = 'admin');
create policy "erp_activity_log_admin_manager_insert"
on public.erp_activity_log for insert to authenticated
with check ((select private.erp_current_staff_role()) in ('admin','manager'));

drop policy if exists "ERP authorized staff delete documents" on storage.objects;
drop policy if exists "ERP authorized staff update documents" on storage.objects;
drop policy if exists "ERP authorized staff upload documents" on storage.objects;
drop policy if exists "ERP staff read documents" on storage.objects;

create policy "ERP staff read documents"
on storage.objects for select to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and (select private.erp_current_staff_role()) is not null
);
create policy "ERP authorized staff upload documents"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'rental-erp-documents'
  and (select private.erp_current_staff_role()) in ('admin','manager','operations','accounts')
);
create policy "ERP authorized staff update documents"
on storage.objects for update to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and (select private.erp_current_staff_role()) in ('admin','manager','operations','accounts')
)
with check (
  bucket_id = 'rental-erp-documents'
  and (select private.erp_current_staff_role()) in ('admin','manager','operations','accounts')
);
create policy "ERP authorized staff delete documents"
on storage.objects for delete to authenticated
using (
  bucket_id = 'rental-erp-documents'
  and (select private.erp_current_staff_role()) in ('admin','manager')
);

commit;
