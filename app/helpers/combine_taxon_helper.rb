# frozen_string_literal: true

module CombineTaxonHelper
  def self.taxon_string(taxon)
    [
      taxon['superkingdom'], taxon['kingdom'], taxon['phylum'],
      taxon['class_name'], taxon['order'],
      taxon['family'], taxon['genus'], taxon['species']
    ].compact.join(', ')
  end

  def self.convert_taxa_string(string)
    taxa_array = convert_raw_combine_taxon(string)
    taxa_array.map do |taxon|
      parts = taxon.split('|')
      {
        id: parts.first,
        taxonomy_string: parts.drop(1).join(', ').gsub(/^--, /, '')
      }
    end
  end

  def self.convert_raw_combine_taxon(string)
    return [] if string.blank?
    string.delete('{"').delete('{').delete('"}').delete('}').split(',')
  end

  def self.convert_taxa_ids(string)
    taxa_array = convert_raw_combine_taxon(string)
    taxa_array.map do |taxon|
      taxon.split('|').first
    end.join('|')
  end

  def self.vernaculars(taxon)
    ncbi = taxon['ncbi_taxa']
    return if ncbi.blank?

    taxa_array =
      ncbi.delete('{"').delete('{').delete('"}').delete('}').split('|')

    id = taxa_array.first
    names = NcbiNodePillarPoint.find(id).common_names
    names.present? ? "(#{names.split('|').join(', ')})" : ''
  end

  # rubocop:disable Metrics/MethodLength
  def self.target_taxon(taxon)
    if taxon['species']
      taxon['species']
    elsif taxon['genus']
      taxon['genus']
    elsif taxon['family']
      taxon['family']
    elsif taxon['order']
      taxon['order']
    elsif taxon['class_name']
      taxon['class_name']
    else
      taxon['phylum']
    end
  end
  # rubocop:enable Metrics/MethodLength
end
