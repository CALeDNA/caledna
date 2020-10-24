refresh materialized view samples_map;

-- add metadatat for PouR samples

update research_project_sources
set metadata = jsonb_set(metadata,'{collection_period}','"Summer 2020"')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 17
)
and sourceable_type = 'Sample';

update research_project_sources
set metadata = jsonb_set(metadata,'{collection_period}','"Fall 2020"')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 17 offset 17
)
and sourceable_type = 'Sample';


update research_project_sources
set metadata = jsonb_set(metadata,'{collection_period}','"Winter 2020"')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 18 offset 34
)
and sourceable_type = 'Sample';


update research_project_sources
set metadata = jsonb_set(metadata,'{order}','1')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 17
)
and sourceable_type = 'Sample';

update research_project_sources
set metadata = jsonb_set(metadata,'{order}','2')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 17 offset 17
)
and sourceable_type = 'Sample';


update research_project_sources
set metadata = jsonb_set(metadata,'{order}','3')
where sourceable_id in (
select distinct sample_id from sample_primers where research_project_id = 7 limit 18 offset 34
)
and sourceable_type = 'Sample';

