# Assumptions and v1 decisions

1. The Sangam-Yatra repository was empty, so this is a greenfield build.
2. Next.js 16.3.8 is the patched Active LTS baseline at implementation time.
3. Supabase Auth uses email/password and Google OAuth with cookie-based SSR through @supabase/ssr.
4. Hindi is the default locale; English message files are included. The first implementation keeps the locale switch intentionally lightweight.
5. REQUIRE_LOGIN_TO_BROWSE defaults to false, matching the product requirement.
6. The first admin is created by an explicit SQL update after signup; role is never client-controlled.
7. Contact numbers are stored separately and exposed only by an authenticated server route. The default reveal limit is 30 per user per day.
8. The service-role key is server-only.
9. Leaflet/OpenStreetMap is the map stack; no paid map API is introduced.
10. Demo seed records are fake and must not be treated as real providers or contacts.
11. Production images should be uploaded to listing-images and validated as JPG/PNG/WebP, max 1600px and 5MB.
12. Mela dates are stored in site_settings and are not hardcoded in application code.
13. Requests are not reservations; Sangam Yatra does not collect payment or dakshina in v1.
14. If WhatsApp is blank, the reveal route falls back to the phone number.
15. Reviews/ratings are intentionally excluded from v1.
16. Terms and Privacy are generic templates and need lawyer review before production use.
17. Accessibility baseline is mobile-first with 44px controls, high contrast and simple wording. Larger-text control is a polish item.
18. Sitemap/robots routes are present; fully dynamic JSON-LD and dynamic sitemap entries are a later hardening item.
19. The repository started empty, so the first pushed foundation prioritizes the secure schema, auth, public discovery, contact protection and requests. Dedicated admin category editors are tracked as the next milestone.
20. owner_user_id exists for future owner accounts; owners do not log in in v1.
