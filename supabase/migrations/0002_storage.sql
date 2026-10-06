create policy "listing image objects public read" on storage.objects for select using(bucket_id='listing-images');
create policy "listing image objects admin insert" on storage.objects for insert with check(bucket_id='listing-images' and public.is_admin());
create policy "listing image objects admin update" on storage.objects for update using(bucket_id='listing-images' and public.is_admin()) with check(bucket_id='listing-images' and public.is_admin());
create policy "listing image objects admin delete" on storage.objects for delete using(bucket_id='listing-images' and public.is_admin());
