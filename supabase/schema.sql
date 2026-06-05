-- Echo database schema
-- Paste ONLY this SQL into Supabase → SQL Editor → New query → Run
-- (Do not paste the file path "supabase/schema.sql" into the editor.)

-- Tables
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  username_lower text not null unique,
  created_at timestamptz default now()
);

create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_lower text not null unique,
  created_by uuid references auth.users(id) not null,
  author_username text not null,
  created_at timestamptz default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references public.topics(id) on delete cascade not null,
  subject text not null,
  author_id uuid references auth.users(id) not null,
  author_username text not null,
  audio_path text not null,
  duration_seconds int default 0,
  reply_count int default 0,
  created_at timestamptz default now()
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade not null,
  parent_comment_id uuid references public.comments(id) on delete cascade,
  author_id uuid references auth.users(id) not null,
  author_username text not null,
  type text not null check (type in ('text', 'voice')),
  text text,
  audio_path text,
  duration_seconds int,
  created_at timestamptz default now()
);

create index if not exists posts_topic_created on public.posts (topic_id, created_at desc);
create index if not exists comments_post_created on public.comments (post_id, created_at asc);

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.topics enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;

-- Policies (safe to re-run)
drop policy if exists "profiles read" on public.profiles;
drop policy if exists "profiles insert own" on public.profiles;
drop policy if exists "topics read" on public.topics;
drop policy if exists "topics insert" on public.topics;
drop policy if exists "posts read" on public.posts;
drop policy if exists "posts insert" on public.posts;
drop policy if exists "comments read" on public.comments;
drop policy if exists "comments insert" on public.comments;

create policy "profiles read" on public.profiles
  for select to authenticated using (true);

create policy "profiles insert own" on public.profiles
  for insert to authenticated with check (auth.uid() = id);

create policy "topics read" on public.topics
  for select to authenticated using (true);

create policy "topics insert" on public.topics
  for insert to authenticated with check (auth.uid() = created_by);

create policy "posts read" on public.posts
  for select to authenticated using (true);

create policy "posts insert" on public.posts
  for insert to authenticated with check (auth.uid() = author_id);

create policy "comments read" on public.comments
  for select to authenticated using (true);

create policy "comments insert" on public.comments
  for insert to authenticated with check (auth.uid() = author_id);
