-- Phase 1 fix: migration 004 enabled RLS on 6 of 8 tables.
-- public.role and public.role_permission were left unprotected, meaning
-- the public anon key could read and write the permission matrix.

alter table public.role enable row level security;
alter table public.role_permission enable row level security;

-- Role definitions are reference data: any signed-in user may read them
-- (the UI needs the catalogue to render). Anonymous visitors may not.
drop policy if exists "Authenticated users can read role definitions" on public.role;
create policy "Authenticated users can read role definitions"
  on public.role
  for select
  to authenticated
  using (true);

drop policy if exists "Authenticated users can read role permissions" on public.role_permission;
create policy "Authenticated users can read role permissions"
  on public.role_permission
  for select
  to authenticated
  using (true);

-- No INSERT / UPDATE / DELETE policies on either table.
-- With RLS enabled, the absence of a policy denies the operation, so the
-- permission matrix can only be changed from the dashboard or a trusted
-- server-side context holding the service_role key.
