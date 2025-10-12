-- Align date-only columns to timestamptz so Kotlin Instant mapping works

-- Projects
alter table if exists resume_project
  alter column start_at type timestamptz using (start_at::timestamp at time zone 'UTC');

alter table if exists resume_project
  alter column end_at type timestamptz using (end_at::timestamp at time zone 'UTC');

-- Certificates
alter table if exists resume_certificate
  alter column start_at type timestamptz using (start_at::timestamp at time zone 'UTC');

alter table if exists resume_certificate
  alter column end_at type timestamptz using (end_at::timestamp at time zone 'UTC');

-- Education
alter table if exists resume_education
  alter column since type timestamptz using (since::timestamp at time zone 'UTC');

alter table if exists resume_education
  alter column expected_until type timestamptz using (expected_until::timestamp at time zone 'UTC');


