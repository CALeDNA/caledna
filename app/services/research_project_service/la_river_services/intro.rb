# frozen_string_literal: true

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

      def home_page_stats
        total_home_page_stats
      end

      private

      def river_sites
        @river_sites ||= begin
          ResearchProjectSource
            .where(sourceable_type: 'Sample')
            .where(research_project: project)
            .joins(:sample)
        end
      end

      def distinct_taxa(sites)
        sites
          .joins('JOIN asvs ON asvs.sample_id = samples.id')
          .joins('JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id')
          .where('cal_division_id IS NOT NULL')
          .select('DISTINCT(asvs.taxon_id)')
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

      def total_home_page_stats
        sites = river_sites
        taxa = distinct_taxa(sites)
        locations = river_sites
                    .select("DISTINCT(samples.metadata ->> 'location' )")

        { sites: sites.count, taxa: taxa.count, locations: locations.count }
      end
    end
  end
end
