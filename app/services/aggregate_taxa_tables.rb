# frozen_string_literal: true

class AggregateTaxaTables
  include ProcessFileUploads
  attr_reader :primer

  def initialize(primer)
    @primer = primer
  end

  # rubocop:disable Metrics/AbcSize
  def create_taxa_table_csv
    return if barcodes.blank?

    obj = s3_object(create_taxa_key)
    obj.upload_stream(acl: 'public-read') do |write_stream|
      CSV(write_stream) do |csv|
        csv << ['sum.taxonomy'] + barcodes

        execute(taxa_table_sql).entries.each do |record|
          csv << record.values
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def create_taxa_key
    date = Time.zone.today.strftime('%Y-%m-%d')
    "aggregate_csvs/taxa_#{date}_#{primer.name}.csv"
  end

  def execute(sql)
    ActiveRecord::Base.connection.exec_query(sql)
  end

  def taxa_table_sql
    <<~SQL
      SELECT
      "sum.taxonomy", #{select_barcode_sql}
      FROM CROSSTAB(
        'SELECT
        COALESCE(ncbi_nodes.hierarchy_names ->> ''superkingdom'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''phylum'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''class'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''order'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''family'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''genus'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''species'', ''''),
        samples.barcode, asvs.count
        FROM asvs
        JOIN samples ON asvs.sample_id = samples.id
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
        WHERE primer_id = #{primer.id}
        ORDER BY 1,2',

        '#{barcodes_sql}'
      ) AS foo (
        "sum.taxonomy" text,
        #{columns_sql}
      );
    SQL
  end

  def barcodes
    @barcodes ||= begin
      results = ActiveRecord::Base.connection.exec_query(barcodes_sql)
      results.map { |r| r['barcode'] }
    end
  end

  def barcodes_sql
    <<~SQL
      SELECT DISTINCT(samples.barcode)
      FROM asvs
      JOIN samples ON asvs.sample_id = samples.id
      WHERE primer_id = #{primer.id}
    SQL
  end

  def select_barcode_sql
    barcodes.map do |barcode|
      "COALESCE(\"#{barcode}\", 0) as \"#{barcode}\""
    end.join(',')
  end

  def columns_sql
    barcodes.map do |barcode|
      "\"#{barcode}\" int"
    end.join(',')
  end
end
