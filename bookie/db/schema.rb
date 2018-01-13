# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150417182154) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.integer  "page"
    t.integer  "par"
    t.integer  "pos"
    t.integer  "forward"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["user_id", "book_id"], name: "index_bookmarks_on_user_id_and_book_id"

  create_table "books", force: true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "description"
    t.integer  "depth"
    t.string   "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "book_id"
    t.string  "status"
  end

  add_index "books_users", ["book_id"], name: "index_books_users_on_book_id"
  add_index "books_users", ["user_id"], name: "index_books_users_on_user_id"

  create_table "pages", force: true do |t|
    t.integer  "number"
    t.text     "text"
    t.integer  "book_id"
    t.string   "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["book_id"], name: "index_pages_on_book_id"

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email",            null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
