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

ActiveRecord::Schema.define(version: 2021_03_05_134731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "case_stages", force: :cascade do |t|
    t.bigint "case_type_id"
    t.string "unique_code", default: "", null: false
    t.string "description", null: false
    t.integer "position"
    t.string "roles"
    t.index ["case_type_id"], name: "index_case_stages_on_case_type_id"
  end

  create_table "case_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "is_fixed_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "requires_cracked_dates"
    t.boolean "requires_trial_dates"
    t.boolean "allow_pcmh_fee_type", default: false
    t.boolean "requires_maat_reference", default: false
    t.boolean "requires_retrial_dates", default: false
    t.string "roles"
    t.string "fee_type_code"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
  end

  create_table "case_worker_claims", id: :serial, force: :cascade do |t|
    t.integer "case_worker_id"
    t.integer "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["case_worker_id"], name: "index_case_worker_claims_on_case_worker_id"
    t.index ["claim_id"], name: "index_case_worker_claims_on_claim_id"
  end

  create_table "case_workers", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "location_id"
    t.string "roles"
    t.datetime "deleted_at"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.index ["location_id"], name: "index_case_workers_on_location_id"
  end

  create_table "certification_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "pre_may_2015", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "roles"
    t.index ["name"], name: "index_certification_types_on_name"
  end

  create_table "certifications", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.string "certified_by"
    t.date "certification_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "certification_type_id"
  end

  create_table "claim_intentions", id: :serial, force: :cascade do |t|
    t.string "form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["form_id"], name: "index_claim_intentions_on_form_id"
  end

  create_table "claim_state_transitions", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.string "namespace"
    t.string "event"
    t.string "from"
    t.string "to"
    t.datetime "created_at"
    t.string "reason_code"
    t.integer "author_id"
    t.integer "subject_id"
    t.string "reason_text"
    t.index ["claim_id"], name: "index_claim_state_transitions_on_claim_id"
  end

  create_table "claims", id: :serial, force: :cascade do |t|
    t.text "additional_information"
    t.boolean "apply_vat"
    t.string "state"
    t.datetime "last_submitted_at"
    t.string "case_number"
    t.string "advocate_category"
    t.date "first_day_of_trial"
    t.integer "estimated_trial_length", default: 0
    t.integer "actual_trial_length", default: 0
    t.decimal "fees_total", default: "0.0"
    t.decimal "expenses_total", default: "0.0"
    t.decimal "total", default: "0.0"
    t.integer "external_user_id"
    t.integer "court_id"
    t.integer "offence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_until"
    t.string "cms_number"
    t.datetime "authorised_at"
    t.integer "creator_id"
    t.text "evidence_notes"
    t.string "evidence_checklist_ids"
    t.date "trial_concluded_at"
    t.date "trial_fixed_notice_at"
    t.date "trial_fixed_at"
    t.date "trial_cracked_at"
    t.string "trial_cracked_at_third"
    t.string "source"
    t.decimal "vat_amount", default: "0.0"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "case_type_id"
    t.string "form_id"
    t.datetime "original_submission_date"
    t.date "retrial_started_at"
    t.integer "retrial_estimated_length", default: 0
    t.integer "retrial_actual_length", default: 0
    t.date "retrial_concluded_at"
    t.string "type"
    t.decimal "disbursements_total", default: "0.0"
    t.date "case_concluded_at"
    t.integer "transfer_court_id"
    t.string "supplier_number"
    t.date "effective_pcmh_date"
    t.date "legal_aid_transfer_date"
    t.string "allocation_type"
    t.string "transfer_case_number"
    t.integer "clone_source_id"
    t.datetime "last_edited_at"
    t.datetime "deleted_at"
    t.string "providers_ref"
    t.boolean "disk_evidence", default: false
    t.decimal "fees_vat", default: "0.0"
    t.decimal "expenses_vat", default: "0.0"
    t.decimal "disbursements_vat", default: "0.0"
    t.integer "value_band_id"
    t.boolean "retrial_reduction", default: false
    t.string "travel_expense_additional_information"
    t.boolean "prosecution_evidence"
    t.bigint "case_stage_id"
    t.index ["case_number"], name: "index_claims_on_case_number"
    t.index ["case_stage_id"], name: "index_claims_on_case_stage_id"
    t.index ["cms_number"], name: "index_claims_on_cms_number"
    t.index ["court_id"], name: "index_claims_on_court_id"
    t.index ["creator_id"], name: "index_claims_on_creator_id"
    t.index ["deleted_at"], name: "index_claims_on_deleted_at"
    t.index ["external_user_id"], name: "index_claims_on_external_user_id"
    t.index ["form_id"], name: "index_claims_on_form_id"
    t.index ["offence_id"], name: "index_claims_on_offence_id"
    t.index ["state"], name: "index_claims_on_state"
    t.index ["transfer_case_number"], name: "index_claims_on_transfer_case_number"
    t.index ["uuid"], name: "index_claims_on_uuid", unique: true
    t.index ["valid_until"], name: "index_claims_on_valid_until"
  end

  create_table "courts", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "court_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_courts_on_code"
    t.index ["court_type"], name: "index_courts_on_court_type"
    t.index ["name"], name: "index_courts_on_name"
  end

  create_table "dates_attended", id: :serial, force: :cascade do |t|
    t.date "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "date_to"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "attended_item_id"
    t.string "attended_item_type"
    t.index ["attended_item_id", "attended_item_type"], name: "index_dates_attended_on_attended_item_id_and_attended_item_type"
  end

  create_table "defendants", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.boolean "order_for_judicial_apportionment"
    t.integer "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.index ["claim_id"], name: "index_defendants_on_claim_id"
  end

  create_table "determinations", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.string "type"
    t.decimal "fees", default: "0.0"
    t.decimal "expenses", default: "0.0"
    t.decimal "total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "vat_amount", default: 0.0
    t.decimal "disbursements", default: "0.0"
    t.index ["claim_id"], name: "index_determinations_on_claim_id"
  end

  create_table "disbursement_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "unique_code"
    t.index ["name"], name: "index_disbursement_types_on_name"
    t.index ["unique_code"], name: "index_disbursement_types_on_unique_code", unique: true
  end

  create_table "disbursements", id: :serial, force: :cascade do |t|
    t.integer "disbursement_type_id"
    t.integer "claim_id"
    t.decimal "net_amount"
    t.decimal "vat_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "total", default: "0.0"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.index ["claim_id"], name: "index_disbursements_on_claim_id"
    t.index ["disbursement_type_id"], name: "index_disbursements_on_disbursement_type_id"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.integer "external_user_id"
    t.string "converted_preview_document_file_name"
    t.string "converted_preview_document_content_type"
    t.integer "converted_preview_document_file_size"
    t.datetime "converted_preview_document_updated_at"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "form_id"
    t.integer "creator_id"
    t.integer "verified_file_size"
    t.string "file_path"
    t.boolean "verified", default: false
    t.string "as_document_checksum"
    t.string "as_converted_preview_document_checksum"
    t.index ["claim_id"], name: "index_documents_on_claim_id"
    t.index ["creator_id"], name: "index_documents_on_creator_id"
    t.index ["document_file_name"], name: "index_documents_on_document_file_name"
    t.index ["external_user_id"], name: "index_documents_on_external_user_id"
  end

  create_table "establishments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_establishments_on_category"
  end

  create_table "expense_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "roles"
    t.string "reason_set"
    t.string "unique_code"
    t.index ["name"], name: "index_expense_types_on_name"
    t.index ["unique_code"], name: "index_expense_types_on_unique_code", unique: true
  end

  create_table "expenses", id: :serial, force: :cascade do |t|
    t.integer "expense_type_id"
    t.integer "claim_id"
    t.string "location"
    t.float "quantity"
    t.decimal "rate"
    t.decimal "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "reason_id"
    t.string "reason_text"
    t.integer "schema_version"
    t.decimal "distance"
    t.integer "mileage_rate_id"
    t.date "date"
    t.decimal "hours"
    t.decimal "vat_amount", default: "0.0"
    t.string "location_type"
    t.decimal "calculated_distance"
    t.index ["claim_id"], name: "index_expenses_on_claim_id"
    t.index ["expense_type_id"], name: "index_expenses_on_expense_type_id"
  end

  create_table "external_users", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "supplier_number"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.boolean "vat_registered", default: true
    t.integer "provider_id"
    t.string "roles"
    t.datetime "deleted_at"
    t.index ["provider_id"], name: "index_external_users_on_provider_id"
    t.index ["supplier_number"], name: "index_external_users_on_supplier_number"
  end

  create_table "fee_schemes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fee_types", id: :serial, force: :cascade do |t|
    t.string "description"
    t.string "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "max_amount"
    t.boolean "calculated", default: true
    t.string "type"
    t.string "roles"
    t.integer "parent_id"
    t.boolean "quantity_is_decimal", default: false
    t.string "unique_code"
    t.integer "position"
    t.index ["code"], name: "index_fee_types_on_code"
    t.index ["description"], name: "index_fee_types_on_description"
    t.index ["unique_code"], name: "index_fee_types_on_unique_code", unique: true
  end

  create_table "fees", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.integer "fee_type_id"
    t.decimal "quantity"
    t.decimal "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.decimal "rate"
    t.string "type"
    t.date "warrant_issued_date"
    t.date "warrant_executed_date"
    t.integer "sub_type_id"
    t.string "case_numbers"
    t.date "date"
    t.boolean "price_calculated", default: false
    t.index ["claim_id"], name: "index_fees_on_claim_id"
    t.index ["fee_type_id"], name: "index_fees_on_fee_type_id"
  end

  create_table "injection_attempts", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.boolean "succeeded"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "error_messages"
    t.datetime "deleted_at"
    t.index ["claim_id"], name: "index_injection_attempts_on_claim_id"
  end

  create_table "interim_claim_info", id: :serial, force: :cascade do |t|
    t.boolean "warrant_fee_paid"
    t.date "warrant_issued_date"
    t.date "warrant_executed_date"
    t.integer "claim_id"
    t.index ["claim_id"], name: "index_interim_claim_info_on_claim_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "claim_id"
    t.integer "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string "as_attachment_checksum"
    t.index ["claim_id"], name: "index_messages_on_claim_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "mi_data", id: :serial, force: :cascade do |t|
    t.boolean "disk_evidence"
    t.boolean "retrial_reduction"
    t.date "case_concluded_at"
    t.date "effective_pcmh_date"
    t.date "first_day_of_trial"
    t.date "legal_aid_transfer_date"
    t.date "retrial_concluded_at"
    t.date "retrial_started_at"
    t.date "trial_concluded_at"
    t.date "trial_cracked_at"
    t.date "trial_fixed_at"
    t.date "trial_fixed_notice_at"
    t.datetime "authorised_at"
    t.datetime "created_at"
    t.datetime "date_last_assessed"
    t.datetime "last_submitted_at"
    t.datetime "original_submission_date"
    t.decimal "amount_authorised"
    t.decimal "amount_claimed"
    t.decimal "disbursements_total"
    t.decimal "disbursements_vat"
    t.decimal "expenses_total"
    t.decimal "expenses_vat"
    t.decimal "fees_total"
    t.decimal "fees_vat"
    t.decimal "total"
    t.decimal "vat_amount"
    t.decimal "assessment_total"
    t.decimal "assessment_vat"
    t.integer "actual_trial_length"
    t.integer "estimated_trial_length"
    t.integer "num_of_defendants"
    t.integer "num_of_documents"
    t.integer "retrial_actual_length"
    t.integer "retrial_estimated_length"
    t.integer "ppe"
    t.integer "rejections"
    t.integer "refusals"
    t.integer "scheme_number"
    t.string "advocate_category"
    t.string "case_type"
    t.string "court"
    t.string "offence_name"
    t.string "offence_type"
    t.string "provider_name"
    t.string "provider_type"
    t.string "source"
    t.string "scheme_name"
    t.string "supplier_number"
    t.string "transfer_court"
    t.string "trial_cracked_at_third"
    t.string "claim_type"
    t.decimal "assessment_fees"
    t.decimal "assessment_expenses"
    t.decimal "assessment_disbursements"
    t.index ["actual_trial_length"], name: "index_mi_data_on_actual_trial_length"
    t.index ["case_type"], name: "index_mi_data_on_case_type"
    t.index ["created_at"], name: "index_mi_data_on_created_at"
    t.index ["offence_type"], name: "index_mi_data_on_offence_type"
    t.index ["ppe"], name: "index_mi_data_on_ppe"
  end

  create_table "offence_bands", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "description"
    t.integer "offence_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offence_category_id"], name: "index_offence_bands_on_offence_category_id"
  end

  create_table "offence_categories", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offence_classes", id: :serial, force: :cascade do |t|
    t.string "class_letter"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["class_letter"], name: "index_offence_classes_on_class_letter"
    t.index ["description"], name: "index_offence_classes_on_description"
  end

  create_table "offence_fee_schemes", id: :serial, force: :cascade do |t|
    t.integer "offence_id"
    t.integer "fee_scheme_id"
    t.index ["fee_scheme_id"], name: "index_offence_fee_schemes_on_fee_scheme_id"
    t.index ["offence_id"], name: "index_offence_fee_schemes_on_offence_id"
  end

  create_table "offences", id: :serial, force: :cascade do |t|
    t.string "description"
    t.integer "offence_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "unique_code", default: "anyoldrubbish", null: false
    t.integer "offence_band_id"
    t.string "contrary"
    t.string "year_chapter"
    t.index ["offence_band_id"], name: "index_offences_on_offence_band_id"
    t.index ["offence_class_id"], name: "index_offences_on_offence_class_id"
    t.index ["unique_code"], name: "index_offences_on_unique_code", unique: true
  end

  create_table "providers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "firm_agfs_supplier_number"
    t.string "provider_type"
    t.boolean "vat_registered"
    t.uuid "uuid"
    t.uuid "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles"
    t.index ["firm_agfs_supplier_number"], name: "index_providers_on_firm_agfs_supplier_number"
    t.index ["name"], name: "index_providers_on_name"
    t.index ["provider_type"], name: "index_providers_on_provider_type"
  end

  create_table "representation_orders", id: :serial, force: :cascade do |t|
    t.integer "defendant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "maat_reference"
    t.date "representation_order_date"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.index ["defendant_id"], name: "index_representation_orders_on_defendant_id"
  end

  create_table "statistics", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "report_name"
    t.string "claim_type"
    t.integer "value_1"
    t.integer "value_2", default: 0
    t.index ["date", "report_name", "claim_type"], name: "index_statistics_on_date_and_report_name_and_claim_type", unique: true
  end

  create_table "stats_reports", id: :serial, force: :cascade do |t|
    t.string "report_name"
    t.string "report"
    t.string "status"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.string "as_document_checksum"
  end

  create_table "super_admins", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplier_numbers", id: :serial, force: :cascade do |t|
    t.integer "provider_id"
    t.string "supplier_number"
    t.string "name"
    t.string "postcode"
  end

  create_table "transfer_details", id: :serial, force: :cascade do |t|
    t.integer "claim_id"
    t.string "litigator_type"
    t.boolean "elected_case"
    t.integer "transfer_stage_id"
    t.date "transfer_date"
    t.integer "case_conclusion_id"
  end

  create_table "user_message_statuses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "message_id"
    t.boolean "read", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["message_id"], name: "index_user_message_statuses_on_message_id"
    t.index ["read"], name: "index_user_message_statuses_on_read"
    t.index ["user_id"], name: "index_user_message_statuses_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "persona_id"
    t.string "persona_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "unlock_token"
    t.text "settings"
    t.datetime "deleted_at"
    t.uuid "api_key", default: -> { "uuid_generate_v4()" }
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vat_rates", id: :serial, force: :cascade do |t|
    t.integer "rate_base_points"
    t.date "effective_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "claims", "case_stages", name: "fk_claims_case_stage_id"
  add_foreign_key "offence_bands", "offence_categories"
  add_foreign_key "offences", "offence_bands"
end
