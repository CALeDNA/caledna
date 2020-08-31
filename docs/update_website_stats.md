people import caledna edna results
- add new asv records -> need to update ncbi_nodes asvs_counts
- add new asv records -> need to update caledna website taxa counts
- add new asv records -> need to update samples_map taxa and taxa_ids
- add new asv records -> need to update ncbi_nodes_edna

-> add refresh_caledna_website_stats, refresh_samples_map, refresh_ncbi_nodes_edna to FetchTaxaAsvsCountsJob

==


people import pour edna results
- add new asv records -> need to update ncbi_nodes asvs_counts
- add new asv records -> need to update ncbi_nodes asvs_counts_la_river
- add new asv records -> need to update caledna website taxa counts
- add new asv records -> need to pour update website taxa counts
- add new asv records -> need to update samples_map taxa and taxa_ids
- add new asv records -> need to update ncbi_nodes_edna

-> add FetchTaxaAsvsCountsJob to TaxaCountsController#update_la_river_taxa_asvs_count
-> add refresh_pour_website_stats to FetchLaRiverTaxaAsvsCountsJob
-> add refresh_caledna_website_stats, refresh_samples_map, refresh_ncbi_nodes_edna to FetchTaxaAsvsCountsJob


==

people delete edna results for a project
- delete asv records -> need to update caledna website taxa counts
- delete asv records -> need to update ncbi_nodes asvs_counts
- add new asv records -> need to update samples_map taxa and taxa_ids
- add new asv records -> need to update ncbi_nodes_edna


-> add refresh_caledna_website_stats, FetchTaxaAsvsCountsJob to ResearchProjectResultsController#delete_records
-> add refresh_samples_map, refresh_ncbi_nodes_edna to FetchTaxaAsvsCountsJob

==

people import new samples via csv
- add new completed samples -> need to update samples_map view

-> add refresh_samples_map to KoboFieldData#import_csv

==

people approve sample
- add new approved samples -> need to update samples_map view

-> add Sync Samples to admin
-> add refresh_samples_map  to ApproveSamplesController#update_sync_samples


===

In order to cache the /api/samples, I need to invalidate the cache when:

samples are approved
-> add change_websites_update_at to ApproveSamplesController#update_sync_samples

samples are imported via csv
-> add change_websites_update_at to KoboFieldData#import_csv

eDNA results are imported
- already taken care  by refresh_xxx_website_stats in FetchLaRiverTaxaAsvsCountsJob,
FetchTaxaAsvsCountsJob
