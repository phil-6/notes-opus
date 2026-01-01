class AddChangeTrackingToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :change_type, :string
    add_column :versions, :previous_title, :string
    add_column :versions, :previous_content, :text
    add_column :versions, :previous_color, :string
  end
end
