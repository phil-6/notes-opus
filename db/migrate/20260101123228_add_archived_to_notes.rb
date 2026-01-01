class AddArchivedToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :archived_at, :datetime
    add_index :notes, :archived_at
  end
end
