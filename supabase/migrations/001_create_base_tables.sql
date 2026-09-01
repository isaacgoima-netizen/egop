-- Phase 1: Base tables for entity hierarchy, users, and organizations

-- Organizations (GroupCo + OpCos)
create table if not exists public.organization (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text not null check (type in ('group', 'opco')),
  parent_id uuid references public.organization(id),
  country text,
  created_at timestamp with time zone default now()
);

-- User profiles (linked to auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  avatar_url text,
  updated_at timestamp with time zone default now()
);

-- User-Organization assignments (scope)
create table if not exists public.user_organization_assignment (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  organization_id uuid not null references public.organization(id) on delete cascade,
  assigned_at timestamp with time zone default now(),
  unique(user_id, organization_id)
);

-- Teams/clusters (SAS, BPO, core, project)
create table if not exists public.team (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('sas', 'bpo', 'core', 'project')),
  organization_id uuid not null references public.organization(id) on delete cascade,
  created_at timestamp with time zone default now()
);

-- Indexes
create index if not exists idx_organization_parent_id on public.organization(parent_id);
create index if not exists idx_user_organization_assignment_user_id on public.user_organization_assignment(user_id);
create index if not exists idx_user_organization_assignment_organization_id on public.user_organization_assignment(organization_id);
create index if not exists idx_team_organization_id on public.team(organization_id);
