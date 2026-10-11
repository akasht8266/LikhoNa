-- Run in Supabase SQL Editor. Review policies before public launch.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-zA-Z0-9_]{3,20}$'),
  display_name text not null default 'लेखक' check (char_length(display_name) between 1 and 60),
  bio text not null default '' check (char_length(bio) <= 300),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text check (title is null or char_length(title) <= 120),
  body text not null check (char_length(body) between 1 and 5000),
  category text not null default 'शायरी' check (category in ('शायरी','कविता','विचार','प्रेरणा','भक्ति','कहानी','अन्य')),
  visibility text not null default 'public' check (visibility in ('public','private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists posts_public_created_idx on public.posts (created_at desc) where visibility='public';
create index if not exists posts_author_created_idx on public.posts (author_id, created_at desc);
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
drop policy if exists "profiles are viewable by everyone" on public.profiles;
create policy "profiles are viewable by everyone" on public.profiles for select using (true);
drop policy if exists "user creates own profile" on public.profiles;
create policy "user creates own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "user updates own profile" on public.profiles;
create policy "user updates own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists "public posts readable and owners can read private" on public.posts;
create policy "public posts readable and owners can read private" on public.posts for select using (visibility='public' or auth.uid()=author_id);
drop policy if exists "authenticated user creates own posts" on public.posts;
create policy "authenticated user creates own posts" on public.posts for insert to authenticated with check (auth.uid() = author_id);
drop policy if exists "author updates own posts" on public.posts;
create policy "author updates own posts" on public.posts for update to authenticated using (auth.uid()=author_id) with check (auth.uid()=author_id);
drop policy if exists "author deletes own posts" on public.posts;
create policy "author deletes own posts" on public.posts for delete to authenticated using (auth.uid()=author_id);
-- Create profile after signup; username can be edited in app after account creation.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
declare base_name text;
begin
  base_name := lower(regexp_replace(coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1), 'writer'), '[^a-zA-Z0-9_]', '', 'g'));
  if length(base_name) < 3 then base_name := 'writer'; end if;
  base_name := left(base_name, 14) || '_' || left(replace(new.id::text,'-',''),5);
  insert into public.profiles (id, username, display_name)
  values (new.id, base_name, left(coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1), 'लेखक'),60))
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
