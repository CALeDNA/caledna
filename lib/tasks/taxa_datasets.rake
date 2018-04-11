# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :taxa_datasets do
  desc 'import dataset info from gbif'

  task import: :environment do
    gbif_import = GbifImport.new

    Taxon.select(:datasetID).distinct.where.not(datasetID: nil).each do |taxon|
      puts "import taxon #{taxon.datasetID}"
      record = gbif_import.gbif_record(taxon.datasetID)
      TaxaDataset.create(
        datasetID: taxon.datasetID,
        citation: record['citation']['text'],
        name: record['title']
      )
    end
  end

  task import_eol_ncbi: :environment do
    # rubocop:disable Metrics/LineLength
    datasets = [
      {
        name: 'Encyclopedia of Life',
        datasetID: 'e632b198-5b2f-47ee-b7a6-6531ea435fa3',
        citation: 'Encyclopedia of Life (EOL). Encyclopedia of Life. Checklist Dataset https://doi.org/10.15468/sxtqyz accessed via GBIF.org on 2018-04-03.'
      },
      {
        name: 'NCBI',
        datasetID: 'fab88965-e69d-4491-a04d-e3198b626e52',
        citation: 'National Center for Biotechnology Information (NCBI). NCBI Taxonomy. Checklist Dataset https://doi.org/10.15468/rhydar accessed via GBIF.org on 2018-04-03.'
      }
    ]
    # rubocop:enable Metrics/LineLength

    TaxaDataset.create(datasets)
  end
end
# rubocop:enable Metrics/BlockLength

class GbifImport
  def gbif_api
    @gbif_api ||= GbifApi.new
  end

  def gbif_record(id)
    results = gbif_api.datasets(id)
    JSON.parse(results.body)
  end
end
