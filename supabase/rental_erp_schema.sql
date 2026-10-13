-- Rental Mediator ERP — Supabase schema blueprint
-- Review and apply in a TEST project first. This file is not automatically applied.
create extension if not exists pgcrypto;

create table if not exists public.erp_customers (
  id uuid primary key default gen_random_uuid(), customer_code text unique,
  legal_name text not null, gstin text, contact_person text, phone text, email text,
  billing_address text, city text, state text, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.erp_vendors (
  id uuid primary key default gen_random_uuid(), vendor_code text unique,
  legal_name text not null, gstin text, contact_person text, phone text, email text,
  address text, city text, state text, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.erp_sites (
  id uuid primary key default gen_random_uuid(), site_code text unique,
  name text not null, customer_id uuid references public.erp_customers(id),
  address text, city text, state text, contact_person text, phone text, notes text,
  created_at timestamptz not null default now()
);
create table if not exists public.erp_machines (
  id uuid primary key default gen_random_uuid(), machine_code text unique,
  name text not null, category text, serial_number text, owner_vendor_id uuid references public.erp_vendors(id),
  status text not null default 'Available' check(status in ('Available','Assigned','On rent','In transit','Maintenance','Returned')),
  notes text, created_at timestamptz not null default now()
);
create table if not exists public.erp_projects (
  id uuid primary key default gen_random_uuid(), project_code text not null unique,
  name text not null, customer_id uuid not null references public.erp_customers(id),
  vendor_id uuid not null references public.erp_vendors(id), site_id uuid references public.erp_sites(id),
  site_name text, site_city text, site_state text, machine_scope text,
  start_date date, expected_return_date date,
  customer_rate numeric(14,2) not null default 0, vendor_rate numeric(14,2) not null default 0,
  billing_rule text not null default 'Custom contract rule'
    check(billing_rule in ('Monthly','Daily','Pro-rata','Minimum guarantee','Custom contract rule')),
  contracted_days numeric(8,2), working_days numeric(8,2), non_working_days numeric(8,2), billable_days numeric(8,2),
  status text not null default 'Open',
  machine_returned boolean not null default false,
  commercial_settled boolean not null default false,
  documents_complete boolean not null default false,
  reconciled boolean not null default false,
  closed_at timestamptz, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (not (status = 'Closed') or (machine_returned and commercial_settled and documents_complete and reconciled))
);
create table if not exists public.erp_project_machines (
  id uuid primary key default gen_random_uuid(), project_id uuid not null references public.erp_projects(id) on delete cascade,
  machine_id uuid not null references public.erp_machines(id), assigned_from date, assigned_to date,
  contracted_days numeric(8,2), working_days numeric(8,2), non_working_days numeric(8,2), billable_days numeric(8,2),
  non_working_reason text, billing_rule text, notes text, created_at timestamptz not null default now()
);
create table if not exists public.erp_customer_invoices (
  id uuid primary key default gen_random_uuid(), invoice_code text unique,
  project_id uuid not null references public.erp_projects(id), invoice_number text not null,
  billing_month date not null, invoice_date date, due_date date,
  subtotal numeric(14,2) not null default 0, gst_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0, tds_expected numeric(14,2) not null default 0,
  status text not null default 'Draft', notes text,
  created_at timestamptz not null default now(), unique(project_id, invoice_number, billing_month)
);
create table if not exists public.erp_vendor_bills (
  id uuid primary key default gen_random_uuid(), bill_code text unique,
  project_id uuid not null references public.erp_projects(id), vendor_id uuid references public.erp_vendors(id),
  bill_number text, billing_month date not null, bill_date date, due_date date,
  subtotal numeric(14,2) not null default 0, gst_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0, tds_expected numeric(14,2) not null default 0,
  status text not null default 'Pending', notes text, created_at timestamptz not null default now()
);
create table if not exists public.erp_payments (
  id uuid primary key default gen_random_uuid(), project_id uuid not null references public.erp_projects(id),
  side text not null check(side in ('customer','vendor')), payment_date date not null,
  amount numeric(14,2) not null check(amount >= 0), tds_amount numeric(14,2) not null default 0,
  reference_number text, allocation_status text not null default 'Needs allocation',
  notes text, created_at timestamptz not null default now()
);
create table if not exists public.erp_invoice_allocations (
  id uuid primary key default gen_random_uuid(), payment_id uuid not null references public.erp_payments(id) on delete cascade,
  customer_invoice_id uuid references public.erp_customer_invoices(id),
  vendor_bill_id uuid references public.erp_vendor_bills(id),
  allocated_amount numeric(14,2) not null check(allocated_amount >= 0),
  created_at timestamptz not null default now(),
  check ((customer_invoice_id is not null)::int + (vendor_bill_id is not null)::int = 1)
);
create table if not exists public.erp_documents (
  id uuid primary key default gen_random_uuid(), project_id uuid not null references public.erp_projects(id) on delete cascade,
  document_type text not null, billing_month date, file_name text, storage_path text, external_url text,
  status text not null default 'Pending', uploaded_by uuid references auth.users(id),
  verified_by uuid references auth.users(id), verified_at timestamptz, notes text,
  created_at timestamptz not null default now()
);
create table if not exists public.erp_followups (
  id uuid primary key default gen_random_uuid(), project_id uuid references public.erp_projects(id) on delete cascade,
  title text not null, owner_user_id uuid references auth.users(id), owner_name text,
  due_date date, status text not null default 'Pending', notes text,
  created_at timestamptz not null default now(), completed_at timestamptz
);
create table if not exists public.erp_po_revisions (
  id uuid primary key default gen_random_uuid(), project_id uuid not null references public.erp_projects(id) on delete cascade,
  side text not null check(side in ('customer','vendor')), revision_number integer not null,
  revision_date date, document_id uuid references public.erp_documents(id),
  change_summary text, created_at timestamptz not null default now(),
  unique(project_id, side, revision_number)
);

-- Staff must be explicitly provisioned in this single-company workspace.
-- This schema is still a draft: table-specific role permissions and tenant isolation
-- must be reviewed before production. Do not use the service-role key in a browser.
create table if not exists public.erp_staff_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null check (role in ('admin','manager','accounts','operations','viewer')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.erp_staff_profiles enable row level security;
drop policy if exists "staff can read own profile" on public.erp_staff_profiles;
create policy "staff can read own profile" on public.erp_staff_profiles
  for select to authenticated using (user_id = auth.uid());

-- Only explicitly provisioned, active staff can access ERP tables.
-- Current draft grants active staff broad access; implement role-specific policies
-- before production (for example, viewers must not insert/update/delete financial data).
do $
declare t text;
begin
  foreach t in array array['erp_customers','erp_vendors','erp_sites','erp_machines','erp_projects',
    'erp_project_machines','erp_customer_invoices','erp_vendor_bills','erp_payments',
    'erp_invoice_allocations','erp_documents','erp_followups','erp_po_revisions']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "authenticated staff full access" on public.%I', t);
    execute format('drop policy if exists "active staff access" on public.%I', t);
    execute format(
      'create policy "active staff access" on public.%I for all to authenticated using (exists (select 1 from public.erp_staff_profiles p where p.user_id = auth.uid() and p.is_active = true)) with check (exists (select 1 from public.erp_staff_profiles p where p.user_id = auth.uid() and p.is_active = true))',
      t
    );
  end loop;
end $;

-- Consistent updated_at timestamps for mutable master/project records.
create or replace function public.erp_set_updated_at()
returns trigger language plpgsql set search_path = public
as $
begin
  new.updated_at = now();
  return new;
end;
$;
do $
declare t text;
begin
  foreach t in array array['erp_customers','erp_vendors','erp_projects','erp_staff_profiles']
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.erp_set_updated_at()', t);
  end loop;
end $;

create index if not exists idx_erp_projects_customer on public.erp_projects(customer_id);
create index if not exists idx_erp_projects_vendor on public.erp_projects(vendor_id);
create index if not exists idx_erp_invoice_project_month on public.erp_customer_invoices(project_id, billing_month);
create index if not exists idx_erp_vendor_bill_project_month on public.erp_vendor_bills(project_id, billing_month);
create index if not exists idx_erp_payments_project_date on public.erp_payments(project_id, payment_date);
create index if not exists idx_erp_documents_project_month on public.erp_documents(project_id, billing_month);
create index if not exists idx_erp_followups_due_status on public.erp_followups(due_date, status);

-- Recommended: create a PRIVATE Storage bucket named rental-erp-documents in Supabase Storage.
-- Add policies allowing authenticated users to read/write that bucket only after confirming staff access rules.
