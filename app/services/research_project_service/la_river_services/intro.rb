# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module LaRiverServices
    module Intro
      def stats
        {
          maywood: maywood_stats,
          total: total_stats,
          hahamongna: hahamongna_stats
        }
      end

      private

      def river_sites
        @river_sites ||= begin
          ResearchProjectSource
            .where(sourceable_type: 'Extraction')
            .where(research_project: project)
            .joins(:sample)
        end
      end

      def distinct_taxa(sites)
        sites
          .joins('JOIN asvs ON asvs.sample_id = samples.id')
          .joins('JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs."taxonID"')
          .where('cal_division_id IS NOT NULL')
          .select('DISTINCT(asvs."taxonID")')
      end

      def maywood_stats
        sites = river_sites
                .where("samples.metadata ->> 'location' = 'Maywood Park'")
        taxa = distinct_taxa(sites)

        { sites: sites.count, taxa: taxa.count }
      end

      def total_stats
        sites = river_sites
        taxa = distinct_taxa(sites)

        { sites: sites.count, taxa: taxa.count }
      end

      def hahamongna_stats
        sites = river_sites
                .where("samples.metadata ->> 'location' = 'Hahamongna'")
        taxa = distinct_taxa(sites)

        { sites: sites.count, taxa: taxa.count }
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength