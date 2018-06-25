class ChangePagePublished < ActiveRecord::Migration[5.2]
  def change
    # TODO: fix this migration; can't push to heroku
    # because published is being used before migration is made

    rename_column :pages, :draft, :published
    Page.all.each do |page|
      page.update(published: !page.published)
    end
  end
end
