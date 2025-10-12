-- Drop old resume_section if už nechceš používat (pozor na data!)
drop table if exists resume_section;

-- Projects
create table if not exists resume_project (
                                              id uuid primary key default gen_random_uuid(),
    company text not null,
    project_name text not null,
    start_at date not null,
    end_at date,
    description text,
    responsibilities text[],
    tech_stack text[],
    repo_url text,
    demo_url text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
    );

-- Hobbies (jediný záznam)
create table if not exists resume_hobbies (
    id uuid primary key default gen_random_uuid(),
    sports text[],
    others text[],
    created_at timestamptz default now(),
    updated_at timestamptz default now()
    );

-- Certificates
create table if not exists resume_certificate (
                                                  id uuid primary key default gen_random_uuid(),
    name text not null,
    issuer text,
    start_at date,
    end_at date,
    description text,
    certificate_id text,
    url text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
    );

-- Education
create table if not exists resume_education (
                                                id uuid primary key default gen_random_uuid(),
    institution text not null,
    field text,
    degree text,
    since date not null,
    expected_until date,
    thesis_title text,
    thesis_description text,
    status text check (status in ('studying','graduated')) not null default 'studying',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
    );

create table if not exists resume_language (
                                               id uuid primary key default gen_random_uuid(),
    name text not null,
    level text not null, -- A1, A2, B1, B2, C1, C2, Native, Professional, etc.
    created_at timestamptz default now(),
    updated_at timestamptz default now()
    );
