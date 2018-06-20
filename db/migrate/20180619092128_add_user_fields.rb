class AddUserFields < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :name, :string
    add_column :users, :location, :string
    add_column :users, :age, :integer
    add_column :users, :gender_cd, :string
    add_column :users, :education_cd, :string
    add_column :users, :ethnicity, :string
    add_column :users, :conservation_experience, :boolean
    add_column :users, :dna_experience, :boolean
    add_column :users, :work_info, :text
    add_column :users, :time_outdoors_cd, :string
    add_column :users, :occupation, :string
    add_column :users, :science_career_goals, :text
    add_column :users, :environmental_career_goals, :text
    add_column :users, :uc_affiliation, :boolean
    add_column :users, :uc_campus, :string
    add_column :users, :caledna_source, :string
    add_column :users, :agree, :boolean, null: false

    add_index :users, :username, unique: true
  end
end
