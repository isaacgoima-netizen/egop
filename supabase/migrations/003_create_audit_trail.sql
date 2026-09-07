-- Phase 1: Audit trail for compliance and monitoring

do $$ begin
  create type public.audit_action as enum (
    'create',
    'read',
    'update',
    'delete',
    'approve',
    'reject',
    'submit',
    'login',
    'logout',
    'export',
    'archive'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.audit_entity_type as enum (
    'organization',
    'user',
    'project',
    'client',
    'contract',
    'invoice',
    'payroll',
    'leave_request',
    'role_assignment',
    'other'
  );
exception when duplicate_object then null;
end $$;

-- Audit log table
create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  timestamp timestamp with time zone not null default now(),
  actor_id uuid references public.profiles(id),
  action public.audit_action not null,
  entity_type public.audit_entity_type not null,
  entity_id uuid,
  entity_name text,
  organization_id uuid references public.organization(id),
  before_values jsonb,
  after_values jsonb,
  changed_fields text[],
  ip_address inet,
  user_agent text,
  reason text,
  status text check (status in ('success', 'failed', 'pending')),
  created_at timestamp with time zone default now()
);

-- Indexes for common queries
create index if not exists idx_audit_log_timestamp on public.audit_log(timestamp desc);
create index if not exists idx_audit_log_actor_id on public.audit_log(actor_id);
create index if not exists idx_audit_log_organization_id on public.audit_log(organization_id);
create index if not exists idx_audit_log_entity_id on public.audit_log(entity_id);
create index if not exists idx_audit_log_action on public.audit_log(action);
