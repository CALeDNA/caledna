-- create clean_taxonomy_string_phylum by removing
-- superkingdom from clean_taxonomy_string

UPDATE result_taxa set clean_taxonomy_string_phylum = regexp_replace(clean_taxonomy_string, '^.*?;' , '');
