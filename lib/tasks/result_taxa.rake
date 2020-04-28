# frozen_string_literal: true

namespace :result_taxa do
  task import_csv: :environment do
    include ImportCsv::EdnaResultsTaxa

    base = ENV.fetch('RESEARCH_PROJECT_BASE')
    # rubocop:disable Metrics/LineLength
    files = [
      {
        path: OpenStruct.new(path: "#{base}/desert/16S_ASV_sum_by_taxonomy_60_renamed.txt"),
        primer: '16S',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/desert/18S_ASV_sum_by_taxonomy_60_renamed.txt"),
        primer: '18S',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/desert/CO1_ASV_sum_by_taxonomy_60_renamed.txt"),
        primer: 'CO1',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/desert/FITS_ASV_sum_by_taxonomy_60_renamed.txt"),
        primer: 'FITS',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/desert/PITS_ASV_sum_by_taxonomy_60_renamed.txt"),
        primer: 'PITS',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/desert/trnL_ASV_sum_by_taxonomy_60_RM_renamed.txt"),
        primer: 'trnL',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_CO1_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: 'CO1',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_FITS_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: 'FITS',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_PITS_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: 'PITS',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_X12S_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: '12S',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_X16S_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: '16S',
        research_project_id: '6'
      },

      {
        path: OpenStruct.new(path: "#{base}/la_river/pilot/edna/LA_river_X18S_ASV_sum_by_taxonomy_70_dc_ed_min5.csv"),
        primer: '18S',
        research_project_id: '6'
      },
      {
        path: OpenStruct.new(path: "#{base}/pillar\ point/raw\ data/edna\ 4/CO1_with_BOLD_no_contam_combined_noSingletons.csv"),
        primer: 'CO1',
        research_project_id: '4'
      },
      {
        path: OpenStruct.new(path: "#{base}/pillar\ point/raw\ data/edna\ 4/X12S_merged_runs_decontam_0.1_correct_taxonomy_for_Wai-Yin.txt"),
        primer: '12S',
        research_project_id: '4'
      },
      {
        path: OpenStruct.new(path: "#{base}/pillar\ point/raw\ data/edna\ 4/X16S_merged_runs_decontam_0.1_no_singletons_Oct29.txt"),
        primer: '16S',
        research_project_id: '4'
      },
      {
        path: OpenStruct.new(path: "#{base}/pillar\ point/raw\ data/edna\ 4/X18S_merged_runs_decontam_0.1_no_singletons_Oct29.txt"),
        primer: '18S',
        research_project_id: '4'
      }
    ]

    more_files = [
      {
        path: OpenStruct.new(path: "#{base}/Palmyra_Atoll/ASV_12S.csv"),
        primer: '12S',
        research_project_id: '19'
      },
      {
        path: OpenStruct.new(path: "#{base}/Palmyra_Atoll/ASV_12Selasmo.csv"),
        primer: '12Selasmo',
        research_project_id: '19'
      },
      {
        path: OpenStruct.new(path: "#{base}/Palmyra_Atoll/ASV_18S.csv"),
        primer: '18S',
        research_project_id: '19'
      },
      {
        path: OpenStruct.new(path: "#{base}/Palmyra_Atoll/ASV_CO1.csv"),
        primer: 'CO1',
        research_project_id: '19'
      },

      {
        path: OpenStruct.new(path: "#{base}/transects/asv_deco_dedup_16S.csv"),
        primer: '16S',
        research_project_id: '20'
      },
      {
        path: OpenStruct.new(path: "#{base}/transects/asv_deco_dedup_18S.csv"),
        primer: '18S',
        research_project_id: '20'
      },
      {
        path: OpenStruct.new(path: "#{base}/transects/asv_deco_dedup_CO1.csv"),
        primer: 'CO1',
        research_project_id: '20'
      },
      {
        path: OpenStruct.new(path: "#{base}/transects/asv_deco_dedup_FITS.csv"),
        primer: 'FITS',
        research_project_id: '20'
      },
      {
        path: OpenStruct.new(path: "#{base}/transects/asv_deco_dedup_PITS.csv"),
        primer: 'PITS',
        research_project_id: '20'
      }
    ]
    # rubocop:enable Metrics/LineLength

    puts files.length
    puts more_files.length

    files.each do |file|
      puts "#{file[:path].path.split('/').last} - #{file[:research_project_id]}"

      import_csv(file[:path], file[:research_project_id], file[:primer])

      sleep(15)
    end
  end

  task add_canonical_name: :environment do
    ResultTaxon.where(canonical_name: nil).find_each do |taxon|
      name = find_canonical_taxon_from_string(taxon.clean_taxonomy_string)
      taxon.canonical_name = name
      taxon.save
    end
  end

  task update_missing_superkingdom_string: :environment do
    sql =  <<-SQL
    update result_taxa
    set original_taxonomy_superkingdom =
      coalesce(hierarchy ->> 'superkingdom', '') ||
      ';' || original_taxonomy_phylum
    where result_taxa.original_taxonomy_superkingdom is null;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  # skip checking phylum hierarchy when looking for taxa that match ceratin
  # taxonomy strings
  task normalize_strings_without_phylum: :environment do
    # rubocop:disable Metrics/MethodLength
    def find_taxa_by_hierarchy(hierarchy, target_rank)
      clauses = []
      ranks = %w[superkingdom class order family genus species]
      ranks.each do |rank|
        next if hierarchy[rank].blank?
        clauses << '"' + rank + '": "' +
                   hierarchy[rank].gsub("'", "''") + '"'
      end
      sql = "rank = '#{target_rank}' AND  hierarchy_names @> '{"
      sql += clauses.join(', ')
      sql += "}'"

      NcbiNode.where(sql)
    end
    # rubocop:enable Metrics/MethodLength

    sql = "hierarchy ->> 'class' = 'Oomycetes' OR " \
          " hierarchy ->> 'class' = 'Florideophyceae'"
    result_taxa = ResultTaxon.where(sql).where(normalized: false)

    result_taxa.each do |result_taxon|
      ncbi_taxa =
        find_taxa_by_hierarchy(result_taxon.hierarchy, result_taxon.taxon_rank)
      next unless ncbi_taxa.to_a.size == 1

      puts "#{result_taxon.original_taxonomy_string} - " \
        "#{ncbi_taxa.first.taxon_id}"
      result_taxon.taxon_id = ncbi_taxa.first.taxon_id
      result_taxon.normalized = true
      result_taxon.save
    end
  end
end
