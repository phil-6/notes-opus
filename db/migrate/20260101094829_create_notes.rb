class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :color, default: "gray"
      t.boolean :pinned, default: false, null: false
      t.integer :position, default: 0, null: false
      t.datetime :locked_at
      t.references :locked_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :notes, :pinned
    add_index :notes, :position
  end
end
