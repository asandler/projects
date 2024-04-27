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

ActiveRecord::Schema[7.0].define(version: 2024_04_18_172757) do
  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.text "data"
    t.integer "user_id"
    t.integer "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_documents_on_folder_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "folders", force: :cascade do |t|
    t.integer "parent_folder_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_folder_id"], name: "index_folders_on_parent_folder_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "root_directory_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "documents", "folders"
  add_foreign_key "documents", "users"
  add_foreign_key "folders", "folders", column: "parent_folder_id"
end
