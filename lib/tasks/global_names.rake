# frozen_string_literal: true

namespace :global_names do
  task create_external_resources_for_gbif_taxa: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new
    conn = ActiveRecord::Base.connection

    sql = <<-SQL
    SELECT taxonkey, scientificname
    FROM pillar_point.gbif_occ_taxa
    LEFT JOIN external_resources
    ON pillar_point.gbif_occ_taxa.taxonkey = external_resources.gbif_id
    WHERE gbif_id IS NULL;
    SQL

    records = conn.exec_query(sql).to_a

    records.each do |record|
      puts record['taxonkey']

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['scientificname'], source_ids)

      create_external_resource(results: results, taxon_id: record['taxonkey'],
                               id_name: 'gbif_id')
    end
  end

  task create_external_resource2: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new

    # taxa = %w[Dothideomycetes Maxillopoda]
    # taxa = %w[Hydrophilidae Mycosphaerellaceae Cercyon]
    # taxa = %w[
    #   Hesperonoe
    #   Paratrytone
    #   Idarcturus
    #   Integripelta
    #   Rexithaerus
    #   Glans
    #   Platyodon
    #   Chaceia
    #   Zirfaea
    #   Hespererato
    #   Hainotis
    #   Ophiodermella
    #   Granulina
    #   Atrimitra
    #   Orienthella
    #   Leostyletus
    #   Flabellinopsis
    #   Catriona
    #   Cornu
    #   Neostylidium
    #   Kaburakia
    #   Cylindrocarpus
    #   Stephanocystis
    # ]

    taxa = ['Fratercula cirrhata']

    taxa.each do |record|
      puts record

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['scientificname'], source_ids)

      create_external_resource(results: results, taxon_id: nil,
                               id_name: nil)
    end
  end

  task create_external_resources: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new

    records1 = PpGbifOccTaxa.where("genus in ('Hesperonoe',
    'Paratrytone',
    'Idarcturus',
    'Integripelta',
    'Rexithaerus',
    'Glans',
    'Platyodon',
    'Chaceia',
    'Zirfaea',
    'Hespererato',
    'Hainotis',
    'Ophiodermella',
    'Granulina',
    'Atrimitra',
    'Orienthella',
    'Leostyletus',
    'Flabellinopsis',
    'Catriona',
    'Cornu',
    'Neostylidium',
    'Kaburakia',
    'Cylindrocarpus',
    'Stephanocystis') ")

    records1.each do |record|
      puts record['taxonkey']

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['scientificname'], source_ids)

      create_external_resource(results: results, taxon_id: record['taxonkey'],
                               id_name: 'gbif_id')
    end
  end

  task create_external_resources3: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new

    records = NcbiNode.where("lower(canonical_name) in (
      'alaus melanops',
      'amaeana occidentalis',
      'amanita cf. ravenelli',
      'amphicaryon ernesti',
      'amyna stellata',
      'anticlea switzeraria',
      'autochton neis',
      'bassaniana',
      'capulus sp.',
      'casmaria boblehmani',
      'chrysomya sp.',
      'clymenella californica',
      'colaconema sp. 1bc',
      'colaconema sp. 1bc',
      'conus sp.',
      'corallinac sp. 4bccrust',
      'corallinac',
      'cyclopoida_family_incertae_sedis',
      'cyclopoidgen sp.5 chu',
      'cyclopoidgen',
      'dasysiphonia japonica',
      'desmacella cf. annexa belum',
      'euclymene lombricoides',
      'euphilomedes carcharodonta',
      'eurystomina ophthalmophora',
      'euxoa oncocnemoides',
      'glossodrilus sp4',
      'grateloupia gardneri',
      'haimbachia arizonensis',
      'haplodrassus bicornis',
      'heterokontophyta',
      'kaliella dendrophila',
      'kaliella',
      'limatula sp. 3',
      'limoniscus violaceus',
      'lumbrineris luti',
      'mazzaella dewreedei',
      'naididae',
      'nassarius tringa',
      'orbinia johnsoni',
      'ouleus fridericus',
      'peyssonnelia crinitis',
      'peyssonnelia incudiformis',
      'peyssonneliales',
      'phytophthora sp. novaeguinea',
      'phytophthora',
      'plocamium sp. 1mertensiisa',
      'polychaeta_incertae_sedis',
      'pseudosteineria',
      'ptomaphagus amamianus',
      'pythium sp. nov.',
      'pythium sp. nov',
      'rhacognathus americanus',
      'rhodymenia rhizoides',
      'rosacea sp.',
      'scolelepis maculata',
      'scopula ef03',
      'stylarioides',
      'symphyocladia tanakae',
      'sympistis subsimplex',
      'tethya sp.',
      'thecophora longicornis',
      'vertebrata woodii'
      )")

    records.each do |record|
      puts record.taxon_id

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record.canonical_name, source_ids)

      create_external_resource(results: results, taxon_id: nil,
                               id_name: nil)
    end
  end

  task create_external_resource_for_globi: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new
    conn = ActiveRecord::Base.connection

    project = ResearchProject.find_by(name: 'Pillar Point')

    sql = <<-SQL
    SELECT taxon_name,
      research_project_sources.metadata ->> 'inat_id' as inat_id
    FROM external.globi_requests
    JOIN research_project_sources
    ON research_project_sources.sourceable_id = external.globi_requests.id
    LEFT JOIN external_resources
      ON external_resources.inaturalist_id = (research_project_sources.metadata ->> 'inat_id')::integer
      AND external_resources.source = 'globalnames',
    WHERE research_project_id = #{project.id}
    AND sourceable_type = 'GlobiRequest',
    AND gbif_id IS NULL
    SQL

    records = conn.exec_query(sql).to_a

    records.each do |record|
      puts record['taxon_name']

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['taxon_name'], source_ids)

      create_external_resource(
        results: results, taxon_id: record['inat_id'],
        id_name: 'inaturalist_id'
      )
    end
  end
end
