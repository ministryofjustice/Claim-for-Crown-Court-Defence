NON_TRUNCATED_TABLES ||= %w(
  vat_rates courts offence_classes offences case_types fee_types certification_types expense_types disbursement_types
  offence_bands offence_categories offence_fee_schemes fee_schemes establishments
)

Before('not @no-site-prism') do
  @fee_scheme_selector = FeeSchemeSelectorPage.new
  @external_user_claim_show_page = ExternalUserClaimShowPage.new
  @case_worker_claim_show_page = CaseWorkerClaimShowPage.new

  @claim_form_page = ClaimFormPage.new
  @advocate_hardship_claim_form_page = AdvocateHardshipClaimFormPage.new
  @advocate_interim_claim_form_page = AdvocateInterimClaimFormPage.new
  @advocate_supplementary_claim_form_page = AdvocateSupplementaryClaimFormPage.new
  @litigator_claim_form_page = LitigatorClaimFormPage.new
  @litigator_interim_claim_form_page = LitigatorInterimClaimFormPage.new
  @litigator_transfer_claim_form_page = LitigatorTransferClaimFormPage.new
  @litigator_hardship_claim_form_page = LitigatorHardshipClaimFormPage.new

  @claim_summary_page = ClaimSummaryPage.new
  @external_user_home_page = ExternalUserHomePage.new
  @case_worker_home_page = CaseWorkerHomePage.new
  @certification_page = CertificationPage.new
  @confirmation_page = ConfirmationPage.new
  @allocation_page = AllocationPage.new
  @provider_index_page = ProviderIndexPage.new
  @new_provider_page = ProviderPage.new
  @provider_search_page = ProviderSearchPage.new
end

Before do
  unless ($seed_done ||= false)

    ActiveRecord::Base.connection.reset_pk_sequence!('offences')
    load "#{Rails.root}/db/seeds/courts.rb"
    load "#{Rails.root}/db/seeds/offence_classes.rb"
    load "#{Rails.root}/db/seeds/offences.rb"
    load "#{Rails.root}/db/seeds/scheme_10.rb"
    load "#{Rails.root}/db/seeds/scheme_11.rb"
    load "#{Rails.root}/db/seeds/case_types.rb"
    load "#{Rails.root}/db/seeds/fee_types.rb"
    load "#{Rails.root}/db/seeds/certification_types.rb"
    load "#{Rails.root}/db/seeds/disbursement_types.rb"
    load "#{Rails.root}/db/seeds/expense_types.rb"
    load "#{Rails.root}/db/seeds/vat_rates.rb"
    load "#{Rails.root}/db/seeds/establishments.rb"

    $seed_done = true
  end
end

AfterConfiguration do
  # Possible values are :truncation and :transaction
  # The :transaction strategy is faster, but might give you threading problems.
  # See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
  Cucumber::Rails::Database.javascript_strategy = :truncation, { except: NON_TRUNCATED_TABLES }
end

After do |scenario|
  name = scenario.location.file.gsub('features/','').gsub(/\.|\//, '-')
  screenshot_image(name) if scenario.failed?

  # Following a local ruby and various dependecy updates cucumber no longer
  # appears to have been shutting down the chromedriver automatically.
  # This explicit quit patches the issue for chromedriver, ignoring
  # Capybara::Rack::Test::Drivers, but hopefully a chromedriver
  # or selenium webdriver update will make this unecessary in the near
  # future
  #
  Capybara.current_session.driver.tap do |driver|
    puts browser_logs(driver).red if scenario.failed?
    driver.quit if driver.respond_to?(:quit)
  end

  # undo any time travel set by scenario
  travel_back
end

def browser_logs(driver)
  "Browser logs:\n" << driver.browser.manage.logs.get(:browser).map(&:to_s).join("\n")
end

at_exit do
  #
  # NOTE: ActiveRecord may be interfering with exit codes
  #       so we need to explcitly return the test suite
  #       run's exit code.
  #
  exit_status = $!.status if $!.is_a?(SystemExit)
  NON_TRUNCATED_TABLES.each do |table|
    table.sub('fee_types', 'Fee::BaseFeeType').classify.safe_constantize.delete_all
  end
  exit exit_status if exit_status
end
