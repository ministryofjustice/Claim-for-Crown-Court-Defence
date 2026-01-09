NON_TRUNCATED_TABLES ||= %w(
  vat_rates courts offence_classes offences case_types case_stages fee_types certification_types expense_types disbursement_types
  offence_bands offence_categories offence_fee_schemes fee_schemes establishments
)

Before('not @no-site-prism') do
  @fee_scheme_selector = FeeSchemeSelectorPage.new
  @external_user_claim_show_page = ExternalUserClaimShowPage.new
  @case_worker_claim_show_page = CaseWorkerClaimShowPage.new
  @external_user_manage_users_page = ExternalUserManageUsersPage.new
  @new_user_page = NewUserPage.new
  @edit_user_page = EditUserPage.new

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
  @provider_users_index_page = ProviderUsersIndexPage.new
  @provider_users_show_page = ProviderUsersShowPage.new
  @provider_users_new_page = ProviderUsersNewPage.new
  @provider_users_edit_page = ProviderUsersEditPage.new
  @provider_users_change_availability_page = ProviderUsersChangeAvailabilityPage.new

  @cookie_page = CookiePage.new
  @misc_fee_page = MiscellaneousFeePage.new
end

Before('not @no-seed') do
  unless ($seed_done ||= false)
    # IMPORTANT - Truncate lookup table data to ensure any factory created lookup data is cleared
    truncate_lookup_tables

    # IMPORTANT - add any seeded tables to list of NON_TRUNCATED_TABLES
    ActiveRecord::Base.connection.reset_pk_sequence!('offences')
    load "#{Rails.root}/db/seeds/courts.rb"
    load "#{Rails.root}/db/seeds/offence_classes.rb"
    load "#{Rails.root}/db/seeds/offences.rb"
    load "#{Rails.root}/db/seeds/scheme_10.rb"
    load "#{Rails.root}/db/seeds/scheme_11.rb"
    load "#{Rails.root}/db/seeds/scheme_12.rb"
    load "#{Rails.root}/db/seeds/case_types.rb"
    load "#{Rails.root}/db/seeds/case_stages.rb"
    load "#{Rails.root}/db/seeds/fee_types.rb"
    load "#{Rails.root}/db/seeds/certification_types.rb"
    load "#{Rails.root}/db/seeds/disbursement_types.rb"
    load "#{Rails.root}/db/seeds/expense_types.rb"
    load "#{Rails.root}/db/seeds/vat_rates.rb"
    load "#{Rails.root}/db/seeds/establishments.rb"
    load "#{Rails.root}/db/seeds/lgfs_scheme_10.rb"
    load "#{Rails.root}/db/seeds/scheme_13.rb"
    load "#{Rails.root}/db/seeds/scheme_14.rb"
    load "#{Rails.root}/db/seeds/scheme_15.rb"
    load "#{Rails.root}/db/seeds/scheme_16.rb"
    load "#{Rails.root}/db/seeds/agfs_scheme_cleaner.rb"
    load "#{Rails.root}/db/seeds/lgfs_scheme_11.rb"

    $vat_seed_done = true
    $seed_done = true
  end
end

# after the defaults have been changed to 7.2 in config/application.rb it might be possible to remove this.
Before('@javascript') do
  Rails.application.config.active_job.enqueue_after_transaction_commit = true
end

# minimum seeding necessary for case worker functionality
# to avoid long start up time for basic case worker features
#
Before('@vat-seeds') do
  unless ($vat_seed_done ||= false)
    load "#{Rails.root}/db/seeds/vat_rates.rb"
    $vat_seed_done = true
  end
end

Before('@on-api-sandbox') do
  allow(ENV).to receive(:fetch).and_call_original
  allow(ENV).to receive(:fetch).with('ENV', nil).and_return 'api-sandbox'

  @api_landing_page = ApiLandingPage.new
  @new_user_sign_up_page = NewUserSignUpPage.new
  @vendor_tandcs_page = VendorTandcsPage.new
  @external_user_home_page = ExternalUserHomePage.new
end

After('@on-api-sandbox') do
  allow(ENV).to receive(:fetch).with('ENV', nil).and_call_original
end

BeforeAll do
  # Possible values are :truncation and :transaction
  # The :transaction strategy is faster, but might give you threading problems.
  # See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
  Cucumber::Rails::Database.javascript_strategy = :truncation, { except: NON_TRUNCATED_TABLES }
end

After do |scenario|
  # undo any mocks and stubs created by scenario steps
  travel_back
  RSpec::Mocks.space.proxy_for(Settings).reset

  # screenshot failure for storage as artifact in circleCI
  name = scenario.location.file.gsub('features/','').gsub(/\.|\//, '-')
  screenshot_image(name) if scenario.failed? && ENV['CI']

  # Following a local ruby and various dependecy updates cucumber no longer
  # appears to have been shutting down the chromedriver automatically.
  # This explicit quit patches the issue for chromedriver, ignoring
  # Capybara::Rack::Test::Drivers, but hopefully a chromedriver
  # or selenium webdriver update will make this unecessary in the near
  # future
  #
  Capybara.current_session.driver.tap do |driver|
    driver.quit if driver.respond_to?(:quit)
  end
end

at_exit do
  #
  # NOTE: ActiveRecord may be interfering with exit codes
  #       so we need to explcitly return the test suite
  #       run's exit code.
  #
  exit_status = $!.status if $!.is_a?(SystemExit)
  truncate_lookup_tables
  exit exit_status if exit_status
end

def truncate_lookup_tables
  NON_TRUNCATED_TABLES.each do |table|
    table.sub('fee_types', 'Fee::BaseFeeType').classify.safe_constantize.delete_all
  end
end
