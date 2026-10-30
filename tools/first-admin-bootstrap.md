# First Admin Bootstrap (Test Project First)

This procedure is intentionally manual. There is no public "make me Admin" endpoint, no service-role key in the browser, and no automatic first-user promotion.

## 1. Create the first login

1. In the **Trident ERP TEST** Supabase project, open Authentication → Users.
2. Invite the intended owner/admin work email (or create the user through the approved authentication flow).
3. Complete the email/password setup.
4. Copy that user's UUID from Authentication → Users.

Do not use the production project for this test.

## 2. Assign the first Admin role

Open SQL Editor in the **test project** and run this query after replacing both placeholders with the confirmed user UUID and display name:

```sql
insert into public.erp_staff_profiles (user_id, display_name, role, is_active)
select id, 'REPLACE WITH ADMIN DISPLAY NAME', 'admin', true
from auth.users
where id = 'REPLACE-WITH-CONFIRMED-AUTH-USER-UUID'::uuid
on conflict (user_id) do update
set display_name = excluded.display_name,
    role = 'admin',
    is_active = true,
    updated_at = now();
```

The statement inserts only if the UUID exists in `auth.users`. If it affects zero rows, stop and verify the UUID. Do not guess an ID.

Verify:

```sql
select p.user_id, u.email, p.display_name, p.role, p.is_active
from public.erp_staff_profiles p
join auth.users u on u.id = p.user_id
where p.role = 'admin' and p.is_active = true;
```

## 3. Provision other staff

Until an Admin/staff-management screen is implemented, the project owner must invite each staff member in Authentication → Users, then insert a matching `erp_staff_profiles` row from SQL Editor. Use one of these exact lowercase role values:

- `manager`
- `accounts`
- `operations`
- `viewer`

Never allow a user to choose or change their own role. Deactivate access by setting `is_active = false`; do not delete the auth account as a routine offboarding step.

Example for a newly invited employee:

```sql
insert into public.erp_staff_profiles (user_id, display_name, role, is_active)
select id, 'EMPLOYEE DISPLAY NAME', 'operations', true
from auth.users
where id = 'CONFIRMED-EMPLOYEE-UUID'::uuid;
```

## 4. Test role access

Use separate test accounts, one per role. Confirm:
- Admin: full ERP access and Dump / Deleted records.
- Manager: operational and financial create/update access.
- Operations: customer/vendor/machine/project operations and shared documents/follow-ups/PO revisions; no financial writes.
- Accounts: invoices, vendor bills, payments and shared documents/follow-ups/PO revisions; no operational master writes.
- Viewer: read-only access; no add/edit/archive/checklist/closure actions.

The UI hides or blocks role-ineligible actions for usability. **Supabase RLS is the security boundary**; a hidden button is not security by itself.

## Safety boundaries

- This bootstrap is for the dedicated test project only.
- Do not paste service-role/secret keys into code, browser tools, or GitHub.
- Do not promote the first admin by an unauthenticated function or public signup metadata.
- Do not run this against production until test sign-in and role authorization checks have passed and a separate production change is explicitly approved.
