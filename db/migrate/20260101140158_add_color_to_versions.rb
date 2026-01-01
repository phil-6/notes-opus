class AddColorToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :color, :string
  end
end
