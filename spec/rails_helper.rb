require 'simplecov'

SimpleCov.start
SimpleCov.start do
  add_filter '_spec.rb'
  add_filter 'spec/'
  add_filter 'config/'
  add_filter 'db/seeds'

  # exclude individual files from test coverage stats
  add_filter 'lib/demo_data/claim_state_advancer.rb'          # only used for generation of demo data
  add_filter 'app/interfaces/api/helpers/xml_formatter.rb'    # only used for XML export proof of concept (LAA integration)
  add_filter 'app/validators/expense_v1_validator.rb'         # no longer used - can be removed when all claims with v1 expenses deleted (see PT https://www.pivotaltracker.com/story/show/119351871 )
  add_filter 'lib/caching/redis_store.rb'                     # unable to mock a local instance of Redis
  add_filter 'lib/messaging'                                  # all the files used in the proof of concept to export calims to LAA systems


  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'FormBuilders', 'app/form_builders'
  add_group 'Helpers', 'app/helpers'
  add_group 'API', 'app/interfaces/api'
  add_group 'Presenters', '/app/presenters'


  # add_filter "\/factories\/"
end

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'simplecov'
  SimpleCov.start
  # allow Code Climate Test coverage reports to be sent
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['ADP_API_USER'] = 'api_user'
ENV['ADP_API_PASS'] = 'api_password'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'shoulda/matchers'
require 'paperclip/matchers'
require 'webmock/rspec'
require 'kaminari_rspec'
require 'vcr_helper'
require 'sidekiq/testing'

include ActionDispatch::TestProcess #required for fixture_file_upload

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers
  config.include ValidationHelpers, type: :validator
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include KaminariRspec::TestHelpers, type: :controller
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/presenters}
  config.include ActiveSupport::Testing::TimeHelpers
  config.include JsonSpec::Helpers
  config.include CCLF::BillScenarioHelpers, type: :adapter

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  WebMock.disable_net_connect!(allow_localhost: true)

  config.before :each, geckoboard: true do
    stub_request(:get, "https://api.geckoboard.com/").
        with(headers: { 'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=> /Geckoboard-Ruby\/0\.[\d]+(\.[\d])*/ }).
        to_return(status: 200, body: "", headers: {})
  end

  config.before :each, slack_bot: true do
    allow(Settings.slack).to receive(:bot_url).and_return('https://hooks.slack.com/services/fake/endpoint')
    allow(Settings.slack).to receive(:channel).and_return('#monitoring')
    allow(Settings.slack).to receive(:bot_name).and_return('monitor_bot')
    allow(Settings.slack).to receive(:success_icon).and_return(':good_icon:')
    allow(Settings.slack).to receive(:fail_icon).and_return(':bad_icon:')
    stub_request(:post, 'https://hooks.slack.com/services/fake/endpoint').to_return(status: 200, body: '', headers: {})
  end
  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    FactoryBot.create(:vat_rate, :for_2011_onward)
  end

  config.after(:suite) do
    FileUtils.rm_rf('./public/assets/test/images/') #to delete files from filesystem that were generated during rspec tests
    VatRate.delete_all
  end

  config.before(:each) do |example|
    if example.metadata[:delete]
      DatabaseCleaner.strategy = :truncation, {:except => ['vat_rates']}
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
