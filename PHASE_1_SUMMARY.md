# Phase 1 Foundation - Setup Summary

## Created Files

### Configuration
- `package.json` — Dependencies (React, TypeScript, Vite, Supabase)
- `vite.config.ts` — Vite build configuration  
- `tsconfig.json` — TypeScript compiler options
- `.gitignore` — Ignore node_modules, .env.local, dist
- `.env.local.example` — Template for environment variables

### Frontend (React/Vite)
- `index.html` — Entry HTML
- `src/main.tsx` — React entry point
- `src/App.tsx` — Root component (placeholder)
- `src/App.css` — Component styles
- `src/index.css` — Global styles
- `src/lib/supabase.ts` — Supabase client initialization

### Database Schema (Supabase Migrations)
- `supabase/migrations/001_create_base_tables.sql` — Organization hierarchy, profiles, teams
- `supabase/migrations/002_create_role_system.sql` — 11-role definitions, role assignments, permissions
- `supabase/migrations/003_create_audit_trail.sql` — Audit log table (immutable)
- `supabase/migrations/004_create_rls_policies.sql` — Row-level security enforcement

### Documentation
- `README.md` — Project overview and setup instructions
- `CLAUDE.md` — Project guidelines and architecture decisions

## Quick Start (Next Steps)

1. **Copy files to your local machine**
2. **Create .env.local:**
```
VITE_SUPABASE_URL=https://fbbacfvwhsbuxvmrflxg.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZiYmFjZnZ3aHNidXh2bXJmbHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyNDk3NzksImV4cCI6MjEwMzgyNTc3OX0.aITZxeS_smZ4eAXOD1QmSubq5TCnPIn7xoN42pHPlPQ
VITE_ENTRA_CLIENT_ID=YOUR_ENTRA_CLIENT_ID_HERE
VITE_ENTRA_TENANT_ID=YOUR_ENTRA_TENANT_ID_HERE
```

3. **Run Supabase migrations** (in Supabase dashboard → SQL Editor):
   - Copy each SQL file from `supabase/migrations/` and run in order

4. **Install and run:**
```bash
npm install
npm run dev
```

5. **Visit:** http://localhost:5173

## Architecture Overview

### Entity Hierarchy
- **GroupCo** (parent) — Commercial, Finance, HR centralized here
- **5 OpCos** — Delivery, local Finance capture (SSO), Project delivery

### 11-Role Model
| Level | Role | Access |
|---|---|---|
| **GroupCo** | Group Executive | All |
| | Group Function Head | Function-specific (Comm, Finance, HR, Tech) |
| | System Admin | Full technical |
| **OpCo** | GM | Entity-level oversight |
| | Front-end Lead (RM) | Clients, proposals |
| | Back-end Lead (LC) | Projects, delivery |
| | Entity Function Lead (SSO) | Finance only |
| **Project** | Project Manager | Assigned projects |
| **Employee** | Employee | Assigned projects + tasks |

### Module Access

| Module | GroupCo | OpCo | Notes |
|--------|---------|------|-------|
| **CRM** | Yes (only) | No | GroupCo-only commercial |
| **Projects** | Read-only | Yes (deliver) | OpCos execute |
| **Finance** | Approve, consolidate | Capture, code | SSO submits, GroupCo approves |
| **HR** | Centralized | GM summary only | GroupCo-only with GM read-only |
| **Recruitment** | Ad-hoc (direct) | Two-tier | Ad-hoc or 5+ role projects |

### Database Schema

**Core:**
- `organization` — GroupCo + OpCos
- `profiles` — Users (linked to auth)
- `user_organization_assignment` — Org membership
- `team` — Client/project groupings

**Access Control:**
- `role` — 11 role definitions
- `user_role` — User ↔ Role per org
- `role_permission` — Role ↔ Module permissions

**Audit:**
- `audit_log` — Immutable action log (create, update, approve, etc.)

## Security Enforced By

1. **Entra ID/SSO** — Microsoft 365 authentication (Phase 2)
2. **Row-Level Security** — Database enforces org/entity scoping
3. **Module Permissions** — App-layer permission matrix
4. **Audit Trail** — Immutable log for compliance

## What's Next (Phase 2)

- Complete Entra/SSO integration
- Build CRM module (GroupCo only)
- Build Projects module (OpCo delivery)
- Implement Shared Services Request Engine (quick actions)
- Add Finance capture module (OpCo SSO)

---

Phase 1 is the foundation. Everything else builds on it.
