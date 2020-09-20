# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2015_04_17_182154) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "book_id"
    t.integer "page"
    t.integer "par"
    t.integer "pos"
    t.integer "forward"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "book_id"], name: "index_bookmarks_on_user_id_and_book_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "description"
    t.integer "depth"
    t.string "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "book_id"
    t.string "status"
    t.index ["book_id"], name: "index_books_users_on_book_id"
    t.index ["user_id"], name: "index_books_users_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.integer "number"
    t.text "text"
    t.integer "book_id"
    t.string "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["book_id"], name: "index_pages_on_book_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
