-- Phase 1: Role-based access control system

-- Define the 11 roles
create type if not exists public.role_type as enum (
  'group_executive',
  'group_function_head',
  'gm',
  'entity_function_lead',
  'project_manager',
  'front_end_lead',
  'back_end_lead',
  'employee',
  'client_user',
  'sub_admin',
  'system_admin'
);

-- Role definitions
create table if not exists public.role (
  id uuid primary key default gen_random_uuid(),
  name public.role_type not null unique,
  description text,
  scope text not null check (scope in ('group', 'entity', 'project', 'user')),
  created_at timestamp with time zone default now()
);

-- User-Role assignments (per organization)
create table if not exists public.user_role (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  role_id uuid not null references public.role(id) on delete cascade,
  organization_id uuid not null references public.organization(id) on delete cascade,
  assigned_at timestamp with time zone default now(),
  assigned_by uuid references public.profiles(id),
  unique(user_id, role_id, organization_id)
);

-- Module permissions
create type if not exists public.module_type as enum (
  'crm',
  'projects',
  'finance',
  'hr',
  'recruitment',
  'analytics',
  'support',
  'documents',
  'calendar',
  'invoicing',
  'workflow',
  'forms',
  'tools'
);

-- Permission levels
create type if not exists public.permission_level as enum (
  'none',
  'view',
  'create',
  'edit',
  'approve',
  'admin',
  'full'
);

-- Role-Module permissions
create table if not exists public.role_permission (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references public.role(id) on delete cascade,
  module public.module_type not null,
  permission public.permission_level not null default 'none',
  created_at timestamp with time zone default now(),
  unique(role_id, module)
);

-- Insert the 11 roles
insert into public.role (name, description, scope) values
  ('group_executive', 'GroupCo CEO - full platform access', 'group'),
  ('group_function_head', 'GroupCo function leads (Commercial, Finance, HR, Tech)', 'group'),
  ('gm', 'OpCo General Manager - entity-level oversight', 'entity'),
  ('entity_function_lead', 'OpCo function lead (typically Finance/SSO)', 'entity'),
  ('project_manager', 'Project Manager - project-level delivery leadership', 'project'),
  ('front_end_lead', 'Relationship Manager - client relationships', 'entity'),
  ('back_end_lead', 'Lead Consultant - delivery/project oversight', 'entity'),
  ('employee', 'Core employee - assigned projects and tasks', 'project'),
  ('client_user', 'External client user (BPO HR services)', 'user'),
  ('sub_admin', 'Sub-administrator - limited admin functions', 'group'),
  ('system_admin', 'System Administrator - full technical access', 'group')
on conflict do nothing;

-- Indexes
create index if not exists idx_user_role_user_id on public.user_role(user_id);
create index if not exists idx_user_role_organization_id on public.user_role(organization_id);
create index if not exists idx_user_role_role_id on public.user_role(role_id);
create index if not exists idx_role_permission_role_id on public.role_permission(role_id);
