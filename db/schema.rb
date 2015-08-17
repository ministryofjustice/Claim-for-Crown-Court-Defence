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

ActiveRecord::Schema.define(version: 20150813163440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "advocates", force: true do |t|
    t.string   "role"
    t.integer  "chamber_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_number"
    t.uuid     "uuid",           default: "uuid_generate_v4()"
  end

  add_index "advocates", ["account_number"], name: "index_advocates_on_account_number", using: :btree
  add_index "advocates", ["chamber_id"], name: "index_advocates_on_chamber_id", using: :btree
  add_index "advocates", ["role"], name: "index_advocates_on_role", using: :btree

  create_table "case_types", force: true do |t|
    t.string   "name"
    t.boolean  "is_fixed_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "case_worker_claims", force: true do |t|
    t.integer  "case_worker_id"
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_worker_claims", ["case_worker_id"], name: "index_case_worker_claims_on_case_worker_id", using: :btree
  add_index "case_worker_claims", ["claim_id"], name: "index_case_worker_claims_on_claim_id", using: :btree

  create_table "case_workers", force: true do |t|
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.string   "days_worked"
    t.string   "approval_level", default: "Low"
  end

  add_index "case_workers", ["location_id"], name: "index_case_workers_on_location_id", using: :btree
  add_index "case_workers", ["role"], name: "index_case_workers_on_role", using: :btree

  create_table "chambers", force: true do |t|
    t.string   "name"
    t.string   "account_number"
    t.boolean  "vat_registered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",           default: "uuid_generate_v4()"
  end

  add_index "chambers", ["account_number"], name: "index_chambers_on_account_number", using: :btree
  add_index "chambers", ["name"], name: "index_chambers_on_name", using: :btree

  create_table "claim_state_transitions", force: true do |t|
    t.integer  "claim_id"
    t.string   "namespace"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
  end

  add_index "claim_state_transitions", ["claim_id"], name: "index_claim_state_transitions_on_claim_id", using: :btree

  create_table "claims", force: true do |t|
    t.text     "additional_information"
    t.boolean  "apply_vat"
    t.string   "state"
    t.datetime "submitted_at"
    t.string   "case_number"
    t.string   "advocate_category"
    t.string   "prosecuting_authority"
    t.string   "indictment_number"
    t.date     "first_day_of_trial"
    t.integer  "estimated_trial_length", default: 0
    t.integer  "actual_trial_length",    default: 0
    t.decimal  "fees_total",             default: 0.0
    t.decimal  "expenses_total",         default: 0.0
    t.decimal  "total",                  default: 0.0
    t.integer  "advocate_id"
    t.integer  "court_id"
    t.integer  "offence_id"
    t.integer  "scheme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_until"
    t.string   "cms_number"
    t.datetime "paid_at"
    t.integer  "creator_id"
    t.text     "notes"
    t.text     "evidence_notes"
    t.string   "evidence_checklist_ids"
    t.date     "trial_concluded_at"
    t.date     "trial_fixed_notice_at"
    t.date     "trial_fixed_at"
    t.date     "trial_cracked_at"
    t.string   "trial_cracked_at_third"
    t.string   "source"
    t.decimal  "vat_amount",             default: 0.0
    t.uuid     "uuid",                   default: "uuid_generate_v4()"
    t.integer  "case_type_id"
  end

  add_index "claims", ["advocate_id"], name: "index_claims_on_advocate_id", using: :btree
  add_index "claims", ["cms_number"], name: "index_claims_on_cms_number", using: :btree
  add_index "claims", ["court_id"], name: "index_claims_on_court_id", using: :btree
  add_index "claims", ["creator_id"], name: "index_claims_on_creator_id", using: :btree
  add_index "claims", ["offence_id"], name: "index_claims_on_offence_id", using: :btree
  add_index "claims", ["scheme_id"], name: "index_claims_on_scheme_id", using: :btree
  add_index "claims", ["valid_until"], name: "index_claims_on_valid_until", using: :btree

  create_table "courts", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "court_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courts", ["code"], name: "index_courts_on_code", using: :btree
  add_index "courts", ["court_type"], name: "index_courts_on_court_type", using: :btree
  add_index "courts", ["name"], name: "index_courts_on_name", using: :btree

  create_table "dates_attended", force: true do |t|
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_to"
    t.uuid     "uuid",               default: "uuid_generate_v4()"
    t.integer  "attended_item_id"
    t.string   "attended_item_type"
  end

  add_index "dates_attended", ["attended_item_id", "attended_item_type"], name: "index_dates_attended_on_attended_item_id_and_attended_item_type", using: :btree

  create_table "defendants", force: true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.datetime "date_of_birth"
    t.boolean  "order_for_judicial_apportionment"
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",                             default: "uuid_generate_v4()"
  end

  add_index "defendants", ["claim_id"], name: "index_defendants_on_claim_id", using: :btree

  create_table "determinations", force: true do |t|
    t.integer  "claim_id"
    t.string   "type"
    t.decimal  "fees"
    t.decimal  "expenses"
    t.decimal  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: true do |t|
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "advocate_id"
    t.string   "converted_preview_document_file_name"
    t.string   "converted_preview_document_content_type"
    t.integer  "converted_preview_document_file_size"
    t.datetime "converted_preview_document_updated_at"
    t.uuid     "uuid",                                    default: "uuid_generate_v4()"
  end

  add_index "documents", ["advocate_id"], name: "index_documents_on_advocate_id", using: :btree
  add_index "documents", ["claim_id"], name: "index_documents_on_claim_id", using: :btree
  add_index "documents", ["document_file_name"], name: "index_documents_on_document_file_name", using: :btree

  create_table "expense_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expense_types", ["name"], name: "index_expense_types_on_name", using: :btree

  create_table "expenses", force: true do |t|
    t.integer  "expense_type_id"
    t.integer  "claim_id"
    t.string   "location"
    t.integer  "quantity"
    t.decimal  "rate"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",            default: "uuid_generate_v4()"
  end

  add_index "expenses", ["claim_id"], name: "index_expenses_on_claim_id", using: :btree
  add_index "expenses", ["expense_type_id"], name: "index_expenses_on_expense_type_id", using: :btree

  create_table "features", force: true do |t|
    t.string   "key",                        null: false
    t.boolean  "enabled",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "fee_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
  end

  add_index "fee_categories", ["name"], name: "index_fee_categories_on_name", using: :btree

  create_table "fee_types", force: true do |t|
    t.string   "description"
    t.string   "code"
    t.integer  "fee_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fee_types", ["code"], name: "index_fee_types_on_code", using: :btree
  add_index "fee_types", ["description"], name: "index_fee_types_on_description", using: :btree
  add_index "fee_types", ["fee_category_id"], name: "index_fee_types_on_fee_category_id", using: :btree

  create_table "fees", force: true do |t|
    t.integer  "claim_id"
    t.integer  "fee_type_id"
    t.integer  "quantity"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",        default: "uuid_generate_v4()"
  end

  add_index "fees", ["claim_id"], name: "index_fees_on_claim_id", using: :btree
  add_index "fees", ["fee_type_id"], name: "index_fees_on_fee_type_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["name"], name: "index_locations_on_name", using: :btree

  create_table "messages", force: true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "claim_id"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "messages", ["claim_id"], name: "index_messages_on_claim_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree

  create_table "offence_classes", force: true do |t|
    t.string   "class_letter"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offence_classes", ["class_letter"], name: "index_offence_classes_on_class_letter", using: :btree
  add_index "offence_classes", ["description"], name: "index_offence_classes_on_description", using: :btree

  create_table "offences", force: true do |t|
    t.string   "description"
    t.integer  "offence_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offences", ["offence_class_id"], name: "index_offences_on_offence_class_id", using: :btree

  create_table "representation_orders", force: true do |t|
    t.integer  "defendant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "granting_body"
    t.string   "maat_reference"
    t.date     "representation_order_date"
    t.uuid     "uuid",                      default: "uuid_generate_v4()"
  end

  create_table "schemes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "schemes", ["name"], name: "index_schemes_on_name", using: :btree

  create_table "user_message_statuses", force: true do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.boolean  "read",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_message_statuses", ["message_id"], name: "index_user_message_statuses_on_message_id", using: :btree
  add_index "user_message_statuses", ["read"], name: "index_user_message_statuses_on_read", using: :btree
  add_index "user_message_statuses", ["user_id"], name: "index_user_message_statuses_on_user_id", using: :btree

  create_table "users", force: true do |t|
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
    t.integer  "persona_id"
    t.string   "persona_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vat_rates", force: true do |t|
    t.integer  "rate_base_points"
    t.date     "effective_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
