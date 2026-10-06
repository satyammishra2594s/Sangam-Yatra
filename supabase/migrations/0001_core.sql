create extension if not exists pgcrypto;

create type public.user_role as enum ('user','admin');
create type public.listing_category as enum ('stay','panda','food','transport','shop','guide','other');
create type public.listing_status as enum ('draft','published','hidden');
create type public.request_status as enum ('pending','contacted','confirmed','cancelled','completed');

create table public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 email text unique, full_name text, phone text, home_state text, home_city text,
 role public.user_role not null default 'user',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.lookups(
 id uuid primary key default gen_random_uuid(), kind text not null, key text not null,
 label text not null, label_hi text, sort_order int not null default 0,
 active boolean not null default true, unique(kind,key)
);

create table public.listings(
 id uuid primary key default gen_random_uuid(), category public.listing_category not null,
 title text not null, title_hi text, slug text not null unique,
 description text, description_hi text, locality text, full_address text,
 latitude double precision, longitude double precision, distance_to_vishnupad_km numeric(8,2),
 status public.listing_status not null default 'draft',
 is_verified boolean not null default false, is_founder_family boolean not null default false,
 featured boolean not null default false, sort_order int not null default 0,
 platform_fee_amount numeric(10,2) not null default 0,
 owner_user_id uuid references auth.users(id),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.listing_images(
 id uuid primary key default gen_random_uuid(), listing_id uuid not null references public.listings(id) on delete cascade,
 storage_path text not null, public_url text, alt_text text, sort_order int not null default 0,
 is_cover boolean not null default false, created_at timestamptz not null default now()
);

create table public.listing_contacts(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 phone text not null, whatsapp text, updated_at timestamptz not null default now()
);

create table public.stay_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 property_type text not null, check_in_time time, check_out_time time, house_rules text,
 amenities jsonb not null default '[]', elderly_friendly boolean not null default false
);
create table public.stay_rooms(
 id uuid primary key default gen_random_uuid(), listing_id uuid not null references public.listings(id) on delete cascade,
 room_type_name text not null, ac boolean not null default false, capacity int not null check(capacity>0),
 beds int not null default 1, normal_price_per_night numeric(10,2), mela_price_per_night numeric(10,2),
 availability_status text not null default 'ask', room_images jsonb not null default '[]'
);

create table public.panda_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 full_name text not null, short_bio text, years_experience int, languages jsonb not null default '[]',
 religion text, caste_community text, brahmin_sub_group text, gotra text, veda_shakha text,
 family_lineage text, regions_served jsonb not null default '[]', rituals jsonb not null default '[]',
 dakshina_min numeric(10,2), dakshina_max numeric(10,2),
 consent_obtained boolean not null default false, face_image_path text
);
create table public.panda_slots(
 id uuid primary key default gen_random_uuid(), listing_id uuid not null references public.listings(id) on delete cascade,
 slot_date date not null, slot text not null, status text not null default 'ask'
);

create table public.food_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 food_type text, price_per_thali numeric(10,2), timings text, capacity int,
 home_delivery boolean not null default false, bulk_orders boolean not null default false,
 brahmin_bhojan boolean not null default false
);
create table public.transport_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 vehicle_type text, capacity int, ac boolean not null default false, pricing_basis text, rate numeric(10,2),
 station_airport_pickup boolean not null default false, outstation boolean not null default false,
 driver_name text, languages jsonb not null default '[]'
);
create table public.shop_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 items jsonb not null default '[]', pind_daan_kit_price numeric(10,2), packages text,
 bulk_orders boolean not null default false, home_delivery boolean not null default false, opening_hours text
);
create table public.guide_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 languages jsonb not null default '[]', experience_years int,
 fee_half_day numeric(10,2), fee_day numeric(10,2), specialties jsonb not null default '[]',
 government_certified boolean not null default false
);
create table public.other_details(
 listing_id uuid primary key references public.listings(id) on delete cascade,
 sub_type text, extra_fields jsonb not null default '{}'
);

create table public.favourites(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 listing_id uuid not null references public.listings(id) on delete cascade,
 created_at timestamptz not null default now(), unique(user_id,listing_id)
);
create table public.booking_requests(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 listing_id uuid not null references public.listings(id) on delete cascade,
 room_id uuid references public.stay_rooms(id), slot_id uuid references public.panda_slots(id),
 start_date date, end_date date, guests int not null default 1, rooms int, message text,
 status public.request_status not null default 'pending',
 platform_fee_amount numeric(10,2) not null default 0, internal_notes text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.listing_reports(
 id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete set null,
 listing_id uuid not null references public.listings(id) on delete cascade,
 reason text not null, details text, status text not null default 'open',
 created_at timestamptz not null default now(), resolved_at timestamptz
);
create table public.contact_reveals(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 listing_id uuid not null references public.listings(id) on delete cascade,
 created_at timestamptz not null default now()
);
create table public.site_settings(
 id boolean primary key default true, mela_start_date date, mela_end_date date,
 site_contact_number text, announcement_banner text,
 require_login_to_browse boolean not null default false, updated_at timestamptz not null default now()
);
insert into public.site_settings default values on conflict do nothing;

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as
$$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as
$$ begin insert into public.profiles(id,email,full_name) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'name')); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.validate_listing_publish() returns trigger language plpgsql as
$$ begin
 if new.status='published' then
   if new.category='stay' and (select count(*) from public.listing_images where listing_id=new.id)<3 then
     raise exception 'Stays need at least 3 images before publishing';
   end if;
   if new.category='panda' and not exists(select 1 from public.panda_details where listing_id=new.id and consent_obtained=true and face_image_path is not null) then
     raise exception 'Pandas need consent and a face photo before publishing';
   end if;
 end if;
 return new;
end; $$;
create trigger listing_publish_guard before insert or update on public.listings for each row execute procedure public.validate_listing_publish();

do $$ declare r record; begin
 for r in select tablename from pg_tables where schemaname='public' loop
   execute format('alter table public.%I enable row level security',r.tablename);
 end loop;
end $$;

create policy listings_public_read on public.listings for select using(status='published' or public.is_admin());
create policy listings_admin_insert on public.listings for insert with check(public.is_admin());
create policy listings_admin_update on public.listings for update using(public.is_admin()) with check(public.is_admin());
create policy listings_admin_delete on public.listings for delete using(public.is_admin());

create policy images_public_read on public.listing_images for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy images_admin_write on public.listing_images for all using(public.is_admin()) with check(public.is_admin());
create policy contacts_admin_only on public.listing_contacts for all using(public.is_admin()) with check(public.is_admin());

create policy profiles_self on public.profiles for select using(id=auth.uid() or public.is_admin());
create policy profiles_update on public.profiles for update using(id=auth.uid() or public.is_admin()) with check(id=auth.uid() or public.is_admin());
create policy lookups_read on public.lookups for select using(active=true or public.is_admin());
create policy lookups_admin on public.lookups for all using(public.is_admin()) with check(public.is_admin());

create policy stay_public on public.stay_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy stay_admin on public.stay_details for all using(public.is_admin()) with check(public.is_admin());
create policy rooms_public on public.stay_rooms for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy rooms_admin on public.stay_rooms for all using(public.is_admin()) with check(public.is_admin());
create policy panda_public on public.panda_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy panda_admin on public.panda_details for all using(public.is_admin()) with check(public.is_admin());
create policy slots_public on public.panda_slots for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy slots_admin on public.panda_slots for all using(public.is_admin()) with check(public.is_admin());
create policy food_public on public.food_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy food_admin on public.food_details for all using(public.is_admin()) with check(public.is_admin());
create policy transport_public on public.transport_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy transport_admin on public.transport_details for all using(public.is_admin()) with check(public.is_admin());
create policy shop_public on public.shop_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy shop_admin on public.shop_details for all using(public.is_admin()) with check(public.is_admin());
create policy guide_public on public.guide_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy guide_admin on public.guide_details for all using(public.is_admin()) with check(public.is_admin());
create policy other_public on public.other_details for select using(exists(select 1 from public.listings l where l.id=listing_id and l.status='published') or public.is_admin());
create policy other_admin on public.other_details for all using(public.is_admin()) with check(public.is_admin());

create policy favourites_self on public.favourites for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy requests_self_read on public.booking_requests for select using(user_id=auth.uid() or public.is_admin());
create policy requests_self_insert on public.booking_requests for insert with check(user_id=auth.uid());
create policy requests_admin_update on public.booking_requests for update using(public.is_admin()) with check(public.is_admin());
create policy reports_insert on public.listing_reports for insert with check(user_id=auth.uid());
create policy reports_read on public.listing_reports for select using(user_id=auth.uid() or public.is_admin());
create policy reports_admin on public.listing_reports for update using(public.is_admin()) with check(public.is_admin());
create policy reveals_insert on public.contact_reveals for insert with check(user_id=auth.uid());
create policy reveals_read on public.contact_reveals for select using(user_id=auth.uid() or public.is_admin());
create policy settings_read on public.site_settings for select using(true);
create policy settings_admin on public.site_settings for all using(public.is_admin()) with check(public.is_admin());

insert into public.lookups(kind,key,label,label_hi,sort_order) values
('brahmin_sub_group','gayawal','Gayawal','गयावाल',1),('brahmin_sub_group','sakaldwipi','Sakaldwipi','साकलद्वीपी',2),
('brahmin_sub_group','kanyakubja','Kanyakubja (Kankubja)','कान्यकुब्ज',3),('brahmin_sub_group','saryuparin','Saryuparin','सरयूपारीण',4),
('brahmin_sub_group','gaud','Gaud','गौड़',5),('brahmin_sub_group','maithil','Maithil','मैथिल',6),
('brahmin_sub_group','sanadhya','Sanadhya','सनाढ्य',7),('brahmin_sub_group','utkal','Utkal','उत्कल',8),
('brahmin_sub_group','saraswat','Saraswat','सारस्वत',9),('brahmin_sub_group','bhumihar','Bhumihar Brahmin','भूमिहार ब्राह्मण',10),
('brahmin_sub_group','other','Other','अन्य',99) on conflict do nothing;

insert into public.lookups(kind,key,label,sort_order) values
('ritual','pind-1','Pind Daan 1-day',1),('ritual','pind-3','Pind Daan 3-day',2),('ritual','pind-5','Pind Daan 5-day',3),
('ritual','pind-7','Pind Daan 7-day',4),('ritual','pind-17','Pind Daan 17-day',5),('ritual','tarpan','Tarpan',6),
('ritual','shraddha','Shraddha',7),('ritual','akshayavat','Akshayavat Shraddha',8),('ritual','bhojan','Brahmin Bhojan',9),
('ritual','special-puja','Special Puja',10) on conflict do nothing;

insert into storage.buckets(id,name,public) values('listing-images','listing-images',true) on conflict do nothing;
