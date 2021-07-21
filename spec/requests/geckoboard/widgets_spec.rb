# frozen_string_literal: true

RSpec.shared_examples 'a data generator' do |options|
  context 'when json requested' do
    # rubocop:disable RSpec/AnyInstance
    before do
      allow_any_instance_of(options[:generator]).to receive(:run).and_return(payload)
      get options[:endpoint], headers: { 'Accept' => 'application/json' }
    end
    # rubocop:enable RSpec/AnyInstance

    let(:payload) { { foo: 'bar' } }

    specify { expect(response.content_type).to eq('application/json; charset=utf-8') }
    specify { expect(response.body).to eql(payload.to_json) }
  end
end

RSpec.shared_examples 'an html stats renderer' do |options|
  context 'when html requested' do
    before { get options[:endpoint], headers: { 'Accept' => 'text/html' } }

    specify { expect(response).to render_template(options[:template]) }

    it_behaves_like 'a disabler of view only actions'
  end
end

RSpec.describe 'Widgets', type: :request, allow_forgery_protection: true do
  # rubocop:disable Metrics/MethodLength
  def self.reports
    {
      claims: { endpoint: '/geckoboard_api/widgets/claims',
                generator: Stats::ClaimPercentageAuthorisedGenerator,
                template: nil },
      claim_completion: { endpoint: '/geckoboard_api/widgets/claim_completion',
                          generator: Stats::ClaimCompletionReporterGenerator,
                          template: :nil },
      claim_creation_source: { endpoint: '/geckoboard_api/widgets/claim_creation_source',
                               generator: Stats::ClaimCreationSourceDataGenerator,
                               template: :claim_creation_source },
      claim_submissions: { endpoint: '/geckoboard_api/widgets/claim_submissions',
                           generator: Stats::ClaimSubmissionsDataGenerator,
                           template: :claim_submissions },
      multi_session_submissions: { endpoint: '/geckoboard_api/widgets/multi_session_submissions',
                                   generator: Stats::MultiSessionSubmissionDataGenerator,
                                   template: :multi_session_submissions },
      requests_for_further_info: { endpoint: '/geckoboard_api/widgets/requests_for_further_info',
                                   generator: Stats::RequestForFurtherInfoDataGenerator,
                                   template: :requests_for_further_info },
      time_reject_to_auth: { endpoint: '/geckoboard_api/widgets/time_reject_to_auth',
                             generator: Stats::TimeFromRejectToAuthDataGenerator,
                             template: :time_reject_to_auth },
      completion_rate: { endpoint: '/geckoboard_api/widgets/completion_rate',
                         generator: Stats::CompletionRateDataGenerator,
                         template: :completion_rate },
      time_to_completion: { endpoint: '/geckoboard_api/widgets/time_to_completion',
                            generator: Stats::TimeToCompletionDataGenerator,
                            template: :time_to_completion },
      redeterminations_average: { endpoint: '/geckoboard_api/widgets/redeterminations_average',
                                  generator: Stats::ClaimRedeterminationsDataGenerator,
                                  template: :redeterminations_average },
      money_to_date: { endpoint: '/geckoboard_api/widgets/money_to_date',
                       generator: Stats::MoneyToDateDataGenerator,
                       template: nil },
      money_claimed_per_month: { endpoint: '/geckoboard_api/widgets/money_claimed_per_month',
                                 generator: Stats::MoneyClaimedPerMonthDataGenerator,
                                 template: :money_claimed_per_month }
    }
  end
  # rubocop:enable Metrics/MethodLength

  # needed? has no template!
  describe 'GET #claims' do
    it_behaves_like 'a data generator', reports[:claims]
  end

  # needed? only data generator that uses ClaimReporter?! and has no template
  # describe 'GET #claim_completion' do
  #   it_behaves_like 'a data generator', '/geckoboard_api/widgets/claim_completion', Stats::ClaimCompletionReporterGenerator, :claim_completion
  #   it_behaves_like 'an html stats renderer', '/geckoboard_api/widgets/claim_completion', :claim_completion
  # end

  describe 'GET #claim_creation_source' do
    it_behaves_like 'a data generator', reports[:claim_creation_source]
    it_behaves_like 'an html stats renderer', reports[:claim_creation_source]
  end

  describe 'GET #claim_submissions' do
    it_behaves_like 'a data generator', reports[:claim_submissions]
    it_behaves_like 'an html stats renderer', reports[:claim_submissions]
  end

  describe 'GET #multi_session_submissions' do
    it_behaves_like 'a data generator', reports[:multi_session_submissions]
    it_behaves_like 'an html stats renderer', reports[:multi_session_submissions]
  end

  describe 'GET #requests_for_further_info' do
    it_behaves_like 'a data generator', reports[:requests_for_further_info]
    it_behaves_like 'an html stats renderer', reports[:requests_for_further_info]
  end

  describe 'GET #time_reject_to_auth' do
    it_behaves_like 'a data generator', reports[:time_reject_to_auth]
    it_behaves_like 'an html stats renderer', reports[:time_reject_to_auth]
  end

  describe 'GET #completion_rate' do
    it_behaves_like 'a data generator', reports[:completion_rate]
    it_behaves_like 'an html stats renderer', reports[:completion_rate]
  end

  describe 'GET #time_to_completion' do
    it_behaves_like 'a data generator', reports[:time_to_completion]
    it_behaves_like 'an html stats renderer', reports[:time_to_completion]
  end

  describe 'GET #redeterminations_average' do
    it_behaves_like 'a data generator', reports[:redeterminations_average]
    it_behaves_like 'an html stats renderer', reports[:redeterminations_average]
  end

  # needed? has no template!
  describe 'GET #money_to_date' do
    it_behaves_like 'a data generator', reports[:money_to_date]
  end

  describe 'GET #money_claimed_per_month' do
    it_behaves_like 'a data generator', reports[:money_claimed_per_month]
    it_behaves_like 'an html stats renderer', reports[:money_claimed_per_month]
  end
end
