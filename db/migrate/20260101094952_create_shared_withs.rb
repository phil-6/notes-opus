class CreateSharedWiths < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_withs do |t|
      t.references :note, null: false, foreign_key: true
      t.references :shared_with_user, null: false, foreign_key: { to_table: :users }
      t.boolean :can_edit, default: false, null: false

      t.timestamps
    end

    add_index :shared_withs, [ :note_id, :shared_with_user_id ], unique: true
  end
end
