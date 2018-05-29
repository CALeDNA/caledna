class DropNcbiCitations < ActiveRecord::Migration[5.0]
  def change
    drop_table :ncbi_citations do |t|
    end

    drop_table :ncbi_citation_nodes do |t|
    end
  end
end
