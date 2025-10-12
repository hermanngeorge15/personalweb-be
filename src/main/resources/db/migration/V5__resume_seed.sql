-- Seed data for resume tables (projects, hobbies, certificates, education, languages)
-- Assumes V4 migrated date columns to timestamptz

-- Projects
-- Avast — June 2022 – Present
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'GEN',
    'Software Development Engineer',
    '2022-06-01T00:00:00Z',
    null,
    'Design and Kotlin backend development for account domain.',
    null,
    '{"Spring Boot","Kotlin","Coroutines","Grafana","ELK","Kibana","TeamCity","Cassandra"}',
    null,
    null
  );

-- PBK — December 2021 – March 2022
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'PBK',
    'Software Development Engineer',
    '2021-12-01T00:00:00Z',
    '2022-03-01T00:00:00Z',
    'Design and Kotlin backend development for a bank application.',
    null,
    '{"Micronaut","Hibernate","Gherkin","Kotlin","Coroutines","Kubernetes","Docker","Prometheus","Grafana","Loki","RabbitMQ","PostgreSQL","MongoDB"}',
    null,
    null
  );

-- Česká spořitelna — November 2020 – November 2021
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'Česká spořitelna',
    'Software Development Engineer',
    '2020-11-01T00:00:00Z',
    '2021-11-01T00:00:00Z',
    'Design and backend development (Java/Kotlin) for PSD2 API.',
    null,
    '{"Spring Boot","Hibernate","Selenium","Gherkin","Jenkins","Kotlin","Java","OpenShift","RobotFramework","Kibana","Oracle","Redis","ElasticSearch"}',
    null,
    null
  );

-- Metadata driven development — October 2019 – October 2020
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'Metadata driven development',
    'Java Backend Developer',
    '2019-10-01T00:00:00Z',
    '2020-10-01T00:00:00Z',
    'Backend for web app to design DWH systems; metadata-driven development; DDL templates; REST API; Jenkins jobs; test framework.',
    null,
    '{"Spring Boot","Hibernate","Selenium","Gherkin","Jenkins","MapStruct","Project Lombok","Freemarker","PostgreSQL"}',
    null,
    null
  );

-- Nakoupeno.online — February 2020 – March 2020
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'Adastra s.r.o ',
    'Nakoupeno.online - Java Backend Developer',
    '2020-02-01T00:00:00Z',
    '2020-03-01T00:00:00Z',
    'Backend for web/mobile app for SMEs (onboarding merchant, user management); team leadership.',
    null,
    '{"Spring Boot","Hibernate","AWS","Jenkins","PostgreSQL","Firebase"}',
    null,
    null
  );

-- Adastra s.r.o — HCCN - MAPP — November 2018 – October 2019
insert into resume_project
  (company, project_name, start_at, end_at, description, responsibilities, tech_stack, repo_url, demo_url)
values
  (
    'Adastra s.r.o',
    'Java Backend Developer — HCCN - MAPP',
    '2018-11-01T00:00:00Z',
    '2019-10-01T00:00:00Z',
    'Backend for mobile apps: loan management, customer onboarding, user management, messaging, reporting; API specifications.',
    null,
    '{"Spring Boot","Batch","Hibernate","Kafka","RabbitMQ","JMS","Redis","Oracle"}',
    null,
    null
  );
-- Hobbies (single row)
insert into resume_hobbies (sports, others)
values (
  '{"Running","Climbing","Cycling"}',
  '{"Photography","Travel","Cooking"}'
);

-- University of Pardubice — Master’s (2014 – 2018)
insert into resume_education (
  institution, field, degree, since, expected_until, thesis_title, thesis_description, status
) values
  (
    'University of Pardubice, Faculty of Electrical Engineering and Informatics',
    null,
    'Master’s degree',
    '2014-09-01T00:00:00Z'::timestamptz,
    '2018-06-30T00:00:00Z'::timestamptz,
    'Software application for support and learning data structure R-tree',
    'Diploma thesis (Java/JavaFX)',
    'graduated'
  );

-- University of Pardubice — Bachelor’s (2010 – 2014)
insert into resume_education (
  institution, field, degree, since, expected_until, thesis_title, thesis_description, status
) values
  (
    'University of Pardubice, Faculty of Electrical Engineering and Informatics',
    null,
    'Bachelors’s degree',
    '2010-09-01T00:00:00Z'::timestamptz,
    '2014-06-30T00:00:00Z'::timestamptz,
    'Engine for interactive learning Math',
    'Bachelor thesis (Java/JavaFX)',
    'graduated'
  );

-- Certificates / Workshops (additional)
insert into resume_certificate (
  name, issuer, start_at, end_at, description, certificate_id, url
) values
  ('Clean Architecture', null, null, null, 'Course', null, null),
  ('Kotlin Coroutines Open Workshop', null, null, null, 'Workshop', null, null),
  ('Kotlin Expert Open Workshop', null, null, null, 'Workshop', null, null),
  ('Kotlin Mastery Open Workshop', null, null, null, 'Workshop', null, null),
  ('Kotlin for Developers Open Workshop', null, null, null, 'Workshop', null, null),
  ('Practical Use of Artificial Intelligence', null, null, null, 'Course', null, null),
  ('Reactive Spring Boot With Coroutines and Virtual Threads Workshop', null, null, null, 'Workshop', null, null),
  ('Software Architecture', null, null, null, 'Course', null, null);

-- Languages
insert into resume_language (name, level) values
  ('Czech', 'Native'),
  ('English', 'Fluent'),
  ('Japanese', 'Basic');


