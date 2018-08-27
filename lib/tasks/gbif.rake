# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :gbif do
  task import_missing_fields_for_occ_taxa: :environment do
    api = GbifApi.new
    conn = ActiveRecord::Base.connection

    GbifOccTaxa.where(taxonkey: nil).each do |taxon|
      rank = taxon.taxonrank
      query = { rank: taxon.taxonrank }
      if rank == 'kingdom'
        query[:kingdom] = taxon.kingdom
        rank_sql = "AND kingdom = #{conn.quote(taxon.kingdom)}"
      elsif rank == 'phylum'
        query[:phylum] = taxon.phylum
        rank_sql = "AND phylum = #{conn.quote(taxon.phylum)}"
      elsif rank == 'class'
        query[:class] = taxon.classname
        rank_sql = "AND classname = #{conn.quote(taxon.classname)}"
      elsif rank == 'order'
        query[:order] = taxon.order
        rank_sql = "AND \"order\" = #{conn.quote(taxon.order)}"
      elsif rank == 'family'
        query[:family] = taxon.family
        rank_sql = "AND family = #{conn.quote(taxon.family)}"
      elsif rank == 'genus'
        query[:family] = taxon.family
        query[:genus] = taxon.genus
        rank_sql = "AND family = #{conn.quote(taxon.family)} " \
          "AND genus = #{conn.quote(taxon.genus)}"
      else
        next
      end

      response = api.taxa_by_rank(query)
      result = response.parsed_response

      puts result['usageKey']

      taxon.taxonkey = result['usageKey']
      taxon.scientificname = result['scientificName']
      sql = 'UPDATE external.gbif_occ_taxa ' \
      "SET taxonkey = #{result['usageKey']},  " \
      "scientificname = #{conn.quote(result['scientificName'])} " \
      "WHERE taxonrank = #{conn.quote(rank)} " \
      'AND taxonkey IS NULL '
      sql += rank_sql

      conn.execute(sql)
    end
  end
end
# rubocop:enable Metrics/BlockLength
