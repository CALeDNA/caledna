CREATE INDEX "idx_ncbi_scientific_name" ON "2019_dwc_ncbi" ("scientificName");
CREATE INDEX "idx_gbif_scientific_name" ON "2019_dwc_gbif" ("scientificName");


CREATE INDEX "idx_ncbi_family" ON "2019_dwc_ncbi" ("family");
CREATE INDEX "idx_gbif_family" ON "2019_dwc_gbif" ("family");


.headers on
.mode csv
.once query_results_higher.csv
select "2019_dwc_gbif".*, "2019_dwc_ncbi".* from "2019_dwc_gbif" inner join "2019_dwc_ncbi" on "2019_dwc_gbif" ."scientificName" = "2019_dwc_ncbi"."scientificName" where  ("2019_dwc_ncbi"."taxonRank" = 'phylum' or "2019_dwc_ncbi"."taxonRank" = 'class' or "2019_dwc_ncbi"."taxonRank" = 'order') and "2019_dwc_ncbi"."taxonomicStatus" = 'accepted';


.headers on
.mode csv
.once query_results.csv
select "2019_dwc_gbif".*, "2019_dwc_ncbi".* from "2019_dwc_gbif" inner join "2019_dwc_ncbi" on "2019_dwc_gbif" ."scientificName" = "2019_dwc_ncbi"."scientificName" where "2019_dwc_gbif" ."family" = "2019_dwc_ncbi"."family" and ("2019_dwc_ncbi"."taxonRank" = 'family' OR "2019_dwc_ncbi"."taxonRank" = 'genus' OR "2019_dwc_ncbi"."taxonRank" = 'species') and "2019_dwc_ncbi"."taxonomicStatus" = 'accepted';

