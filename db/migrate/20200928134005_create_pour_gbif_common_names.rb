class CreatePourGbifCommonNames < ActiveRecord::Migration[5.2]
  def up
    create_table 'pour.gbif_common_names' do |t|
      t.bigint :taxon_id, index: true
      t.string :vernacular_name
      t.string :language
    end

    execute 'CREATE INDEX vernacular_name_prefix ON pour.gbif_common_names USING btree ( lower ("vernacular_name") text_pattern_ops);'
  end

  def down
    drop_table 'pour.gbif_common_names'
  end
end


