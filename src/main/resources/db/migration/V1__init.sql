create extension if not exists "uuid-ossp";

create table if not exists post(
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  excerpt text not null,
  content_mdx text not null,
  cover_url text,
  tags text[] not null default '{}',
  status text not null default 'draft' check (status in ('draft','published')),
  published_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists idx_post_status_published_at on post(status, published_at desc);

create table if not exists project(
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  summary text not null,
  content_mdx text not null,
  links jsonb not null default '{}',
  "order" int not null default 0
);
create index if not exists idx_project_order on project("order");

create table if not exists testimonial(
  id uuid primary key default uuid_generate_v4(),
  author text not null,
  role text not null,
  avatar_url text,
  quote text not null,
  "order" int not null default 0
);
create index if not exists idx_testimonial_order on testimonial("order");

create table if not exists resume_section(
  id uuid primary key default uuid_generate_v4(),
  kind text not null,
  content_json jsonb not null default '{}',
  "order" int not null default 0
);

create table if not exists contact_message(
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  email text not null,
  message text not null,
  created_at timestamptz not null default now(),
  handled boolean not null default false
);

create table if not exists site_meta(
  id smallint primary key,
  email text,
  location text,
  socials jsonb not null default '{}',
  hero jsonb not null default '{}'
);

insert into site_meta(id, email, location, socials, hero)
values(1, 'me@jirihermann.com', 'Prague, CZ', '{}', '{}')
on conflict (id) do nothing;



