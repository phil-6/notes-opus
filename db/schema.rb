# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_01_143134) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "connections", force: :cascade do |t|
    t.integer "connected_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["connected_user_id"], name: "index_connections_on_connected_user_id"
    t.index ["user_id", "connected_user_id"], name: "index_connections_on_user_id_and_connected_user_id", unique: true
    t.index ["user_id"], name: "index_connections_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "expires_at", null: false
    t.integer "inviter_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address", "inviter_id"], name: "index_invitations_on_email_address_and_inviter_id", unique: true
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.datetime "archived_at"
    t.string "color", default: "gray"
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "locked_by_id"
    t.boolean "pinned", default: false, null: false
    t.integer "position", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["archived_at"], name: "index_notes_on_archived_at"
    t.index ["locked_by_id"], name: "index_notes_on_locked_by_id"
    t.index ["pinned"], name: "index_notes_on_pinned"
    t.index ["position"], name: "index_notes_on_position"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shared_withs", force: :cascade do |t|
    t.boolean "can_edit", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.integer "shared_with_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id", "shared_with_user_id"], name: "index_shared_withs_on_note_id_and_shared_with_user_id", unique: true
    t.index ["note_id"], name: "index_shared_withs_on_note_id"
    t.index ["shared_with_user_id"], name: "index_shared_withs_on_shared_with_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_taggings_on_note_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "dark_mode", default: false, null: false
    t.string "display_name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "change_type"
    t.string "color"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.string "previous_color"
    t.text "previous_content"
    t.string "previous_title"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_versions_on_note_id"
    t.index ["user_id"], name: "index_versions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "connections", "users"
  add_foreign_key "connections", "users", column: "connected_user_id"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "notes", "users"
  add_foreign_key "notes", "users", column: "locked_by_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "shared_withs", "notes"
  add_foreign_key "shared_withs", "users", column: "shared_with_user_id"
  add_foreign_key "taggings", "notes"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "users"
  add_foreign_key "versions", "notes"
  add_foreign_key "versions", "users"
end
