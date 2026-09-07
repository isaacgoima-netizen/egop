-- Phase 1: Row-level security policies for access control

-- Enable RLS on key tables
alter table public.profiles enable row level security;
alter table public.organization enable row level security;
alter table public.user_organization_assignment enable row level security;
alter table public.user_role enable row level security;
alter table public.team enable row level security;
alter table public.audit_log enable row level security;

-- Users can read their own profile
drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

-- Users can view organizations they belong to
drop policy if exists "Users can view assigned organizations" on public.organization;
create policy "Users can view assigned organizations"
  on public.organization
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment uoa
      where uoa.user_id = auth.uid()
      and uoa.organization_id = organization.id
    )
  );

-- Users can see their own org assignments
drop policy if exists "Users see their org assignments" on public.user_organization_assignment;
create policy "Users see their org assignments"
  on public.user_organization_assignment
  for select
  using (user_id = auth.uid());

-- Users can see roles they have
drop policy if exists "Users see their roles" on public.user_role;
create policy "Users see their roles"
  on public.user_role
  for select
  using (user_id = auth.uid());

-- Teams visible to users in that organization
drop policy if exists "Teams visible to org members" on public.team;
create policy "Teams visible to org members"
  on public.team
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment uoa
      where uoa.user_id = auth.uid()
      and uoa.organization_id = team.organization_id
    )
  );

-- Audit logs readable by org members
drop policy if exists "Users can read audit logs for their orgs" on public.audit_log;
create policy "Users can read audit logs for their orgs"
  on public.audit_log
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment uoa
      where uoa.user_id = auth.uid()
      and uoa.organization_id = audit_log.organization_id
    )
  );

-- Audit logs are insert-only (immutable by omission of update/delete policies)
drop policy if exists "Authenticated users can insert audit logs" on public.audit_log;
create policy "Authenticated users can insert audit logs"
  on public.audit_log
  for insert
  to authenticated
  with check (true);

-- Note: no UPDATE or DELETE policies exist on audit_log.
-- With RLS enabled, absence of a policy means the operation is denied.
-- This is what makes the audit trail immutable.
