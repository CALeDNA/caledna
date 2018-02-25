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
end

class GbifImport
  def gbif_api
    @gbif_api ||= GbifApi.new
  end

  def gbif_record(id)
    results = gbif_api.datasets(id)
    JSON.parse(results.body)
  end
end
