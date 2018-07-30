# frozen_string_literal: true

class Wikidata
  require 'sparql/client'

  attr_reader :taxon_id, :external_resource

  URL = 'https://query.wikidata.org/sparql'

  def initialize(taxon_id, external_resource)
    @taxon_id = taxon_id
    @external_resource = external_resource
  end

  def wikidata_image
    image = external_resource&.wikidata_image
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: 'commons.wikimedia.org',
      source: 'wikimedia',
      taxa_url: image
    )
  end

  def bold_link
    id = external_resource&.bold_id
    return if id.blank?
    url = 'http://www.boldsystems.org/index.php/TaxBrowser_TaxonPage?taxid='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Barcode of Life Data System (BOLD)'
    )
  end

  def calflora_link
    id = external_resource&.calflora_id
    return if id.blank?
    url = 'http://www.calflora.org/cgi-bin/species_query.cgi?where-calrecnum='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Calflora'
    )
  end

  def cites_link
    id = external_resource&.cites_id
    return if id.blank?
    url = 'http://speciesplus.net/#/taxon_concepts/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}/legal",
      text: 'CITES Species+'
    )
  end

  def cnps_link
    id = external_resource&.cnps_id
    return if id.blank?
    url = 'http://www.rareplants.cnps.org/detail/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}.html",
      text: 'California Native Plant Society (CNPS)'
    )
  end

  def eol_link
    id = external_resource&.eol_id
    return if id.blank?
    url = 'http://eol.org/pages/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Encyclopedia of Life (EOL)'
    )
  end

  def gbif_link
    id = external_resource&.gbif_id
    return if id.blank?
    url = 'https://www.gbif.org/species/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Global Biodiversity Information Facility (GBIF)'
    )
  end

  def inaturalist_link
    id = external_resource&.inaturalist_id
    return if id.blank?
    url = 'https://www.inaturalist.org/taxa/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'iNaturalist'
    )
  end

  def itis_link
    id = external_resource&.itis_id
    return if id.blank?
    url = 'https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Integrated Taxonomic Information System (ITIS)'
    )
  end

  def iucn_link
    id = external_resource&.iucn_id
    return if id.blank?

    url = 'http://www.iucnredlist.org/details/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}/0",
      text: 'International Union for Conservation of Nature (IUCN)'
    )
  end

  def msw_link
    id = external_resource&.msw_id
    return if id.blank?
    url = 'http://www.departments.bucknell.edu/biology/resources/msw3/browse.asp?s=y&id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Mammal Species of the World (MSW)'
    )
  end

  def ncbi_link
    id = external_resource&.ncbi_id || taxon_id
    return if id.blank?
    url = 'https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'National Center for Biotechnology Information (NCBI)'
    )
  end

  def wikidata_entity
    external_resource&.wikidata_entity
  end

  def wikidata_link
    id = external_resource&.wikidata_entity
    return if id.blank?
    url = 'https://www.wikidata.org/wiki/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Wikidata'
    )
  end

  def wikipedia_link; end

  def worms_link
    id = external_resource&.worms_id
    return if id.blank?
    url = 'http://www.marinespecies.org/aphia.php?p=taxdetails&id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'World Register of Marine Species (WoRMS)'
    )
  end

  private

  def client
    @client ||= SPARQL::Client.new(URL, method: :get)
  end

  # rubocop:disable Metrics/MethodLength
  def query
    parts = <<-'SPARQL'.chop
      SELECT ?item ?Global_Biodiversity_Information_Facility_ID ?IUCN_taxon_ID
      ?Encyclopedia_of_Life_ID ?ITIS_TSN ?BioLib_ID ?iNaturalist_taxon_ID
      ?WoRMS_ID ?NCBI_Taxonomy_ID ?taxon_range_map_image
      ?temporal_range_start ?temporal_range_startLabel ?temporal_range_end
      ?temporal_range_endLabel ?endemic_to ?endemic_toLabel ?ADW_taxon_ID
      ?ARKive_ID ?MSW_ID ?CITES_Species__ID ?IUCN_conservation_status
      ?IUCN_conservation_statusLabel ?BHL_Page_ID ?FishBase_species_ID
      ?IPNI_plant_ID ?MycoBank_taxon_name_ID ?PlantList_ID
      ?Plants_of_the_World_online_ID ?ICTV_virus_genome_composition
      ?ICTV_virus_genome_compositionLabel ?AlgaeBase_URL
      ?IRMNG_taxon_ID ?uBio_ID ?Index_Fungorum_ID
      ?Flora_of_North_America_taxon_ID ?Flora_of_China_ID ?FloraBase_ID
      ?GRIN_URL ?BOLD_Systems_taxon_ID ?CNPS_ID ?image
      WHERE {
        ?item wdt:P685 ?ncbi_id.
    SPARQL

    parts += "FILTER(?ncbi_id = '#{ncbi_taxon_id}')."

    parts += <<-'SPARQL'.chop
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
      OPTIONAL { ?item wdt:P4024 ?ADW_taxon_ID. }
      OPTIONAL { ?item wdt:P1348 ?AlgaeBase_URL. }
      OPTIONAL { ?item wdt:P2833 ?ARKive_ID. }
      OPTIONAL { ?item wdt:P687 ?BHL_Page_ID. }
      OPTIONAL { ?item wdt:P838 ?BioLib_ID. }
      OPTIONAL { ?item wdt:P3606 ?BOLD_Systems_taxon_ID. }
      OPTIONAL { ?item wdt:P3420 ?Calflora_ID. }
      OPTIONAL { ?item wdt:P2040 ?CITES_Species__ID. }
      OPTIONAL { ?item wdt:P4194 ?CNPS_ID. }
      OPTIONAL { ?item wdt:P830 ?Encyclopedia_of_Life_ID. }
      OPTIONAL { ?item wdt:P938 ?FishBase_species_ID. }
      OPTIONAL { ?item wdt:P1747 ?Flora_of_China_ID. }
      OPTIONAL { ?item wdt:P1727 ?Flora_of_North_America_taxon_ID. }
      OPTIONAL { ?item wdt:P3101 ?FloraBase_ID. }
      OPTIONAL { ?item wdt:P846 ?Global_Biodiversity_Information_Facility_ID. }
      OPTIONAL { ?item wdt:P1421 ?GRIN_URL. }
      OPTIONAL { ?item wdt:P1832 ?GrassBase_ID. }
      OPTIONAL { ?item wdt:P1391 ?Index_Fungorum_ID. }
      OPTIONAL { ?item wdt:P3151 ?iNaturalist_taxon_ID. }
      OPTIONAL { ?item wdt:P1076 ?ICTV_virus_ID. }
      OPTIONAL { ?item wdt:P961 ?IPNI_plant_ID. }
      OPTIONAL { ?item wdt:P815 ?ITIS_TSN. }
      OPTIONAL { ?item wdt:P627 ?IUCN_taxon_ID. }
      OPTIONAL { ?item wdt:P959 ?MSW_ID. }
      OPTIONAL { ?item wdt:P962 ?MycoBank_taxon_name_ID. }
      OPTIONAL { ?item wdt:P1070 ?PlantList_ID. }
      OPTIONAL { ?item wdt:P685 ?NCBI_Taxonomy_ID. }
      OPTIONAL { ?item wdt:P850 ?WoRMS_ID. }

      OPTIONAL { ?item wdt:P181 ?taxon_range_map_image. }
      OPTIONAL { ?item wdt:P523 ?temporal_range_start. }
      OPTIONAL { ?item wdt:P524 ?temporal_range_end. }
      OPTIONAL { ?item wdt:P183 ?endemic_to. }
      OPTIONAL { ?item wdt:P141 ?IUCN_conservation_status. }
      OPTIONAL { ?item wdt:P18 ?image. }
      }
    SPARQL

    parts
  end
  # rubocop:enable Metrics/MethodLength

  def results
    @results ||= client.query(query)[0]
  end

  def adw_link
    id = results['ADW_taxon_ID']
    return if id.blank?
    url = 'http://animaldiversity.org/accounts/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Animal Diversity Web (ADW)'
    )
  end

  def algaebase_link
    id = results['AlgaeBase_URL']
    return if id.blank?
    url = 'http://www.algaebase.org/search/genus/detail/?genus_id='
    # url2 = 'http://www.algaebase.org/search/species/detail/?species_id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'AlgaeBase'
    )
  end

  def arkive_link
    id = results['ARKive_ID']
    return if id.blank?
    url = 'http://www.arkive.org/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'ARKive'
    )
  end

  def bhl_link
    id = results['BHL_Page_ID']
    return if id.blank?
    url = 'http://biodiversitylibrary.org/page/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Biodiversity Heritage Library (BHL)'
    )
  end

  def biolib_link
    id = results['BioLib_ID']
    return if id.blank?
    url = 'http://www.biolib.cz/en/taxon/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'BioLib'
    )
  end

  def fishbase_link
    id = results['FishBase_species_ID']
    return if id.blank?
    url = 'http://www.fishbase.org/Summary/speciesSummary.php?id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'FishBase'
    )
  end

  def flora_link
    id = results['Flora_of_China_ID']
    return if id.blank?
    url = 'http://www.efloras.org/florataxon.aspx?flora_id=2&taxon_id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Flora of China'
    )
  end

  def flora_north_america_link
    id = results['Flora_of_North_America_taxon_ID']
    return if id.blank?
    url = 'http://www.efloras.org/florataxon.aspx?flora_id=1&taxon_id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Flora of North America'
    )
  end

  def florabase_link
    id = results['FloraBase_ID']
    return if id.blank?
    url = 'http://florabase.dec.wa.gov.au/browse/profile/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'FloraBase Australia'
    )
  end

  def grassbase_link
    id = results['GrassBase_ID']
    return if id.blank?
    url = 'http://www.kew.org/data/grasses-db/www/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}htm",
      text: ' GrassBase'
    )
  end

  def grin_link
    id = results['GRIN_URL']
    return if id.blank?
    url = 'https://npgsweb.ars-grin.gov/gringlobal/accessiondetail.aspx?'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: ' Germplasm Resources Information Network (GRIN)'
    )
  end

  def ictv_link
    id = results['ICTV_virus_ID']
    return if id.blank?
    url = 'http://ictvdb.bio-mirror.cn/ICTVdB/'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}htm",
      text: 'International Committee on Taxonomy of Viruses (ICTV)'
    )
  end

  def fungorum_link
    id = results['Index_Fungorum_ID']
    return if id.blank?
    url = 'http://www.indexfungorum.org/names/NamesRecord.asp?RecordID='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'Fungorum'
    )
  end

  def ipni_link
    id = results['IPNI_plant_ID']
    return if id.blank?
    url = 'http://www.ipni.org/ipni/idPlantNameSearch.do?id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'International Plant Names Index (IPNI)'
    )
  end

  def mycobank_link
    id = results['MycoBank_taxon_name_ID']
    return if id.blank?
    url = 'http://www.mycobank.org/Biolomics.aspx?Table=Mycobank&MycoBankNr_='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'MycoBank'
    )
  end

  def plantlist_link
    id = results['PlantList_ID']
    return if id.blank?
    url = 'http://www.theplantlist.org/tpl1.1/record/kew-8323'
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}",
      text: 'PlantList'
    )
  end
end
