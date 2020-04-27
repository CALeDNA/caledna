
-- change status from results_completed to approved for samples from
-- delete research projects
update samples set status_cd = 'approved' where id in (
 select distinct(samples.id)
from samples
left join asvs on asvs.sample_id = samples.id
where status_cd = 'results_completed'
and asvs.id is  null
);


===
-- delete old research projects

delete from research_project_sources where research_project_id in (3,2,5,1);
delete from research_project_authors where research_project_id in (3,2,5,1);
delete from research_projects where id in (3,2,5,1);
