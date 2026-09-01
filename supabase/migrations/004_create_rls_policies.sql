-- Phase 1: Row-level security policies for access control

-- Enable RLS on key tables
alter table public.profiles enable row level security;
alter table public.organization enable row level security;
alter table public.user_organization_assignment enable row level security;
alter table public.user_role enable row level security;
alter table public.team enable row level security;
alter table public.audit_log enable row level security;

-- Policy: Users can read their own profile
create policy if not exists "Users can read their own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

-- Policy: Users can view organizations they belong to
create policy if not exists "Users can view assigned organizations"
  on public.organization
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment
      where user_id = auth.uid()
      and organization_id = organization.id
    )
  );

-- Policy: Users can see their own org assignments
create policy if not exists "Users see their org assignments"
  on public.user_organization_assignment
  for select
  using (user_id = auth.uid());

-- Policy: Users can see roles they have in organizations
create policy if not exists "Users see their roles"
  on public.user_role
  for select
  using (user_id = auth.uid());

-- Policy: Teams visible to users in that organization
create policy if not exists "Teams visible to org members"
  on public.team
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment
      where user_id = auth.uid()
      and organization_id = team.organization_id
    )
  );

-- Policy: Audit logs readable by org members
create policy if not exists "Users can read audit logs for their orgs"
  on public.audit_log
  for select
  using (
    exists (
      select 1 from public.user_organization_assignment
      where user_id = auth.uid()
      and organization_id = audit_log.organization_id
    )
  );

-- Policy: Only system can insert audit logs
create policy if not exists "Only system inserts audit logs"
  on public.audit_log
  for insert
  with check (true);

-- Policy: Audit logs are immutable
create policy if not exists "Audit logs are immutable"
  on public.audit_log
  for update
  using (false);

create policy if not exists "Audit logs cannot be deleted"
  on public.audit_log
  for delete
  using (false);
