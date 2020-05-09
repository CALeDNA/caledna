
==

def primer_names_sql
  <<~SQL
    ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
    AS primer_names,
    1,
    2
  SQL
end

def primer_ids_sql
  <<~SQL
    ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
    AS primer_ids,
    1,
    2
  SQL
end


"samples"."gps_precision", ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
AS primer_names,
1,
2
, ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
AS primer_ids,
1,
2
, count(asvs.taxon_id) as taxa_count,

===

def primer_names_sql
  <<~SQL.chomp
    ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
    AS primer_names,
    1,
    2
  SQL
end

def primer_ids_sql
  <<~SQL.chomp
    ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
    AS primer_ids,
    1,
    2
  SQL
end

"samples"."gps_precision", ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
AS primer_names,
1,
2, ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
AS primer_ids,
1,
2, count(asvs.taxon_id) as taxa_count

==

  def primer_names_sql
    <<-SQL
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names,
      1,
      2
    SQL
  end

  def primer_ids_sql
    <<-SQL
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids,
      1,
      2
    SQL
  end


"samples"."gps_precision",       ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names,
      1,
      2
,       ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids,
      1,
      2
, count(asvs.taxon_id) as taxa_count

==

  def primer_names_sql
    %(
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names
    )
  end

  def primer_ids_sql
    %(
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids
    )
  end


"samples"."gps_precision",
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names
    ,
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids
    , count(asvs.taxon_id) as taxa_count

