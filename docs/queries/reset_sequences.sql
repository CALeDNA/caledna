ALTER SEQUENCE field_projects_id_seq RESTART WITH  63;
ALTER SEQUENCE  samples_id_seq RESTART WITH  7500;
ALTER SEQUENCE  kobo_photos_id_seq RESTART WITH  6571;
ALTER SEQUENCE pages_id_seq RESTART WITH 29;


select max(id) from asvs;
SELECT setval('asvs_id_seq', max(id)) FROM asvs;


select max(id) from result_taxa;
SELECT setval('result_taxa_id_seq', max(id)) FROM result_taxa;
