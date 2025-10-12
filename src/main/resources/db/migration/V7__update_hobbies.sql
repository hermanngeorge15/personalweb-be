-- Update hobbies/interests

-- Delete existing hobbies if any
DELETE FROM resume_hobbies;

-- Insert new hobbies
INSERT INTO resume_hobbies (
    id,
    sports,
    others
) VALUES (
    gen_random_uuid(),
    ARRAY['Sports']::text[],
    ARRAY['Traveling', 'Japan', 'Community builder']::text[]
);

