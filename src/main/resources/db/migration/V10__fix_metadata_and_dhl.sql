-- Fix Metadata project company name and title
-- Fix DHL dates to August 2016 – August 2020

-- ═══════════════════════════════════════════════════════════════════════════
-- FIX 1: Metadata driven development
-- Change company from "Metadata driven development" to "Adastra s.r.o"
-- Change title to "Java Backend Developer - Metadata driven development"
-- Dates: October 2019 – October 2020
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE resume_project
SET 
    company = 'Adastra s.r.o',
    project_name = 'Java Backend Developer - Metadata driven development',
    start_at = '2019-10-01 00:00:00+00'::timestamptz,
    end_at = '2020-10-31 23:59:59+00'::timestamptz
WHERE company = 'Metadata driven development'
  AND project_name = 'Java Backend Developer';

-- ═══════════════════════════════════════════════════════════════════════════
-- FIX 2: DHL dates
-- Update to: August 2016 – August 2020
-- ═══════════════════════════════════════════════════════════════════════════
UPDATE resume_project
SET 
    start_at = '2016-08-01 00:00:00+00'::timestamptz,
    end_at = '2020-08-31 23:59:59+00'::timestamptz
WHERE company = 'DHL a.s.';

