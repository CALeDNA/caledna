# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include FilterSamples

      def index
        render json: NcbiNodeSerializer.new(taxa).serializable_hash
      end

      def show
        render json: {
          samples: { data: taxa_samples },
          base_samples: { data: taxa_basic_samples },
          taxon: BasicTaxonSerializer.new(taxon)
        }, status: :ok
      end

      def next_taxon_id
        sql = 'SELECT MAX(taxon_id) FROM ncbi_nodes;'
        res = ActiveRecord::Base.connection.exec_query(sql)
        render json: { next_taxon_id: res[0]['max'] + 1 }
      end

      private

      # =======================
      # index
      # =======================

      def taxa
        if query.present?
          ::NcbiNode.where('lower("canonical_name") like ?', "#{query}%")
                    .limit(15)
        else
          []
        end
      end

      def query
        params[:query]&.downcase
      end

      # =======================
      # show
      # =======================

      def taxon
        @taxon ||= NcbiNode.find_by(taxon_id: params[:id])
      end

      def taxa_join_sql
        <<~SQL
          JOIN sample_primers ON samples_map.id = sample_primers.sample_id
          JOIN primers ON sample_primers.primer_id = primers.id
        SQL
      end

      def table1_sql
        completed_samples
          .joins(taxa_join_sql)
          .where('taxon_ids @> ?', "{#{params[:id]}}")
          .to_sql
      end

      def table2_sql
        <<~SQL
          SELECT (array_agg(
            canonical_name || '|' || ncbi_nodes.taxon_id
            ORDER BY asvs_count DESC NULLS LAST
          ))[0:15] as taxa, samples_map.id
          FROM samples_map
          JOIN asvs ON asvs.sample_id = samples_map.id
            AND status ='results_completed'
          JOIN ncbi_nodes ON asvs.taxon_id = ncbi_nodes.taxon_id
            AND ncbi_nodes.asvs_count > 0
            AND ncbi_nodes.ids @> ARRAY[$1]::integer[]
          GROUP BY samples_map.id
        SQL
      end

      def combined_sql
        <<~SQL
          SELECT * FROM(#{table1_sql}) table1
          JOIN (#{table2_sql}) table2
          on table1.id = table2.id
        SQL
      end

      def taxa_samples
        @taxa_samples ||= begin
          key = "#{taxon.cache_key}/taxa_samples/#{params_values}"
          Rails.cache.fetch(key, expires_in: 1.month) do
            records = conn.exec_query(combined_sql, 'q', [[nil, params[:id]]])
            records.each do |record|
              process_records(record)
            end
          end
        end
      end

      def process_records(record)
        record['primer_ids'] = YAML.safe_load(record['primer_ids']).keys
        record['primer_names'] = YAML.safe_load(record['primer_names']).keys
        record['taxa'] = YAML.safe_load(record['taxa']).keys.slice(0, 10)
        record
      end

      def taxa_basic_samples
        @taxa_basic_samples ||= begin
          website = Website.caledna
          key = "#{website.cache_key}/taxa_basic_samples/#{params_values}"
          Rails.cache.fetch(key, expires_in: 1.month) do
            basic_completed_samples.load
          end
        end
      end

      def params_values
        params.reject { |k, _v| %w[action controller].include?(k) }
              .values.join('_')
      end
    end
  end
end
