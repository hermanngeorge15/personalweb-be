-- Fix overlapping and incorrect dates in resume projects
-- See docs/RESUME_DATE_FIXES.md for explanation
--
-- ⚠️  IMPORTANT: Choose ONE scenario below and uncomment ONLY that section!
--
-- Current WRONG dates in database:
--   DHL:   Jan 2020 - Dec 2021  ❌
--   Trask: Jan 2018 - Dec 2019  ❌
--
-- ═══════════════════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ SCENARIO A: No Overlapping Jobs (Most Common)                          │
-- │ Use this if you worked one full-time job at a time                     │
-- └─────────────────────────────────────────────────────────────────────────┘

-- 1. Fix Trask: January 2017 – September 2018
UPDATE resume_project
SET 
    start_at = '2017-01-01 00:00:00+00'::timestamptz,
    end_at = '2018-09-30 23:59:59+00'::timestamptz
WHERE company = 'Trask solutions a.s.';

-- 2. Fix DHL: August 2016 – December 2016 (before Trask)
UPDATE resume_project
SET 
    start_at = '2016-08-01 00:00:00+00'::timestamptz,
    end_at = '2016-12-31 23:59:59+00'::timestamptz,
    project_name = 'Java backend developer / data analyst'
WHERE company = 'DHL a.s.';

-- 3. Fix Adastra HCCN-MAPP: November 2018 – October 2019
UPDATE resume_project
SET 
    start_at = '2018-11-01 00:00:00+00'::timestamptz,
    end_at = '2019-10-31 23:59:59+00'::timestamptz
WHERE company = 'Adastra s.r.o'
  AND project_name LIKE '%HCCN%';

-- 4. Fix Metadata: November 2019 – October 2020 (moved 1 month to not overlap)
UPDATE resume_project
SET 
    start_at = '2019-11-01 00:00:00+00'::timestamptz,
    end_at = '2020-10-31 23:59:59+00'::timestamptz
WHERE company = 'Metadata driven development';

-- 5. Fix Nakoupeno: February 2020 – March 2020 (short project within Metadata period)
UPDATE resume_project
SET 
    start_at = '2020-02-01 00:00:00+00'::timestamptz,
    end_at = '2020-03-31 23:59:59+00'::timestamptz,
    company = 'Adastra s.r.o'
WHERE project_name LIKE '%Nakoupeno%';

-- ═══════════════════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ SCENARIO B: DHL Was Part-Time/Consulting (Uncomment below if this)    │
-- │ Use this if you worked at DHL while also working full-time elsewhere   │
-- └─────────────────────────────────────────────────────────────────────────┘

-- -- 1. Fix Trask: January 2017 – September 2018
-- UPDATE resume_project
-- SET 
--     start_at = '2017-01-01 00:00:00+00'::timestamptz,
--     end_at = '2018-09-30 23:59:59+00'::timestamptz
-- WHERE company = 'Trask solutions a.s.';

-- -- 2. Fix DHL: August 2016 – August 2020 (mark as part-time)
-- UPDATE resume_project
-- SET 
--     start_at = '2016-08-01 00:00:00+00'::timestamptz,
--     end_at = '2020-08-31 23:59:59+00'::timestamptz,
--     project_name = 'Java backend developer / data analyst (Part-time)',
--     description = COALESCE(description, '') || E'\n\nNote: Part-time/consulting role concurrent with full-time positions.'
-- WHERE company = 'DHL a.s.';

-- -- 3. Fix Adastra HCCN-MAPP: November 2018 – October 2019
-- UPDATE resume_project
-- SET 
--     start_at = '2018-11-01 00:00:00+00'::timestamptz,
--     end_at = '2019-10-31 23:59:59+00'::timestamptz
-- WHERE company = 'Adastra s.r.o'
--   AND project_name LIKE '%HCCN%';

-- -- 4. Fix Metadata: October 2019 – August 2020 (end with DHL)
-- UPDATE resume_project
-- SET 
--     start_at = '2019-10-01 00:00:00+00'::timestamptz,
--     end_at = '2020-08-31 23:59:59+00'::timestamptz
-- WHERE company = 'Metadata driven development';

-- -- 5. Fix Nakoupeno: February 2020 – March 2020 (within Metadata)
-- UPDATE resume_project
-- SET 
--     start_at = '2020-02-01 00:00:00+00'::timestamptz,
--     end_at = '2020-03-31 23:59:59+00'::timestamptz,
--     company = 'Adastra s.r.o'
-- WHERE project_name LIKE '%Nakoupeno%';

-- ═══════════════════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ SCENARIO C: DHL After Trask (Uncomment below if this)                  │
-- │ Use this if you worked at DHL from 2018-2020 (after Trask ended)       │
-- └─────────────────────────────────────────────────────────────────────────┘

-- -- 1. Fix Trask: January 2017 – September 2018
-- UPDATE resume_project
-- SET 
--     start_at = '2017-01-01 00:00:00+00'::timestamptz,
--     end_at = '2018-09-30 23:59:59+00'::timestamptz
-- WHERE company = 'Trask solutions a.s.';

-- -- 2. Fix DHL: October 2018 – August 2020 (after Trask)
-- UPDATE resume_project
-- SET 
--     start_at = '2018-10-01 00:00:00+00'::timestamptz,
--     end_at = '2020-08-31 23:59:59+00'::timestamptz,
--     project_name = 'Java backend developer / data analyst'
-- WHERE company = 'DHL a.s.';

-- -- 3. Fix Adastra HCCN-MAPP: November 2018 – October 2019 (overlaps with DHL start!)
-- UPDATE resume_project
-- SET 
--     start_at = '2018-11-01 00:00:00+00'::timestamptz,
--     end_at = '2019-10-31 23:59:59+00'::timestamptz
-- WHERE company = 'Adastra s.r.o'
--   AND project_name LIKE '%HCCN%';

-- -- 4. Fix Metadata: October 2019 – August 2020 (overlaps with DHL end!)
-- UPDATE resume_project
-- SET 
--     start_at = '2019-10-01 00:00:00+00'::timestamptz,
--     end_at = '2020-08-31 23:59:59+00'::timestamptz
-- WHERE company = 'Metadata driven development';

-- -- 5. Fix Nakoupeno: February 2020 – March 2020
-- UPDATE resume_project
-- SET 
--     start_at = '2020-02-01 00:00:00+00'::timestamptz,
--     end_at = '2020-03-31 23:59:59+00'::timestamptz,
--     company = 'Adastra s.r.o'
-- WHERE project_name LIKE '%Nakoupeno%';

-- ═══════════════════════════════════════════════════════════════════════════
-- All other projects (Česká spořitelna, PBK, GEN/Avast) are already correct
-- ═══════════════════════════════════════════════════════════════════════════

