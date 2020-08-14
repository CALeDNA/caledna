class CreateResearchPages < ActiveRecord::Migration[5.2]
  def up
    create_table :research_project_pages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, default: false, null: false
      t.string :slug, index: true
      t.integer :display_order
      t.references :research_project
      t.string :menu_text
      t.boolean :show_map
      t.boolean :show_edna_results_metadata

      t.timestamps
    end

    fields = %w[title body published slug display_order research_project_id
      menu_text show_map show_edna_results_metadata created_at updated_at].join(',')

    execute "INSERT INTO research_project_pages(#{fields}) " \
      "SELECT #{fields} FROM pages WHERE research_project_id IS NOT NULL;"
  end

  def down
    drop_table :research_project_pages
  end
end


# 'SELECT title, body, published, slug, ' \
# 'display_order, research_project_id, menu_text, show_map, ' \
# 'show_edna_results_metadata, created_at, updated_at ' \
#  'FROM pages WHERE research_project_id IS NOT NULL;'

# t.string "title", null: false
# t.text "body", null: false
# t.boolean "published", default: false, null: false
# t.string "menu_cd"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.string "slug"
# t.integer "display_order"
# t.integer "research_project_id"
# t.string "menu_text"
# t.bigint "website_id"
# t.boolean "show_map"
# t.boolean "show_edna_results_metadata"
# t.index ["display_order"], name: "index_pages_on_display_order"
# t.index ["slug"], name: "index_pages_on_slug"
# t.index ["website_id"], name: "index_pages_on_website_id"
