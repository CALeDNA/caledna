TRUNCATE  asvs restart identity;
TRUNCATE  pages restart identity;
TRUNCATE  sample_primers restart identity;
TRUNCATE result_taxa restart identity;
TRUNCATE research_project_authors restart identity;
TRUNCATE research_project_sources restart identity;
TRUNCATE kobo_photos restart identity;
TRUNCATE event_registrations restart identity;
TRUNCATE events restart identity CASCADE;TRUNCATE research_projects restart identity CASCADE;
TRUNCATE samples restart identity CASCADE;
TRUNCATE field_projects restart identity CASCADE;


pg_restore  --verbose --no-acl --no-owner -n public -t field_projects -t samples -t research_projects   -d caledna_development  rollback.dmp

pg_restore  --verbose --no-acl --no-owner -n public  -t events  -t kobo_photos -t research_project_sources -t research_project_authors -t result_taxa -t sample_primers -t  pages -t asvs -d caledna_development  rollback.dmp

pg_restore  --verbose --no-acl --no-owner -n public  -t event_registrations -d caledna_development  rollback.dmp



- note can't copy samples because of json error. Use postico manual field projects,
then samples, then copy the rest.

psql -d caledna_development -c '\copy result_taxa FROM  'result_taxa.csv' WITH CSV HEADER;'
psql -d caledna_development -c '\copy research_projects FROM  'research_projects.csv' WITH CSV HEADER;'
psql -d caledna_development -c '\copy sample_primers FROM  'sample_primers.csv' WITH CSV HEADER;'
psql -d caledna_development -c '\copy pages FROM  'pages.csv' WITH CSV HEADER;'
psql -d caledna_development -c '\copy asvs FROM  'asvs.csv' WITH CSV HEADER;'
psql -d caledna_development -c '\copy research_project_sources FROM  'research_project_sources.csv' WITH CSV HEADER;'


copy result_taxa FROM  'result_taxa.csv' WITH CSV HEADER;'
copy field_projects FROM  'field_projects.csv' WITH CSV HEADER;'
copy research_projects FROM  'research_projects.csv' WITH CSV HEADER;'
copy sample_primers FROM  'sample_primers.csv' WITH CSV HEADER;'
copy pages FROM  'pages.csv' WITH CSV HEADER;'
copy asvs FROM  'asvs.csv' WITH CSV HEADER;'
copy research_project_sources FROM  'research_project_sources.csv' WITH CSV HEADER;'


===

NOTICE:  truncate cascades to table "asvs_2017"
NOTICE:  truncate cascades to table "pages"
NOTICE:  truncate cascades to table "research_project_authors"
NOTICE:  truncate cascades to table "research_project_sources"
NOTICE:  truncate cascades to table "asvs"
NOTICE:  truncate cascades to table "sample_primers"
TRUNCATE TABLE research_projects


NOTICE:  truncate cascades to table "asvs_2017"
NOTICE:  truncate cascades to table "kobo_photos"
NOTICE:  truncate cascades to table "asvs"
NOTICE:  truncate cascades to table "sample_primers"
TRUNCATE TABLE samples

NOTICE:  truncate cascades to table "events"
NOTICE:  truncate cascades to table "samples"
NOTICE:  truncate cascades to table "asvs_2017"
NOTICE:  truncate cascades to table "event_registrations"
NOTICE:  truncate cascades to table "kobo_photos"
NOTICE:  truncate cascades to table "asvs"
NOTICE:  truncate cascades to table "sample_primers"
TRUNCATE TABLE field_projects

---------

