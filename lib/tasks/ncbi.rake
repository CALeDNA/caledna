# frozen_string_literal: true

namespace :ncbi do
  require_relative '../../app/services/format_ncbi'
  require_relative '../../app/services/process_edna_results'

  include FormatNcbi
  include ProcessEdnaResults

  desc 'create alt_names'
  task create_alt_names: :environment do
    puts 'create alt_names...'
    puts Time.zone.now
    create_alt_names
    puts Time.zone.now
  end

  desc 'create taxa tree'
  task create_taxa_tree: :environment do
    puts 'create taxa tree...'
    puts Time.zone.now
    create_taxa_tree
    puts Time.zone.now
  end

  desc 'create common names'
  task create_common_names: :environment do
    puts 'create_common_names...'
    puts Time.zone.now
    create_common_names
    puts Time.zone.now
  end

  desc 'add ncbi_id to ncbi_nodes to handle BOLD'
  task add_ncbi_id_to_ncbi_nodes: :environment do
    sql = <<-SQL
      UPDATE ncbi_nodes
      SET ncbi_id = taxon_id
      WHERE bold_id IS NULL
      AND ncbi_id IS NULL
      AND taxon_id < 3000000;
    SQL

    conn.exec_query(sql)
  end

  desc 'update cal divisions for "Plants and Fungi"'
  task update_cal_division_for_plants_fungi: :environment do
    chromista =
      NcbiDivision.create(name: 'Chromista', comments: 'Added by CALeDNA')
    protozoa =
      NcbiDivision.create(name: 'Protozoa', comments: 'Added by CALeDNA')
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

  desc 'update result_taxon'
  task update_result_taxon: :environment do
    puts 'update result_taxon...'
    ResultTaxon.where(exact_gbif_match: false).all.each do |taxon|
      results = format_result_taxon_data_from_string(taxon.original_taxonomy)

      if results[:taxon_id].blank? && results[:rank].present?
        update_data = results.merge(normalized: false, ignore: false)
      elsif results[:taxon_id].present? && results[:rank].present?
        update_data = results.merge(normalized: true, ignore: false)
      end

      taxon.attributes = update_data
      taxon.save(validate: false)
    end
  end

  task delete_bad_imported_taxa: :environment do
    NcbiNode.where('ncbi_id is null')
            .where('bold_id is null')
            .where('taxon_id > 3000000')
            .delete_all
  end

  task update_cal_division_up_to_order: :environment do
    queries = [
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 5653;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 5752;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 5789;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 5794;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 5977;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 5988;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 6000;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 6015;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 6020;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 27998;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 28009;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 29185;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 31291;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 33651;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 33651;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 33827;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 33829;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 37104;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 37471;',
      'UPDATE ncbi_nodes set cal_division_id = 14 WHERE taxon_id = 38254;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 42382;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 42740;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 65574;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 65582;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 66288;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 66524;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 73027;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 127916;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 137614;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 137622;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 188941;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 188944;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 191814;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 194287;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 208471;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 211104;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 238765;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 238786;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 238790;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 251709;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 285691;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 285692;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 285693;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 313555;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 318493;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 332294;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 339960;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 418917;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 418921;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 418928;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 418930;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 419944;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 435411;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 557229;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 589438;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 589444;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 658449;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 740972;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 740974;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 740976;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 740984;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 877183;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 998816;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1051633;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1054998;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1216353;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 1237875;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1238681;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1249559;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1367446;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1395567;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 1485168;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1492816;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 1498967;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1572403;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 1659748;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 2058181;',
      'UPDATE ncbi_nodes set cal_division_id = 18 WHERE taxon_id = 2058949;',
      'UPDATE ncbi_nodes set cal_division_id = 17 WHERE taxon_id = 5043353;'
    ]

    queries.each do |sql|
      conn.exec_query(sql)
    end
  end

  task update_ncbi_divisions: :environment do
    queries = [
      'UPDATE ncbi_nodes SET cal_division_id = NULL WHERE taxon_id = 2759;',
      "UPDATE ncbi_nodes SET cal_division_id = 14 WHERE ids @> '{2763}';",
      "UPDATE ncbi_nodes SET cal_division_id = 17 WHERE ids @> '{33630}';",
      "UPDATE ncbi_nodes SET cal_division_id = 17 WHERE ids @> '{193537}';",
      "UPDATE ncbi_nodes SET cal_division_id = 17 WHERE ids @> '{2830}';",
      "UPDATE ncbi_nodes SET cal_division_id = 17 WHERE ids @> '{543769}';",
      "UPDATE ncbi_nodes SET cal_division_id = 17 WHERE ids @> '{33634}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{554915}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{554296}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{1401294}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{33682}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{207245}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{556282}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{136087}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{5719}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{134557}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{98350}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2018064}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2018063}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{251709}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{154966}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{691882}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2033803}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2006546}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2006545}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{2006709}';",
      "UPDATE ncbi_nodes SET cal_division_id = 18 WHERE ids @> '{1993908}';",
      'UPDATE ncbi_nodes SET cal_division_id = NULL WHERE taxon_id = 33154;',
      'UPDATE ncbi_nodes SET cal_division_id = NULL WHERE taxon_id = 42461;',
      'UPDATE ncbi_nodes SET cal_division_id = NULL WHERE taxon_id = 1001604;'
    ]

    queries.each do |sql|
      conn.exec_query(sql)
    end
  end

  task fix_environmental_samples_divisions: :environment do
    sql = <<-SQL
      UPDATE ncbi_nodes SET cal_division_id = subquery.division_id
      FROM (
        SELECT cal_division_id, division_id, ncbi_nodes.taxon_id
        FROM ncbi_nodes
        JOIN ncbi_divisions ON
          ncbi_divisions.id = ncbi_nodes.division_id
        WHERE division_id != cal_division_id
        AND ncbi_divisions.name = 'Environmental samples'
      ) AS subquery
      WHERE ncbi_nodes.taxon_id = subquery.taxon_id;
    SQL

    conn.exec_query(sql)
  end

  task add_ruggiero_taxa_to_ncbi_order: :environment do
    CombineTaxon.where(taxon_rank: 'order', source: 'paper')
                .each do |taxon|
      puts '.'

      NcbiNode.where('kingdom_r IS NULL')
              .where("hierarchy_names ->> 'order' = ?", taxon.order)
              .where("hierarchy_names ->> 'class' = ?", taxon.class_name)
              .where("hierarchy_names ->> 'phylum' = ?", taxon.phylum)
              .in_batches do |taxa|
                puts taxa.first.taxon_id

                taxa.update(kingdom_r: taxon.kingdom,
                            phylum_r: taxon.phylum,
                            class_r: taxon.class_name,
                            order_r: taxon.order)
              end
    end
  end

  # rubocop:disable Metrics/LineLength
  task update_cal_divisions: :environment do
    plant_id = NcbiDivision.find_by(name: 'Plantae').id
    fungi_id = NcbiDivision.find_by(name: 'Fungi').id
    animal_id = NcbiDivision.find_by(name: 'Animalia').id
    archaea_id = NcbiDivision.find_by(name: 'Archaea').id
    protozoa_id = NcbiDivision.find_by(name: 'Protozoa').id
    chromista_id = NcbiDivision.find_by(name: 'Chromista').id

    ruggeiro_queries = [
      {
        name: 'Viridiplantae',
        id: plant_id,
        where_sql: <<-SQL
        hierarchy_names @> '{"kingdom": "Viridiplantae"}'
        SQL
      },
      {
        name: 'Rhodophyta',
        id: plant_id,
        where_sql: <<-SQL
        hierarchy_names @> '{"phylum": "Rhodophyta"}'
        SQL
      },
      {
        name: 'Fungi',
        id: fungi_id,
        where_sql: <<-SQL
        hierarchy_names @> '{"kingdom": "Fungi"}'
        SQL
      },
      {
        name: 'Metazoa',
        id: animal_id,
        where_sql: <<-SQL
        hierarchy_names @> '{"kingdom": "Metazoa"}'
        SQL
      },
      {
        name: 'Archaea',
        id: archaea_id,
        where_sql: <<-SQL
        hierarchy_names @> '{"superkingdom": "Archaea"}'
        SQL
      },
      {
        name: 'Eukaryota|Sar|Rhizaria',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{463147}'
        SQL
      },
      {
        name: 'Eukaryota|Sar|Stramenopiles',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{15789}'
        SQL
      },
      {
        name: 'Eukaryota|Sar|Alveolata',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{15785}'
        SQL
      },
      {
        name: 'Eukaryota|Haptista',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{2159448}'
        SQL
      },
      {
        name: 'Eukaryota|Cryptophyceae',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{2387}'
        SQL
      },
      {
        name: 'Eukaryota|Eukaryota incertae sedis|Picozoa|Picomonadea',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{1038777}'
        SQL
      },
      {
        name: 'Eukaryota|Eukaryota incertae sedis|Telonemida',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{499560}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Rotosphaerida',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{2221084}'
        SQL
      },
      {
        name: 'Eukaryota|Amoebozoa',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{472800}'
        SQL
      },
      {
        name: 'Eukaryota|Metamonada',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{2161748}'
        SQL
      },
      {
        name: 'Eukaryota|Discoba',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{2161759}'
        SQL
      },
      {
        name: 'Eukaryota|Breviatea',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{1115555}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Aphelida|Aphelidea',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{1202362}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Filasterea',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{2222232}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Ichthyosporea',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{97722}'
        SQL
      },
      {
        name: 'Eukaryota|CRuMs|Rigifilida',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{970236}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Choanoflagellata',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{11852}'
        SQL
      }
    ]

    more_queries = [
      {
        name: 'Eukaryota|Ancyromonadida',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{2221087}'
        SQL
      },
      {
        name: 'Eukaryota|Apusozoa|Apusomonadidae',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{137631}'
        SQL
      },
      {
        name: 'Eukaryota|Opisthokonta|Opisthokonta incertae sedis|Corallochytrium',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{72059}'
        SQL
      },
      {
        name: 'Eukaryota|Malawimonadidae',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{105023}'
        SQL
      },
      {
        name: 'Eukaryota|Hemimastigophora|Spironemidae',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{1668079}'
        SQL
      },

      {
        name: 'Eukaryota|Glaucocystophyceae|Gloeochaetales|Gloeochaetaceae',
        id: plant_id,
        where_sql: <<-SQL
        ids @> '{19596}'
        SQL
      },
      {
        name: 'Eukaryota|Eukaryota incertae sedis|Picozoa',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{355817}'
        SQL
      },
      {
        name: 'Eukaryota|Eukaryota incertae sedis|Palpitomonas',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{608070}'
        SQL
      },
      {
        name: 'Eukaryota|Eukaryota incertae sedis|Microheliella',
        id: chromista_id,
        where_sql: <<-SQL
        ids @> '{893419}'
        SQL
      },
      {
        name: 'Eukaryota|CRuMs|Mantamonadidae',
        id: protozoa_id,
        where_sql: <<-SQL
        ids @> '{971251}'
        SQL
      },
      {
        name: 'Eukaryota|CRuMs|Collodictyonidae|Diphylleia',
        id: plant_id,
        where_sql: <<-SQL
        ids @> '{141694}'
        SQL
      }
    ]

    all_queries = []

    #  environmental samples
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 11 WHERE division_id = 11 AND cal_division_id IS NULL;'

    # Bacteria
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 0 WHERE division_id = 0 AND cal_division_id IS NULL;'

    # Viruses
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 9 WHERE division_id = 3 AND cal_division_id IS NULL;'
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 9 WHERE division_id = 9 AND cal_division_id IS NULL;'

    # misc
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 7 WHERE division_id = 7 AND cal_division_id IS NULL;'
    all_queries << 'UPDATE ncbi_nodes SET cal_division_id = 8 WHERE division_id = 8 AND cal_division_id IS NULL;'

    ruggeiro_queries.each do |q|
      all_queries << "UPDATE ncbi_nodes SET cal_division_id = #{q[:id]} WHERE #{q[:where_sql]} AND cal_division_id IS NULL;"
    end

    more_queries.each do |q|
      all_queries << "UPDATE ncbi_nodes SET cal_division_id = #{q[:id]} WHERE #{q[:where_sql]} AND cal_division_id IS NULL;"
    end

    all_queries.each do |q|
      puts q
      conn.execute(q)
    end
  end
  # rubocop:enable Metrics/LineLength

  task add_blast_to_common_names: :environment do
    sql = <<~SQL
      UPDATE ncbi_nodes SET common_names =
      coalesce(foo.name || '|' || common_names, common_names)
      FROM (
        SELECT name , taxon_id
        FROM  ncbi_names
        WHERE ncbi_names.name_class = 'blast name'
      ) AS foo
      WHERE ncbi_nodes.ncbi_id = foo.taxon_id;
    SQL

    conn.exec_query(sql)
  end

  def conn
    ActiveRecord::Base.connection
  end
end
