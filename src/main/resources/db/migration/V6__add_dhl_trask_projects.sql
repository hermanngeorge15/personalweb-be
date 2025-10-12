-- Add DHL and Trask projects

-- Project 1: DHL - Provider Subnet Comparison Application
INSERT INTO resume_project (
    id,
    company,
    project_name,
    start_at,
    end_at,
    description,
    responsibilities,
    tech_stack,
    repo_url,
    demo_url
) VALUES (
    gen_random_uuid(),
    'DHL a.s.',
    'Provider Subnet Comparison Application',
    '2020-01-01 00:00:00+00'::timestamptz,  -- Replace with actual start date
    '2021-12-31 23:59:59+00'::timestamptz,  -- Replace with actual end date
    'Design and development application for searching and comparing difference between provider subnets',
    ARRAY[]::text[],
    ARRAY['Maven', 'Spring', 'Java', 'Project Lombok', 'Hibernate', 'Docker', 'Jenkins', 'PostgreSQL'],
    NULL,
    NULL
);

-- Project 2: Trask Solutions - Document Management System
INSERT INTO resume_project (
    id,
    company,
    project_name,
    start_at,
    end_at,
    description,
    responsibilities,
    tech_stack,
    repo_url,
    demo_url
) VALUES (
    gen_random_uuid(),
    'Trask solutions a.s.',
    'Document Management System (DMS)',
    '2018-01-01 00:00:00+00'::timestamptz,  -- Replace with actual start date
    '2019-12-31 23:59:59+00'::timestamptz,  -- Replace with actual end date
    'Design and development of new functionalities in Document management system (DMS) for the banking sector',
    ARRAY[]::text[],
    ARRAY['Gradle', 'Spring', 'Java SE', 'MapStruct', 'Project Lombok'],
    NULL,
    NULL
);

