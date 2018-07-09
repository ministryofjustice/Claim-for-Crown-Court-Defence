class CreateMiData < ActiveRecord::Migration[5.0]
  def change
    create_table :mi_data do |t|
      t.boolean   'disk_evidence'
      t.boolean   'retrial_reduction'
      t.date      'case_concluded_at'
      t.date      'effective_pcmh_date'
      t.date      'first_day_of_trial'
      t.date      'legal_aid_transfer_date'
      t.date      'retrial_concluded_at'
      t.date      'retrial_started_at'
      t.date      'trial_concluded_at'
      t.date      'trial_cracked_at'
      t.date      'trial_fixed_at'
      t.date      'trial_fixed_notice_at'
      t.datetime  'authorised_at'
      t.datetime  'created_at', index: true
      t.datetime  'date_last_assessed'
      t.datetime  'last_submitted_at'
      t.datetime  'original_submission_date'
      t.decimal   'amount_authorised'
      t.decimal   'amount_claimed'
      t.decimal   'disbursements_total'
      t.decimal   'disbursements_vat'
      t.decimal   'expenses_total'
      t.decimal   'expenses_vat'
      t.decimal   'fees_total'
      t.decimal   'fees_vat'
      t.decimal   'total'
      t.decimal   'vat_amount'
      t.decimal   'assessment_total'
      t.decimal   'assessment_vat'
      t.integer   'actual_trial_length', index: true
      t.integer   'estimated_trial_length'
      t.integer   'num_of_defendants'
      t.integer   'num_of_documents'
      t.integer   'retrial_actual_length'
      t.integer   'retrial_estimated_length'
      t.integer   'ppe', index: true
      t.integer   'rejections'
      t.integer   'refusals'
      t.integer   'scheme_number'
      t.string    'advocate_category'
      t.string    'case_type', index: true
      t.string    'court'
      t.string    'offence_name'
      t.string    'offence_type', index: true
      t.string    'provider_name'
      t.string    'provider_type'
      t.string    'source'
      t.string    'scheme_name'
      t.string    'supplier_number'
      t.string    'transfer_court'
      t.string    'trial_cracked_at_third'
      t.string    'claim_type'
    end
  end
end
