# frozen_string_literal: true

class AggregateTaxaTables
  attr_reader :primer

  def initialize(primer)
    @primer = primer
  end

  def create_taxa_table_csv
    return if barcodes.blank?

    date = Time.zone.today.strftime('%Y-%m-%d')
    CSV.open("CALeDNA_#{date}_#{primer.name}.csv", 'wb') do |csv|
      csv << ['sum.taxonomy'] + barcodes

      execute(taxa_table_sql).entries.each do |record|
        csv << record.values
      end
    end
  end

  private

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

        'SELECT DISTINCT(samples.barcode)
        FROM asvs
        JOIN samples ON asvs.sample_id = samples.id
        WHERE primer_id = #{primer.id}'
      ) AS foo (
        "sum.taxonomy" text,
        #{columns_sql}
      );
    SQL
  end

  def barcodes
    @barcodes ||= begin
      Asv.joins(:sample).select('DISTINCT(barcode)')
         .where(primer_id: primer.id)
         .map(&:barcode)
    end
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
