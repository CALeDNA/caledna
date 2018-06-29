class AddSampleIdToAsvs < ActiveRecord::Migration[5.2]
  def up
    add_reference :asvs, :sample, type: :integer, index: true

    # Asv.find_each do |asv|
    #   asv.update(sample_id: asv.extraction.sample.id)
    # end
  end

  def down
    remove_reference :asvs, :sample
  end
end
