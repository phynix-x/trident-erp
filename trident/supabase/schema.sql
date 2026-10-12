-- TRIDENT RENTAL PLATFORM
-- Apply in Supabase SQL editor after connecting the Trident project.
create extension if not exists pgcrypto;

create table if not exists public.equipment_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text,
  status text not null default 'active' check (status in ('active','coming_soon','inactive')),
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.equipment (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.equipment_categories(id) on delete restrict,
  name text not null,
  slug text not null unique,
  specification text,
  equipment_type text,
  application text,
  listed_quantity int not null default 0,
  status text not null default 'active' check (status in ('active','coming_soon','inactive')),
  featured boolean not null default false,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.equipment_images (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  image_url text not null,
  alt_text text,
  sort_order int not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.equipment_specifications (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  spec_name text not null,
  spec_value text not null,
  sort_order int not null default 0
);

create table if not exists public.locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  location_type text not null default 'office',
  address text,
  city text,
  state text,
  pincode text,
  phone text,
  email text,
  latitude numeric,
  longitude numeric,
  status text not null default 'active' check (status in ('active','inactive')),
  created_at timestamptz not null default now()
);

create table if not exists public.equipment_locations (
  equipment_id uuid references public.equipment(id) on delete cascade,
  location_id uuid references public.locations(id) on delete cascade,
  quantity int not null default 0,
  available_quantity int not null default 0,
  primary key (equipment_id, location_id)
);

create table if not exists public.industries (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists public.industry_equipment (
  industry_id uuid references public.industries(id) on delete cascade,
  equipment_id uuid references public.equipment(id) on delete cascade,
  primary key (industry_id, equipment_id)
);

create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  enquiry_number text unique not null default ('TT-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8))),
  customer_name text not null,
  company_name text,
  email text,
  phone text not null,
  equipment_id uuid references public.equipment(id) on delete set null,
  quantity int not null default 1,
  project_location text not null,
  start_date date,
  rental_duration text,
  message text,
  source text not null default 'website',
  status text not null default 'new' check (status in ('new','contacted','requirement_verified','quotation_sent','negotiation','confirmed','deployed','completed','cancelled','lost')),
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  assigned_to uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  company_name text,
  email text,
  phone text,
  designation text,
  industry_id uuid references public.industries(id) on delete set null,
  address text,
  city text,
  state text,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  excerpt text,
  content text,
  featured_image text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  seo_title text,
  seo_description text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.equipment_categories(name,slug,description,status,sort_order) values
('Access & Lifting Equipment','access-lifting','Aerial access, lifting and elevated work equipment.','active',1),
('Material Handling Equipment','material-handling','Equipment for warehouse and project material handling.','active',2),
('Power & Support Equipment','power-support','Generators, compressors, tower lights and welding equipment.','coming_soon',3),
('Earth Moving & Mining Equipment','earth-moving-mining','Excavation, crushing, hauling and loading equipment.','coming_soon',4)
on conflict (slug) do nothing;

insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Boom Lift','boom-lift-60ft','60 FT (18.3 M)','Diesel','Construction, Industrial, Maintenance',4,true from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Boom Lift','boom-lift-80ft','80 FT (24.4 M)','Diesel','Construction, Industrial, Maintenance',2,true from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Boom Lift','boom-lift-100ft','100 FT (30.5 M)','Diesel','High Reach Applications',1,true from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Scissor Lift','scissor-lift-12m-electric','12 M (Electric)','Electric','Indoor, Warehouses, Maintenance',4,false from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Scissor Lift','scissor-lift-16m-electric','16 M (Electric)','Electric','Indoor, Warehouses, Maintenance',4,false from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Truck Mounted Boom Lift','truck-mounted-boom-lift-28m','28 M','Diesel','Street Light, Telecom, Maintenance',2,false from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Spider Lift','spider-lift-18m','18 M','Electric','Tight Access, Façade Work',1,false from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Telehandler','telehandler-17m-4-5t','17 M Lift / 4.5 Ton','Diesel','Material Handling, Construction',2,false from public.equipment_categories where slug='access-lifting'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Forklift','forklift-3-ton-diesel','3 Ton Diesel','Diesel','Warehouses, Material Handling',2,true from public.equipment_categories where slug='material-handling'
on conflict (slug) do nothing;
insert into public.equipment(category_id,name,slug,specification,equipment_type,application,listed_quantity,featured)
select id,'Forklift','forklift-5-ton-diesel','5 Ton Diesel','Diesel','Warehouses, Material Handling',2,true from public.equipment_categories where slug='material-handling'
on conflict (slug) do nothing;

insert into public.locations(name,slug,location_type,address,city,state,pincode,phone,email)
values ('Noida Office','noida-office','office','Unit 603–604, 6th Floor, Tower B, Bhutani Alphathum, Sector 90','Noida','Uttar Pradesh','201305','8953565889','sales@tridenttrinity.com')
on conflict (slug) do nothing;

-- Public catalogue reads; enquiries are insert-only from anon clients.
alter table public.equipment_categories enable row level security;
alter table public.equipment enable row level security;
alter table public.equipment_images enable row level security;
alter table public.equipment_specifications enable row level security;
alter table public.locations enable row level security;
alter table public.industries enable row level security;
alter table public.enquiries enable row level security;
alter table public.posts enable row level security;

drop policy if exists "public active categories" on public.equipment_categories;
create policy "public active categories" on public.equipment_categories for select using (status='active');
drop policy if exists "public active equipment" on public.equipment;
create policy "public active equipment" on public.equipment for select using (status='active');
drop policy if exists "public equipment images" on public.equipment_images;
create policy "public equipment images" on public.equipment_images for select using (true);
drop policy if exists "public equipment specs" on public.equipment_specifications;
create policy "public equipment specs" on public.equipment_specifications for select using (true);
drop policy if exists "public locations" on public.locations;
create policy "public locations" on public.locations for select using (status='active');
drop policy if exists "public industries" on public.industries;
create policy "public industries" on public.industries for select using (status='active');
drop policy if exists "public enquiry insert" on public.enquiries;
create policy "public enquiry insert" on public.enquiries for insert with check (true);
drop policy if exists "public published posts" on public.posts;
create policy "public published posts" on public.posts for select using (status='published');
