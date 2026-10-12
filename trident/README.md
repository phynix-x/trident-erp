# Trident Equipment Rental Platform

Educational prototype for **Trident Trinity Assets Private Limited**.

## Current catalogue
- Access & Lifting Equipment — active
- Material Handling Equipment — active
- Power & Support Equipment — coming soon
- Earth Moving & Mining Equipment — coming soon

## Frontend
`index.html`, `styles.css`, and `app.js` provide the first interactive frontend: responsive navigation, equipment search/filtering, equipment detail modal, quote enquiry modal, coming-soon sections and contact/location content.

## Backend
`supabase/schema.sql` contains the PostgreSQL schema, seed catalogue, location seed and initial public RLS policies. Apply it to the Trident Supabase project once the Supabase connector is connected.

## Admin
`admin/index.html` is the initial admin dashboard shell. The next implementation stage should replace the static dashboard with Supabase Auth + database CRUD.

## Brand
Use the user-provided Trident logo asset in production. The current prototype uses a text/CSS brand mark until the binary logo asset is added to the repository.
