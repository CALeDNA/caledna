# frozen_string_literal: true

class SamplesController < ApplicationController
  include CheckWebsite
  include FilterSamples

  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @samples_count = approved_samples_count
    @samples_with_results_count = completed_samples_count
    @taxa_count = Website::DEFAULT_SITE.taxa_count
  end

  def show
    @division_counts = division_counts
    @sample = sample
    @organisms_count = organisms_count
  end

  private

  # =======================
  # show
  # =======================

  def organisms_count_sql
    <<~SQL
      SELECT count(*) FROM (
        SELECT DISTINCT taxon_id
        FROM asvs
        where sample_id = #{sample.id}
      )as temp;
    SQL
  end

  def organisms_count
    @organisms_count ||= begin
      conn.exec_query(organisms_count_sql).entries.first['count']
    end
  end

  def division_counts_sql
    <<~SQL
      SELECT COUNT(*) AS count_name, name
      FROM asvs
      JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
      JOIN ncbi_divisions ON ncbi_divisions.id = ncbi_nodes.cal_division_id
      WHERE asvs.sample_id = #{sample.id}
      AND ncbi_nodes.taxon_id IN (
        SELECT DISTINCT taxon_id FROM asvs WHERE sample_id = #{sample.id}
      )
      GROUP BY name;
    SQL
  end

  def division_counts
    @division_counts ||= begin
      counts = {}
      conn.exec_query(division_counts_sql).each do |record|
        counts[record['name']] = record['count_name'].to_i
      end
      counts
    end
  end

  def sample
    @sample ||= begin
      temp = approved_completed_samples.find_by(id: params[:id])
      Sample.find(temp&.id)
    end
  end

  def conn
    ActiveRecord::Base.connection
  end
end
