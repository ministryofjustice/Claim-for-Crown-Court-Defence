NON_TRUNCATED_TABLES ||= %w(
  vat_rates courts offence_classes offences case_types fee_types certification_types expense_types disbursement_types
)

Before('~@no-site-prism') do
  @fee_scheme_selector = FeeSchemeSelectorPage.new
  @external_user_claim_show_page = ExternalUserClaimShowPage.new
  @case_worker_claim_show_page = CaseWorkerClaimShowPage.new

  @claim_form_page = ClaimFormPage.new
  @litigator_claim_form_page = LitigatorClaimFormPage.new
  @interim_claim_form_page = InterimClaimFormPage.new
  @transfer_claim_form_page = TransferClaimFormPage.new

  @claim_summary_page = ClaimSummaryPage.new
  @external_user_home_page = ExternalUserHomePage.new
  @case_worker_home_page = CaseWorkerHomePage.new
  @certification_page = CertificationPage.new
  @confirmation_page = ConfirmationPage.new
  @allocation_page = AllocationPage.new
end

Before('~@no-seeding') do
  unless ($seed_done ||= false)

    load "#{Rails.root}/db/seeds/courts.rb"
    load "#{Rails.root}/db/seeds/offence_classes.rb"
    load "#{Rails.root}/db/seeds/offences.rb"
    load "#{Rails.root}/db/seeds/case_types.rb"
    load "#{Rails.root}/db/seeds/fee_types.rb"
    load "#{Rails.root}/db/seeds/certification_types.rb"
    load "#{Rails.root}/db/seeds/disbursement_types.rb"
    load "#{Rails.root}/db/seeds/expense_types.rb"

    $seed_done = true
  end
end

Before do
  load "#{Rails.root}/db/seeds/vat_rates.rb"
end

AfterConfiguration do
  # Possible values are :truncation and :transaction
  # The :transaction strategy is faster, but might give you threading problems.
  # See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
  Cucumber::Rails::Database.javascript_strategy = :truncation, { except: NON_TRUNCATED_TABLES }
end

at_exit do
  NON_TRUNCATED_TABLES.each do |table|
    table.sub('fee_types', 'Fee::BaseFeeTypes').classify.safe_constantize.delete_all
  end
end
