-- Unity/Farmtrack ERP normalized core.
-- Run this in the Supabase SQL Editor for project qiwggxoaqeptdqzpwgft.
-- It matches api/rpc.js normalized sync and unlocks full table-by-table persistence.

create extension if not exists pgcrypto;

create table if not exists public.erp_state (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  country text default 'KE',
  base_currency text default 'KES',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  full_name text not null,
  email text not null,
  role text not null default 'viewer',
  phone text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, email)
);

create table if not exists public.warehouses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  code text not null,
  type text default 'main',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  unique (tenant_id, code)
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  customer_no text not null,
  name text not null,
  email text,
  phone text,
  city text,
  type text default 'Farm',
  tax_id text,
  credit_limit numeric(14,2) default 0,
  balance numeric(14,2) default 0,
  health_score numeric(5,2) default 100,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, customer_no)
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  supplier_no text not null,
  name text not null,
  email text,
  phone text,
  category text,
  payment_terms text default 'Net 30',
  on_time_rate numeric(5,2) default 0,
  delivery_rate numeric(5,2) default 0,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, supplier_no)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  sku text not null,
  name text not null,
  category text,
  type text not null default 'finished_good',
  unit text not null default 'unit',
  cost_price numeric(14,2) default 0,
  selling_price numeric(14,2) default 0,
  tax_rate numeric(5,2) default 16,
  min_stock numeric(14,3) default 0,
  reorder_qty numeric(14,3) default 0,
  valuation_method text default 'FIFO',
  is_manufactured boolean default false,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, sku)
);

create table if not exists public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  product_id uuid references public.products(id),
  warehouse_id uuid references public.warehouses(id),
  sku text,
  product_name text not null,
  category text,
  batch_no text,
  quantity_available numeric(14,3) not null default 0,
  quantity_reserved numeric(14,3) not null default 0,
  quantity_incoming numeric(14,3) not null default 0,
  quantity_outgoing numeric(14,3) not null default 0,
  reorder_level numeric(14,3) not null default 0,
  reorder_point numeric(14,3) not null default 0,
  unit_cost numeric(14,2) not null default 0,
  selling_price numeric(14,2) not null default 0,
  valuation_method text not null default 'FIFO',
  expiry_date date,
  last_movement_at timestamptz,
  status text not null default 'in_stock',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.inventory_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  inventory_item_id uuid references public.inventory_items(id) on delete cascade,
  product_id uuid references public.products(id),
  warehouse_id uuid references public.warehouses(id),
  transaction_type text not null,
  quantity numeric(14,3) not null default 0,
  unit_cost numeric(14,2) not null default 0,
  reference_type text,
  reference_id uuid,
  notes text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.sales_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  order_no text not null,
  customer_id uuid not null references public.customers(id),
  status text not null default 'draft',
  subtotal numeric(14,2) default 0,
  tax numeric(14,2) default 0,
  total numeric(14,2) default 0,
  paid numeric(14,2) default 0,
  balance numeric(14,2) default 0,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, order_no)
);

create table if not exists public.sales_order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  sales_order_id uuid not null references public.sales_orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity numeric(14,3) not null,
  reserved_quantity numeric(14,3) default 0,
  unit_price numeric(14,2) not null,
  unit_cost numeric(14,2) default 0,
  total numeric(14,2) generated always as (quantity * unit_price) stored
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  invoice_no text not null,
  customer_id uuid not null references public.customers(id),
  sales_order_id uuid references public.sales_orders(id),
  status text not null default 'unpaid',
  subtotal numeric(14,2) default 0,
  tax numeric(14,2) default 0,
  total numeric(14,2) default 0,
  paid numeric(14,2) default 0,
  balance numeric(14,2) default 0,
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, invoice_no)
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  payment_no text not null,
  customer_id uuid references public.customers(id),
  invoice_id uuid references public.invoices(id),
  amount numeric(14,2) not null,
  method text default 'cash',
  status text default 'completed',
  created_at timestamptz not null default now(),
  unique (tenant_id, payment_no)
);

create table if not exists public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  po_no text not null,
  supplier_id uuid references public.suppliers(id),
  status text not null default 'draft',
  subtotal numeric(14,2) default 0,
  tax numeric(14,2) default 0,
  total numeric(14,2) default 0,
  expected_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, po_no)
);

create table if not exists public.production_jobs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  job_no text not null,
  product_id uuid not null references public.products(id),
  planned_qty numeric(14,3) not null,
  completed_qty numeric(14,3) default 0,
  wastage_qty numeric(14,3) default 0,
  status text default 'pending',
  material_cost numeric(14,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, job_no)
);

create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  journal_no text not null,
  journal_date date not null default current_date,
  description text not null,
  source_module text,
  reference text,
  total_debit numeric(14,2) not null default 0,
  total_credit numeric(14,2) not null default 0,
  approval_status text not null default 'posted',
  posted_by uuid references public.profiles(id),
  immutable boolean not null default true,
  created_at timestamptz not null default now(),
  unique (tenant_id, journal_no),
  check (total_debit = total_credit)
);

create table if not exists public.business_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  event_type text not null,
  entity_type text not null,
  entity_id uuid,
  actor_id uuid references public.profiles(id),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_customers_tenant_status on public.customers (tenant_id, status);
create index if not exists idx_products_tenant_status on public.products (tenant_id, status);
create index if not exists idx_inventory_items_tenant_product on public.inventory_items (tenant_id, product_id);
create index if not exists idx_sales_orders_tenant_created on public.sales_orders (tenant_id, created_at desc);
create index if not exists idx_invoices_tenant_status on public.invoices (tenant_id, status);
create index if not exists idx_journal_entries_tenant_date on public.journal_entries (tenant_id, journal_date desc);

create or replace view public.analytics_revenue_summary as
select tenant_id,
       date_trunc('month', created_at)::date as period,
       coalesce(sum(total), 0) as net_revenue,
       coalesce(sum(tax), 0) as tax,
       coalesce(sum(balance), 0) as receivables,
       count(*) as order_count
from public.sales_orders
group by tenant_id, date_trunc('month', created_at)::date;

create or replace view public.analytics_inventory_health as
select tenant_id,
       product_id,
       product_name,
       coalesce(sum(quantity_available), 0) as available_qty,
       coalesce(sum(quantity_available * unit_cost), 0) as inventory_value,
       min(status) as status
from public.inventory_items
group by tenant_id, product_id, product_name;

create or replace view public.analytics_customer_value as
select c.tenant_id,
       c.id as customer_id,
       c.name,
       coalesce(sum(so.total), 0) as lifetime_value,
       coalesce(sum(so.balance), 0) as open_balance,
       count(so.id) as orders
from public.customers c
left join public.sales_orders so on so.tenant_id = c.tenant_id and so.customer_id = c.id
group by c.tenant_id, c.id, c.name;

create or replace view public.analytics_procurement_metrics as
select tenant_id,
       supplier_id,
       count(*) as purchase_orders,
       coalesce(sum(total), 0) as spend,
       min(status) as status
from public.purchase_orders
group by tenant_id, supplier_id;

create or replace view public.analytics_production_metrics as
select tenant_id,
       product_id,
       count(*) as jobs,
       coalesce(sum(planned_qty), 0) as planned_qty,
       coalesce(sum(completed_qty), 0) as completed_qty,
       coalesce(sum(wastage_qty), 0) as wastage_qty,
       coalesce(sum(material_cost), 0) as material_cost,
       min(status) as status
from public.production_jobs
group by tenant_id, product_id;

create or replace view public.analytics_risk_center as
select tenant_id, 'receivables' as risk_type, count(*) as risk_count, coalesce(sum(balance), 0) as exposure
from public.invoices
where balance > 0
group by tenant_id
union all
select tenant_id, 'low_inventory' as risk_type, count(*) as risk_count, coalesce(sum(reorder_point - quantity_available), 0) as exposure
from public.inventory_items
where quantity_available <= reorder_point
group by tenant_id;

create or replace view public.analytics_executive_summary as
select t.id as tenant_id,
       coalesce((select sum(total) from public.sales_orders so where so.tenant_id = t.id), 0) as revenue,
       coalesce((select sum(balance) from public.invoices i where i.tenant_id = t.id), 0) as receivables,
       coalesce((select sum(quantity_available * unit_cost) from public.inventory_items ii where ii.tenant_id = t.id), 0) as inventory_value,
       coalesce((select count(*) from public.customers c where c.tenant_id = t.id), 0) as customers,
       coalesce((select count(*) from public.sales_orders so where so.tenant_id = t.id), 0) as orders
from public.tenants t;
