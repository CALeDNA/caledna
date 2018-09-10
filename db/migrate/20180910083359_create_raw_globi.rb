class CreateRawGlobi < ActiveRecord::Migration[5.2]
  def change
    create_table 'external.globi_raw', id: false do |t|
      t.string :sourceTaxonId
      t.string :sourceTaxonIds
      t.string :sourceTaxonName
      t.string :sourceTaxonRank
      t.string :sourceTaxonPathNames
      t.string :sourceTaxonPathIds
      t.string :sourceTaxonPathRankNames
      t.string :sourceId
      t.string :sourceOccurrenceId
      t.string :sourceCatalogNumber
      t.string :sourceBasisOfRecordId
      t.string :sourceBasisOfRecordName
      t.string :sourceLifeStageId
      t.string :sourceLifeStageName
      t.string :sourceBodyPartId
      t.string :sourceBodyPartName
      t.string :sourcePhysiologicalStateId
      t.string :sourcePhysiologicalStateName
      t.string :interactionTypeName
      t.string :interactionTypeId
      t.string :targetTaxonId
      t.string :targetTaxonIds
      t.string :targetTaxonName
      t.string :targetTaxonRank
      t.string :targetTaxonPathNames
      t.string :targetTaxonPathIds
      t.string :targetTaxonPathRankNames
      t.string :targetId
      t.string :targetOccurrenceId
      t.string :targetCatalogNumber
      t.string :targetBasisOfRecordId
      t.string :targetBasisOfRecordName
      t.string :targetLifeStageId
      t.string :targetLifeStageName
      t.string :targetBodyPartId
      t.string :targetBodyPartName
      t.string :targetPhysiologicalStateId
      t.string :targetPhysiologicalStateName
      t.string :decimalLatitude
      t.string :decimalLongitude
      t.string :localityId
      t.string :localityName
      t.string :eventDateUnixEpoch
      t.string :referenceCitation
      t.string :referenceDoi
      t.string :referenceUrl
      t.string :sourceCitation
      t.string :sourceNamespace
      t.string :sourceArchiveURI
      t.string :sourceDOI
      t.string :sourceLastSeenAtUnixEpoch
    end
  end
end
