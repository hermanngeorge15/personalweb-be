-- Update site meta with new social links

UPDATE site_meta
SET 
    email = 'me@jirihermann.com',
    location = 'Prague, Czechia',
    socials = jsonb_build_object(
        'github_personal', 'https://github.com/hermanngeorge15',
        'github_kss', 'https://github.com/Kotlin-server-squad',
        'website', 'https://jirihermann.com/',
        'kss_website', 'https://kotlinserversquad.com',
        'phone', '+420 774246408'
    )
WHERE id = 1;

