-- GEN ended in December 2025. Without an end date the site shows it as the current role
-- (Resume "Current role" card, About "Day job" card), so give it one.
-- Only an open-ended row is changed: an end date already set in /admin is kept.
UPDATE resume_project
SET end_at = '2025-12-31 23:59:59+00'::timestamptz
WHERE company = 'GEN'
  AND end_at IS NULL;
