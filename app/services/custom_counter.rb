# frozen_string_literal: true

module CustomCounter
  def update_asvs_counts
    Asv.distinct.pluck(:taxonID).each do |id|
      print '.'
      count = get_count(id)
      update_count(id, count)
    end
  end

  def get_count(taxon_id)
    conn = ActiveRecord::Base.connection

    sql = 'SELECT COUNT(DISTINCT(samples.id)) ' \
    'FROM asvs ' \
    'JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" ' \
    'JOIN samples ON samples.id = asvs.sample_id ' \
    'WHERE samples.missing_coordinates = false ' \
    "AND ids @> '{#{conn.quote(taxon_id)}}'"

    # NOTE: exec_query bindings don't work with postgres array
    results = conn.exec_query(sql)
    results.to_a.first['count']
  end

  def get_sample_ids(taxon_id)
    conn = ActiveRecord::Base.connection

    sql = 'SELECT DISTINCT(samples.id) ' \
    'FROM asvs ' \
    'JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" ' \
    'JOIN samples ON samples.id = asvs.sample_id ' \
    'WHERE samples.missing_coordinates = false ' \
    "AND ids @> '{#{conn.quote(taxon_id)}}'"

    # NOTE: exec_query bindings don't work with postgres array
    results = conn.exec_query(sql)
    results.to_a
  end

  def update_count(taxon_id, count)
    taxon = NcbiNode.find(taxon_id)
    taxon.update(asvs_count: count)
  end
end
