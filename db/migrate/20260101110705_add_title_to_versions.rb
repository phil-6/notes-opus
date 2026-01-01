class AddTitleToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :title, :string
  end
end
