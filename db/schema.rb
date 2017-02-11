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

ActiveRecord::Schema.define(version: 20170209211351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string   "key"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["key"], name: "index_api_keys_on_key", using: :btree
  end

  create_table "authors", force: :cascade do |t|
    t.string   "given_name"
    t.string   "family_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.text     "subtitle"
    t.string   "isbn_10"
    t.string   "isbn_13"
    t.text     "description"
    t.date     "released_on"
    t.integer  "publisher_id"
    t.integer  "author_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "cover"
    t.index ["author_id"], name: "index_books_on_author_id", using: :btree
    t.index ["isbn_10"], name: "index_books_on_isbn_10", using: :btree
    t.index ["isbn_13"], name: "index_books_on_isbn_13", using: :btree
    t.index ["publisher_id"], name: "index_books_on_publisher_id", using: :btree
    t.index ["title"], name: "index_books_on_title", using: :btree
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.string   "searchable_type"
    t.integer  "searchable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree
  end

  create_table "publishers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                   null: false
    t.string   "password_digest",                         null: false
    t.string   "given_name"
    t.string   "family_name"
    t.datetime "last_logged_in_at"
    t.string   "confirmation_token"
    t.text     "confirmation_redirect_url"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.text     "reset_password_redirect_url"
    t.datetime "reset_password_sent_at"
    t.integer  "role",                        default: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", using: :btree
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
  end

  add_foreign_key "books", "authors"
  add_foreign_key "books", "publishers"
end
