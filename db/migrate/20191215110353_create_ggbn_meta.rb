class CreateGgbnMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :ggbn_meta do |t|
      # t.string :dataset_guid
      t.string :technical_contact_name
      t.string :technical_contact_email
      # t.string :technical_contact_phone
      t.string :technical_contact_address
      t.string :content_contact_name
      t.string :content_contact_email
      # t.string :content_contact_phone
      t.string :content_contact_address
      # t.string :other_provider_uddi
      t.string :dataset_title
      t.text :dataset_details
      # t.text :dataset_coverage
      # t.string :dataset_uri
      # t.string :dataset_icon_uri
      # t.string :dataset_version_major
      # t.text :dataset_creators
      # t.text :dataset_contributors
      t.string :owner_organization_name
      t.string :owner_organization_abbrev
      t.string :owner_contact_person
      # t.string :owner_contact_role
      t.string :owner_address
      # t.string :owner_telephone
      t.string :owner_email
      # t.string :owner_uri
      # t.string :owner_logo_uri
      # t.string :ipr_text
      # t.text :ipr_details
      # t.string :ipr_uri
      # t.string :copyright_text
      t.text :copyright_details
      # t.string :copyright_uri
      # t.string :terms_of_use_text
      t.text :terms_of_use_details
      # t.string :terms_of_use_uri
      # t.string :disclaimers_text
      t.text :disclaimers_details
      # t.string :disclaimers_uri
      # t.string :license_text
      t.text :licenses_details
      t.string :license_uri
      # t.string :acknowledgements_text
      t.text :acknowledgements_details
      # t.string :acknowledgements_uri
      # t.string :citations_text
      t.text :citations_details
      # t.string :citations_uri
      t.string :source_institution_id
      t.string :source_id
      t.string :record_basis
      t.string :kind_of_unit
      t.string :language
      t.string :altitude_unit_of_measurement

      t.timestamps null: false
    end
  end
end


