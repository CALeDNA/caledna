class CreateNcbiCitationsNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :ncbi_citation_nodes do |t|
      t.references :ncbi_citation
      t.references :ncbi_node

      t.timestamps
    end
  end
end
