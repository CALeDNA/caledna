# frozen_string_literal: true

namespace :ncbi do
  require_relative '../../app/services/format_ncbi'
  require_relative '../../app/services/process_test_results'

  include FormatNcbi
  include ProcessTestResults

  desc 'create canonical name'
  task create_canonical_name: :environment do
    puts 'create canonical name...'
    create_canonical_name
  end

  desc 'create alt_names'
  task create_alt_names: :environment do
    puts 'create alt_names...'
    create_alt_names
  end

  desc 'create lineage info'
  task create_lineage_info: :environment do
    puts 'create lineage info...'
    create_lineage_info
  end

  desc 'create citations nodes'
  task create_citations_nodes: :environment do
    puts 'create citations nodes...'
    create_citations_nodes
  end

  desc 'create taxonomy strings'
  task create_taxonomy_strings: :environment do
    puts 'create taxonomy strings...'
    create_taxonomy_strings
  end

  desc 'create ids'
  task create_ids: :environment do
    puts 'create ids...'
    create_ids
  end

  desc 'update cal divisions for "Plants and Fungi"'
  task update_cal_division_for_plants_fungi: :environment do
    chromista = NcbiDivision.create(name: 'Chromista', comments: 'Added by CALeDNA')
    protozoa = NcbiDivision.create(name: 'Protozoa', comments: 'Added by CALeDNA')
    plants = NcbiDivision.find_by(name: 'Plants')

    puts 'update phylums...'

    phylums = %w[
      Aurearenophyceae
      Bacillariophyta
      Bolidophyceae
      Eustigmatophyceae
      Phaeophyceae
      Pinguiophyceae
      Xanthophyceae
    ]

    phylums.each do |phylum|
      NcbiNode.where("hierarchy_names ->> 'phylum' = '#{phylum}'")
              .update(cal_division_id: chromista.id)
    end

    NcbiNode.where("hierarchy_names ->> 'phylum' = 'Euglenida'")
            .update(cal_division_id: protozoa.id)

    puts 'update classes...'

    classnames = %w[
      Chrysomerophyceae
      Chrysophyceae
      Cryptophyta
      Dictyochophyceae
      Dinophyceae
      Labyrinthulomycetes
      Oomycetes
      Pelagophyceae
      Phaeothamniophyceae
      Placididea
      Raphidophyceae
      Synurophyceae
    ]
    classnames.each do |classname|
      NcbiNode.where("hierarchy_names ->> 'class' = '#{classname}'")
              .update(cal_division_id: chromista.id)
    end

    puts 'update plant classes...'

    plants_classes = %w[
      Bangiophyceae
      Compsopogonophyceae
      Florideophyceae
      Rhodellophyceae
      Stylonematophyceae
    ]

    plants_classes.each do |plant|
      NcbiNode.where("hierarchy_names ->> 'class' = '#{plant}'")
              .update(cal_division_id: plants.id)
    end

    puts 'update orders...'

    orders = %w[
      Coccolithales
      Euglyphida
      Isochrysidales
      Pavlovales
      Phaeoconchida
      Phaeocystales
      Phaeogymnocellida
      Phaeosphaerida
      Prymnesiales
    ]
    orders.each do |order|
      NcbiNode.where("hierarchy_names ->> 'order' = '#{order}'")
              .update(cal_division_id: chromista.id)
    end
  end

  desc 'create hierarchy_names'
  task hierarchy_names: :environment do
    puts 'create hierarchy_names...'
    create_hierarchy_names_info
  end

  desc 'update cal_taxon'
  task update_cal_taxon: :environment do
    puts 'update cal_taxon...'
    CalTaxon.where(exact_gbif_match: false).all.each do |taxon|
      results = find_taxon_from_string_phylum(taxon.original_taxonomy)

      if results[:taxon_id].blank? && results[:rank].present?
        update_data = {
          taxonRank: results[:rank],
          original_hierarchy: results[:original_hierarchy],
          original_taxonomy: results[:original_taxonomy],
          complete_taxonomy: results[:complete_taxonomy],
          normalized: false,
          exact_gbif_match: false
        }
      elsif results[:taxon_id].present? && results[:rank].present?
        update_data = {
          taxonRank: results[:rank],
          original_hierarchy: results[:original_hierarchy],
          original_taxonomy: results[:original_taxonomy],
          complete_taxonomy: results[:complete_taxonomy],
          normalized: true,
          exact_gbif_match: true,
          taxonID: results[:taxon_id]
        }
      end

      taxon.attributes = update_data
      taxon.save(validate: false)
    end
  end
end
