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

ActiveRecord::Schema.define(version: 20171219122957) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "case_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_fixed_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "requires_cracked_dates"
    t.boolean  "requires_trial_dates"
    t.boolean  "allow_pcmh_fee_type",     default: false
    t.boolean  "requires_maat_reference", default: false
    t.boolean  "requires_retrial_dates",  default: false
    t.string   "roles"
    t.string   "fee_type_code"
    t.uuid     "uuid",                    default: "uuid_generate_v4()"
  end

  create_table "case_worker_claims", force: :cascade do |t|
    t.integer  "case_worker_id"
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_worker_claims", ["case_worker_id"], name: "index_case_worker_claims_on_case_worker_id", using: :btree
  add_index "case_worker_claims", ["claim_id"], name: "index_case_worker_claims_on_claim_id", using: :btree

  create_table "case_workers", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.string   "roles"
    t.datetime "deleted_at"
    t.uuid     "uuid",        default: "uuid_generate_v4()"
  end

  add_index "case_workers", ["location_id"], name: "index_case_workers_on_location_id", using: :btree

  create_table "certification_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "pre_may_2015", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "roles"
  end

  add_index "certification_types", ["name"], name: "index_certification_types_on_name", using: :btree

  create_table "certifications", force: :cascade do |t|
    t.integer  "claim_id"
    t.string   "certified_by"
    t.date     "certification_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "certification_type_id"
  end

  create_table "claim_intentions", force: :cascade do |t|
    t.string   "form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "claim_intentions", ["form_id"], name: "index_claim_intentions_on_form_id", using: :btree

  create_table "claim_state_transitions", force: :cascade do |t|
    t.integer  "claim_id"
    t.string   "namespace"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
    t.string   "reason_code"
    t.integer  "author_id"
    t.integer  "subject_id"
    t.string   "reason_text"
  end

  add_index "claim_state_transitions", ["claim_id"], name: "index_claim_state_transitions_on_claim_id", using: :btree

  create_table "claims", force: :cascade do |t|
    t.text     "additional_information"
    t.boolean  "apply_vat"
    t.string   "state"
    t.datetime "last_submitted_at"
    t.string   "case_number"
    t.string   "advocate_category"
    t.date     "first_day_of_trial"
    t.integer  "estimated_trial_length",   default: 0
    t.integer  "actual_trial_length",      default: 0
    t.decimal  "fees_total",               default: 0.0
    t.decimal  "expenses_total",           default: 0.0
    t.decimal  "total",                    default: 0.0
    t.integer  "external_user_id"
    t.integer  "court_id"
    t.integer  "offence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_until"
    t.string   "cms_number"
    t.datetime "authorised_at"
    t.integer  "creator_id"
    t.text     "evidence_notes"
    t.string   "evidence_checklist_ids"
    t.date     "trial_concluded_at"
    t.date     "trial_fixed_notice_at"
    t.date     "trial_fixed_at"
    t.date     "trial_cracked_at"
    t.string   "trial_cracked_at_third"
    t.string   "source"
    t.decimal  "vat_amount",               default: 0.0
    t.uuid     "uuid",                     default: "uuid_generate_v4()"
    t.integer  "case_type_id"
    t.string   "form_id"
    t.datetime "original_submission_date"
    t.date     "retrial_started_at"
    t.integer  "retrial_estimated_length", default: 0
    t.integer  "retrial_actual_length",    default: 0
    t.date     "retrial_concluded_at"
    t.string   "type"
    t.decimal  "disbursements_total",      default: 0.0
    t.date     "case_concluded_at"
    t.integer  "transfer_court_id"
    t.string   "supplier_number"
    t.date     "effective_pcmh_date"
    t.date     "legal_aid_transfer_date"
    t.string   "allocation_type"
    t.string   "transfer_case_number"
    t.integer  "clone_source_id"
    t.datetime "last_edited_at"
    t.datetime "deleted_at"
    t.string   "providers_ref"
    t.boolean  "disk_evidence",            default: false
    t.decimal  "fees_vat",                 default: 0.0
    t.decimal  "expenses_vat",             default: 0.0
    t.decimal  "disbursements_vat",        default: 0.0
    t.integer  "value_band_id"
    t.boolean  "retrial_reduction",        default: false
  end

  add_index "claims", ["case_number"], name: "index_claims_on_case_number", using: :btree
  add_index "claims", ["cms_number"], name: "index_claims_on_cms_number", using: :btree
  add_index "claims", ["court_id"], name: "index_claims_on_court_id", using: :btree
  add_index "claims", ["creator_id"], name: "index_claims_on_creator_id", using: :btree
  add_index "claims", ["external_user_id"], name: "index_claims_on_external_user_id", using: :btree
  add_index "claims", ["form_id"], name: "index_claims_on_form_id", using: :btree
  add_index "claims", ["offence_id"], name: "index_claims_on_offence_id", using: :btree
  add_index "claims", ["state"], name: "index_claims_on_state", using: :btree
  add_index "claims", ["transfer_case_number"], name: "index_claims_on_transfer_case_number", using: :btree
  add_index "claims", ["valid_until"], name: "index_claims_on_valid_until", using: :btree

  create_table "courts", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "court_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courts", ["code"], name: "index_courts_on_code", using: :btree
  add_index "courts", ["court_type"], name: "index_courts_on_court_type", using: :btree
  add_index "courts", ["name"], name: "index_courts_on_name", using: :btree

  create_table "dates_attended", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_to"
    t.uuid     "uuid",               default: "uuid_generate_v4()"
    t.integer  "attended_item_id"
    t.string   "attended_item_type"
  end

  add_index "dates_attended", ["attended_item_id", "attended_item_type"], name: "index_dates_attended_on_attended_item_id_and_attended_item_type", using: :btree

  create_table "defendants", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "date_of_birth"
    t.boolean  "order_for_judicial_apportionment"
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",                             default: "uuid_generate_v4()"
  end

  add_index "defendants", ["claim_id"], name: "index_defendants_on_claim_id", using: :btree

  create_table "determinations", force: :cascade do |t|
    t.integer  "claim_id"
    t.string   "type"
    t.decimal  "fees",          default: 0.0
    t.decimal  "expenses",      default: 0.0
    t.decimal  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "vat_amount",    default: 0.0
    t.decimal  "disbursements", default: 0.0
  end

  create_table "disbursement_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "unique_code"
  end

  add_index "disbursement_types", ["name"], name: "index_disbursement_types_on_name", using: :btree
  add_index "disbursement_types", ["unique_code"], name: "index_disbursement_types_on_unique_code", unique: true, using: :btree

  create_table "disbursements", force: :cascade do |t|
    t.integer  "disbursement_type_id"
    t.integer  "claim_id"
    t.decimal  "net_amount"
    t.decimal  "vat_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total",                default: 0.0
    t.uuid     "uuid",                 default: "uuid_generate_v4()"
  end

  add_index "disbursements", ["claim_id"], name: "index_disbursements_on_claim_id", using: :btree
  add_index "disbursements", ["disbursement_type_id"], name: "index_disbursements_on_disbursement_type_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "external_user_id"
    t.string   "converted_preview_document_file_name"
    t.string   "converted_preview_document_content_type"
    t.integer  "converted_preview_document_file_size"
    t.datetime "converted_preview_document_updated_at"
    t.uuid     "uuid",                                    default: "uuid_generate_v4()"
    t.string   "form_id"
    t.integer  "creator_id"
    t.integer  "verified_file_size"
    t.string   "file_path"
    t.boolean  "verified",                                default: false
  end

  add_index "documents", ["claim_id"], name: "index_documents_on_claim_id", using: :btree
  add_index "documents", ["creator_id"], name: "index_documents_on_creator_id", using: :btree
  add_index "documents", ["document_file_name"], name: "index_documents_on_document_file_name", using: :btree
  add_index "documents", ["external_user_id"], name: "index_documents_on_external_user_id", using: :btree

  create_table "expense_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "roles"
    t.string   "reason_set"
    t.string   "unique_code"
  end

  add_index "expense_types", ["name"], name: "index_expense_types_on_name", using: :btree
  add_index "expense_types", ["unique_code"], name: "index_expense_types_on_unique_code", unique: true, using: :btree

  create_table "expenses", force: :cascade do |t|
    t.integer  "expense_type_id"
    t.integer  "claim_id"
    t.string   "location"
    t.float    "quantity"
    t.decimal  "rate"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",            default: "uuid_generate_v4()"
    t.integer  "reason_id"
    t.string   "reason_text"
    t.integer  "schema_version"
    t.decimal  "distance"
    t.integer  "mileage_rate_id"
    t.date     "date"
    t.decimal  "hours"
    t.decimal  "vat_amount",      default: 0.0
  end

  add_index "expenses", ["claim_id"], name: "index_expenses_on_claim_id", using: :btree
  add_index "expenses", ["expense_type_id"], name: "index_expenses_on_expense_type_id", using: :btree

  create_table "external_users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "supplier_number"
    t.uuid     "uuid",            default: "uuid_generate_v4()"
    t.boolean  "vat_registered",  default: true
    t.integer  "provider_id"
    t.string   "roles"
    t.datetime "deleted_at"
  end

  add_index "external_users", ["provider_id"], name: "index_external_users_on_provider_id", using: :btree
  add_index "external_users", ["supplier_number"], name: "index_external_users_on_supplier_number", using: :btree

  create_table "fee_types", force: :cascade do |t|
    t.string   "description"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "max_amount"
    t.boolean  "calculated",          default: true
    t.string   "type"
    t.string   "roles"
    t.integer  "parent_id"
    t.boolean  "quantity_is_decimal", default: false
    t.string   "unique_code"
  end

  add_index "fee_types", ["code"], name: "index_fee_types_on_code", using: :btree
  add_index "fee_types", ["description"], name: "index_fee_types_on_description", using: :btree
  add_index "fee_types", ["unique_code"], name: "index_fee_types_on_unique_code", unique: true, using: :btree

  create_table "fees", force: :cascade do |t|
    t.integer  "claim_id"
    t.integer  "fee_type_id"
    t.decimal  "quantity"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "uuid",                  default: "uuid_generate_v4()"
    t.decimal  "rate"
    t.string   "type"
    t.date     "warrant_issued_date"
    t.date     "warrant_executed_date"
    t.integer  "sub_type_id"
    t.string   "case_numbers"
    t.date     "date"
  end

  add_index "fees", ["claim_id"], name: "index_fees_on_claim_id", using: :btree
  add_index "fees", ["fee_type_id"], name: "index_fees_on_fee_type_id", using: :btree

  create_table "injection_attempts", force: :cascade do |t|
    t.integer  "claim_id"
    t.boolean  "succeeded"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "injection_attempts", ["claim_id"], name: "index_injection_attempts_on_claim_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["name"], name: "index_locations_on_name", using: :btree

  create_table "messages", force: :cascade do |t|
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

  create_table "offence_classes", force: :cascade do |t|
    t.string   "class_letter"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offence_classes", ["class_letter"], name: "index_offence_classes_on_class_letter", using: :btree
  add_index "offence_classes", ["description"], name: "index_offence_classes_on_description", using: :btree

  create_table "offences", force: :cascade do |t|
    t.string   "description"
    t.integer  "offence_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unique_code",      default: "anyoldrubbish", null: false
  end

  add_index "offences", ["offence_class_id"], name: "index_offences_on_offence_class_id", using: :btree
  add_index "offences", ["unique_code"], name: "index_offences_on_unique_code", unique: true, using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.string   "firm_agfs_supplier_number"
    t.string   "provider_type"
    t.boolean  "vat_registered"
    t.uuid     "uuid"
    t.uuid     "api_key"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "roles"
  end

  add_index "providers", ["firm_agfs_supplier_number"], name: "index_providers_on_firm_agfs_supplier_number", using: :btree
  add_index "providers", ["name"], name: "index_providers_on_name", using: :btree
  add_index "providers", ["provider_type"], name: "index_providers_on_provider_type", using: :btree

  create_table "representation_orders", force: :cascade do |t|
    t.integer  "defendant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "maat_reference"
    t.date     "representation_order_date"
    t.uuid     "uuid",                      default: "uuid_generate_v4()"
  end

  create_table "statistics", force: :cascade do |t|
    t.date    "date"
    t.string  "report_name"
    t.string  "claim_type"
    t.integer "value_1"
    t.integer "value_2",     default: 0
  end

  add_index "statistics", ["date", "report_name", "claim_type"], name: "index_statistics_on_date_and_report_name_and_claim_type", unique: true, using: :btree

  create_table "stats_reports", force: :cascade do |t|
    t.string   "report_name"
    t.string   "report"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "completed_at"
  end

  create_table "super_admins", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplier_numbers", force: :cascade do |t|
    t.integer "provider_id"
    t.string  "supplier_number"
  end

  create_table "transfer_details", force: :cascade do |t|
    t.integer "claim_id"
    t.string  "litigator_type"
    t.boolean "elected_case"
    t.integer "transfer_stage_id"
    t.date    "transfer_date"
    t.integer "case_conclusion_id"
  end

  create_table "user_message_statuses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.boolean  "read",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_message_statuses", ["message_id"], name: "index_user_message_statuses_on_message_id", using: :btree
  add_index "user_message_statuses", ["read"], name: "index_user_message_statuses_on_read", using: :btree
  add_index "user_message_statuses", ["user_id"], name: "index_user_message_statuses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",                   null: false
    t.string   "encrypted_password",     default: "",                   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                    null: false
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
    t.integer  "failed_attempts",        default: 0,                    null: false
    t.datetime "locked_at"
    t.string   "unlock_token"
    t.text     "settings"
    t.datetime "deleted_at"
    t.uuid     "api_key",                default: "uuid_generate_v4()"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "vat_rates", force: :cascade do |t|
    t.integer  "rate_base_points"
    t.date     "effective_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "injection_attempts", "claims"
end
