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

ActiveRecord::Schema.define(version: 20150326114342) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "advocates", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advocates", ["email"], name: "index_advocates_on_email", unique: true, using: :btree
  add_index "advocates", ["reset_password_token"], name: "index_advocates_on_reset_password_token", unique: true, using: :btree

  create_table "case_worker_claims", force: true do |t|
    t.integer  "case_worker_id"
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_worker_claims", ["case_worker_id"], name: "index_case_worker_claims_on_case_worker_id", using: :btree
  add_index "case_worker_claims", ["claim_id"], name: "index_case_worker_claims_on_claim_id", using: :btree

  create_table "case_workers", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_workers", ["email"], name: "index_case_workers_on_email", unique: true, using: :btree
  add_index "case_workers", ["reset_password_token"], name: "index_case_workers_on_reset_password_token", unique: true, using: :btree

  create_table "chambers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chambers", ["name"], name: "index_chambers_on_name", using: :btree

  create_table "claims", force: true do |t|
    t.integer  "advocate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "claims", ["advocate_id"], name: "index_claims_on_advocate_id", using: :btree

  create_table "fee_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fee_types", ["name"], name: "index_fee_types_on_name", using: :btree

  create_table "fees", force: true do |t|
    t.string   "description"
    t.string   "code"
    t.integer  "quantity"
    t.decimal  "rate"
    t.decimal  "amount"
    t.integer  "fee_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fees", ["code"], name: "index_fees_on_code", using: :btree
  add_index "fees", ["description"], name: "index_fees_on_description", using: :btree
  add_index "fees", ["fee_type_id"], name: "index_fees_on_fee_type_id", using: :btree

end
