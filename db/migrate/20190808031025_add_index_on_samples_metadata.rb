class AddIndexOnSamplesMetadata < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE INDEX ON samples USING gin (metadata);'

  end
end
