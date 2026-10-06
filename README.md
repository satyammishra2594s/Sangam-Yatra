# Sangam Yatra

Gaya Pitru Paksha yatra, simple and fair.

Sangam Yatra is a Gaya-only directory for pilgrims comparing stays, pandas and local services. V1 keeps listing creation admin-only; visitors can browse by default and must log in to reveal contacts, save listings and send requests.

## 1. Prerequisites

- Node.js 20.19+ / current Node LTS
- npm
- Supabase project
- GitHub account
- Vercel account

## 2. Supabase setup

1. Create a Supabase project.
2. Open SQL Editor.
3. Run supabase/migrations/0001_core.sql, then supabase/migrations/0002_storage.sql.
4. For development only, run supabase/seed/seed.sql. All records are fake/demo records.
5. Delete demo data with: delete from public.listings where slug like 'demo-%';

## 3. Auth setup

In Supabase Authentication -> Providers, enable Email/password and Google OAuth. Add http://localhost:3000/auth/callback as a local redirect URL. Add the production /auth/callback URL after Vercel deployment.

## 4. Environment

Copy .env.example to .env.local and fill in NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY, SUPABASE_SERVICE_ROLE_KEY, NEXT_PUBLIC_SITE_URL and REQUIRE_LOGIN_TO_BROWSE=false. Never expose the service-role key to the browser or commit it.

## 5. Install and run

npm install
npm run dev

Open http://localhost:3000.

Validation: npm run typecheck, npm run lint, npm test, npm run build, npm run test:e2e.

## 6. Make your account admin

Sign up first, then run this in Supabase SQL Editor:

update public.profiles set role = 'admin' where email = 'YOUR_EMAIL@example.com';

The role is checked by the server/UI and database RLS policies.

## 7. Included foundation

- Next.js App Router + TypeScript strict configuration.
- Tailwind theme tokens and mobile-first UI.
- Supabase SSR auth utilities for email/password and Google OAuth.
- Listings plus category detail tables, rooms, panda slots, contacts, images, favourites, requests, reports, settings and lookup tables.
- RLS on every public table and admin-only write policies.
- Protected contact reveal with a 30/day/user limit; contact data is excluded from public listing queries.
- Public home, category browse, listing detail, account and protected admin dashboard.
- Hindi/English message files, Vitest and Playwright configuration, sitemap and robots routes.

## 8. Product notices

Always show: Prices are declared by owners and can change. Dakshina is customary and is decided with the panda; Sangam Yatra does not set or collect it. Sangam Yatra is a directory and is not a party to any booking.

Pandas cannot be published without consent and a face-photo path. Stays cannot be published without at least 3 images; these rules are guarded in the database.

## 9. Vercel deployment

1. Import the GitHub repository into Vercel.
2. Add the same environment variables.
3. Set NEXT_PUBLIC_SITE_URL to the production URL.
4. Deploy.
5. Add the production auth callback URL to Supabase and Google OAuth.
6. Run migrations in the production Supabase project before adding real data.

## 10. Remaining launch checklist

Finish and verify the dedicated admin editor screens, image upload/reorder UI, full filters, Leaflet map view, mela-aware room pricing, profile editing/data deletion, dynamic JSON-LD/sitemap entries, bot protection and real Supabase RLS policy tests before a public launch.

## 11. Next

Full CRUD for every category, complete filters and map view, date-aware pricing, panda slots, richer request fields, profile deletion, CSV import, then future owner logins, payments, reviews and more tirthas.

See ASSUMPTIONS.md for decisions made without asking questions.
