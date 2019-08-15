class AddWebsiteToPages < ActiveRecord::Migration[5.2]
  def change
    add_reference :pages, :website
  end
end
