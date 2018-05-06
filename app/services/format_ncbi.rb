module FormatNcbi
  def insert_canonical_name
    NcbiNode.find_each do |node|
      name = NcbiName.find_by(taxon_id: node.id, name_class: 'scientific name')
      next if name.blank?
      node.update(canonical_name: name.name)
    end
  end
end
