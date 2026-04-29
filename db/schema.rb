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

ActiveRecord::Schema[7.1].define(version: 2026_04_29_133222) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "account_type", null: false
    t.integer "balance", default: 0, null: false
    t.string "currency", limit: 3, default: "BRL", null: false
    t.boolean "is_active", default: true, null: false
    t.string "color", limit: 7
    t.string "icon", limit: 30
    t.string "description", limit: 500
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "user_id"], name: "index_accounts_on_name_and_user_id", unique: true
    t.index ["user_id", "account_type"], name: "index_accounts_on_user_id_and_account_type"
    t.index ["user_id", "currency", "is_active"], name: "index_accounts_on_user_id_and_currency_and_is_active"
    t.index ["user_id", "is_active"], name: "index_accounts_on_user_id_and_is_active"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "color", limit: 7, default: "#3B82F6", null: false
    t.string "icon", limit: 30, default: "tag", null: false
    t.boolean "is_active", default: true, null: false
    t.integer "category_type", default: 1, null: false
    t.string "description", limit: 255
    t.integer "position", default: 0, null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "user_id", "category_type"], name: "index_categories_on_name_and_user_id_and_category_type", unique: true
    t.index ["user_id", "category_type", "is_active"], name: "index_categories_on_user_id_and_category_type_and_is_active"
    t.index ["user_id", "position"], name: "index_categories_on_user_id_and_position"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.integer "year", null: false
    t.integer "month", null: false
    t.integer "day", null: false
    t.string "transaction_type", null: false
    t.string "status", default: "COMPLETED", null: false
    t.string "description", limit: 255, null: false
    t.uuid "account_id", null: false
    t.uuid "user_id", null: false
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "transaction_type", "year", "month"], name: "idx_on_account_id_transaction_type_year_month_0f591f7b54"
    t.index ["account_id", "year", "month"], name: "index_transactions_on_account_id_and_year_and_month"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["user_id", "category_id", "year", "month"], name: "idx_on_user_id_category_id_year_month_ddcd9d41cf"
    t.index ["user_id", "year", "month", "day"], name: "index_transactions_on_user_id_and_year_and_month_and_day"
    t.index ["user_id", "year", "month"], name: "index_transactions_on_user_id_and_year_and_month"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_user_sessions_on_expires_at"
    t.index ["revoked_at"], name: "index_user_sessions_on_revoked_at"
    t.index ["token_digest"], name: "index_user_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "email", limit: 120, null: false
    t.string "password_digest", limit: 255, null: false
    t.datetime "last_login"
    t.boolean "is_active", default: true, null: false
    t.boolean "show_values", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at", "is_active"], name: "index_users_on_created_at_and_is_active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_login"], name: "index_users_on_last_login"
  end

  add_foreign_key "accounts", "users", on_delete: :cascade
  add_foreign_key "categories", "users", on_delete: :cascade
  add_foreign_key "transactions", "accounts", on_delete: :cascade
  add_foreign_key "transactions", "categories", on_delete: :cascade
  add_foreign_key "transactions", "users", on_delete: :cascade
  add_foreign_key "user_sessions", "users", on_delete: :cascade
end
