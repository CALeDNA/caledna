# frozen_string_literal: true

module ResearchProjectService
  module LaRiverServices
    module Intro
      def pilot_stats
        {
          maywood: maywood_stats,
          total: pilot_total_stats,
          arroyo_seco: arroyo_seco_stats
        }
      end

      def home_page_stats
        @home_page_stats ||= total_home_page_stats
      end

      private

      def river_sites
        @river_sites ||= begin
          Sample.where(field_project: FieldProject.la_river).approved
        end
      end

      def distinct_taxa
        @distinct_taxa ||= begin
          Asv.where(research_project: ResearchProject.la_river)
            .select('DISTINCT(asvs.taxon_id)')
        end
      end

      def total_home_page_stats
        sites = river_sites
        taxa = distinct_taxa
        locations = Place.where(place_type_cd: :pour_location)

        { sites: sites.count, taxa: taxa.count, locations: locations.count }
      end

      def river_pilot_sites
        @river_completed_sites ||= begin
          ResearchProjectSource
            .where(sourceable_type: 'Sample')
            .where(research_project: ResearchProject.la_river)
            .where("metadata ->> 'order' = '1'")
        end
      end

      def distinct_taxa_pilot
        river_pilot_sites
          .joins('JOIN asvs on asvs.sample_id = ' \
            'research_project_sources.sourceable_id')
          .select('DISTINCT(asvs.taxon_id)')
      end


      def pilot_total_stats
        sites = river_pilot_sites
        taxa = distinct_taxa_pilot

        { sites: sites.count, taxa: taxa.count }
      end

      def maywood_stats
        location = "research_project_sources.metadata ->> 'location' = " \
        "'Maywood'"
        sites = river_pilot_sites.where(location)
        taxa = distinct_taxa_pilot.where(location)

        { sites: sites.count, taxa: taxa.count }
      end


      def arroyo_seco_stats
        location = "research_project_sources.metadata ->> 'location' = " \
        "'Arroyo Seco'"
        sites = river_pilot_sites.where(location)
        taxa = distinct_taxa_pilot.where(location)

        { sites: sites.count, taxa: taxa.count }
      end
    end
  end
end
