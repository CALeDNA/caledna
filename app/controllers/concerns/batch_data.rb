# frozen_string_literal: true

module BatchData
  extend ActiveSupport::Concern

  private

  def asvs_count(sample_id = nil)
    sql = 'SELECT sample_id, COUNT(*) ' \
          'FROM asvs ' \
          'JOIN extractions ' \
          'ON asvs.extraction_id = extractions.id ' \
          'GROUP BY sample_id '
    sql += "WHERE sample_id = #{sample_id}" if sample_id
    @asvs_count ||= ActiveRecord::Base.connection.execute(sql)
  end

  def batch_vernaculars
    sql = 'SELECT ncbi_names.taxon_id, ncbi_names.name ' \
    'FROM asvs ' \
    'JOIN ncbi_names ON asvs."taxonID" = ncbi_names.taxon_id ' \
    'JOIN extractions ON asvs.extraction_id = extractions.id ' \
    "WHERE extractions.sample_id = #{params[:id]} " \
    "AND (name_class = 'common name' OR name_class = 'genbank common name')"

    @batch_vernaculars ||= ActiveRecord::Base.connection.execute(sql)
  end
end
