# frozen_string_literal: true

RSpec.shared_examples 'a data generator' do |options|
  context 'when json requested' do
    before do
      allow(options[:generator]).to receive(:new).and_return(generator_instance)
      allow(generator_instance).to receive(:run).and_return(payload)
      get options[:endpoint], headers: { 'Accept' => 'application/json' }
    end

    let(:generator_instance) { instance_double(options[:generator]) }
    let(:payload) { { foo: 'bar' } }

    specify { expect(response.content_type).to eq('application/json; charset=utf-8') }
    specify { expect(response.body).to eql(payload.to_json) }
  end
end

RSpec.shared_examples 'an html stats table' do |options|
  context 'when html requested' do
    before { get options[:endpoint], headers: { 'Accept' => 'text/html' } }

    specify { expect(response).to render_template(options[:template]) }

    it_behaves_like 'a disabler of view only actions'
  end
end

RSpec.describe 'Widgets', :allow_forgery_protection do
  def self.widgets
    @widgets ||= YAML.unsafe_load_file('spec/fixtures/geckoboard_api_widgets.yaml')
  end

  # needed? has no template!
  describe 'GET #claims' do
    it_behaves_like 'a data generator', widgets[:claims]
  end

  # needed? only data generator that uses ClaimReporter?! and has no template
  # describe 'GET #claim_completion' do
  #   it_behaves_like 'a data generator', '/geckoboard_api/widgets/claim_completion', Stats::ClaimCompletionReporterGenerator, :claim_completion
  #   it_behaves_like 'an html stats table', '/geckoboard_api/widgets/claim_completion', :claim_completion
  # end

  describe 'GET #claim_creation_source' do
    it_behaves_like 'a data generator', widgets[:claim_creation_source]
    it_behaves_like 'an html stats table', widgets[:claim_creation_source]
  end

  describe 'GET #claim_submissions' do
    it_behaves_like 'a data generator', widgets[:claim_submissions]
    it_behaves_like 'an html stats table', widgets[:claim_submissions]
  end

  describe 'GET #multi_session_submissions' do
    it_behaves_like 'a data generator', widgets[:multi_session_submissions]
    it_behaves_like 'an html stats table', widgets[:multi_session_submissions]
  end

  describe 'GET #requests_for_further_info' do
    it_behaves_like 'a data generator', widgets[:requests_for_further_info]
    it_behaves_like 'an html stats table', widgets[:requests_for_further_info]
  end

  describe 'GET #time_reject_to_auth' do
    it_behaves_like 'a data generator', widgets[:time_reject_to_auth]
    it_behaves_like 'an html stats table', widgets[:time_reject_to_auth]
  end

  describe 'GET #completion_rate' do
    it_behaves_like 'a data generator', widgets[:completion_rate]
    it_behaves_like 'an html stats table', widgets[:completion_rate]
  end

  describe 'GET #time_to_completion' do
    it_behaves_like 'a data generator', widgets[:time_to_completion]
    it_behaves_like 'an html stats table', widgets[:time_to_completion]
  end

  describe 'GET #redeterminations_average' do
    it_behaves_like 'a data generator', widgets[:redeterminations_average]
    it_behaves_like 'an html stats table', widgets[:redeterminations_average]
  end

  # needed? has no template!
  describe 'GET #money_to_date' do
    it_behaves_like 'a data generator', widgets[:money_to_date]
  end

  describe 'GET #money_claimed_per_month' do
    it_behaves_like 'a data generator', widgets[:money_claimed_per_month]
    it_behaves_like 'an html stats table', widgets[:money_claimed_per_month]
  end
end
