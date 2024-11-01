require 'rails_helper'

RSpec.describe SurveyMonkey::Response do
  subject(:response) { described_class.new }

  let(:survey_monkey_root) { 'https://surveymonkey.test/v3/' }
  let(:authorization_bearer) { 'abc123' }
  let(:collector_id) { 999 }

  before do
    SurveyMonkey.configure do |config|
      config.root_url = survey_monkey_root
      config.bearer = authorization_bearer
      config.collector_id = collector_id
    end
  end

  describe '#submit' do
    subject(:submit) { response.submit }

    let(:response_body) { { id: '10203456789' }.to_json }
    let(:response_status) { 201 }

    before do
      SurveyMonkey.configure do |config|
        config.register_collector(:test_collector, id: 99)
        config.register_page(
          :test_survey,
          id: 123_456,
          collector: :test_collector,
          questions: {
            radio: { id: 123, format: :radio, answers: { 1 => 505_572, 2 => 505_573, 3 => 505_574 } },
            checkboxes: {
              id: 456, format: :checkboxes,
              answers: { 1 => 591, 2 => 592, 3 => 593, 4 => 594 }
            }
          }
        )
      end

      stub_request(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
        .to_return(body: response_body, status: response_status)
    end

    context 'with a successful response from Survey Monkey' do
      it 'submits to survey monkey' do
        submit
        expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
          .with(headers: { 'Authorization' => "Bearer #{authorization_bearer}" })
      end

      it { is_expected.to eq({ id: 10_203_456_789, success: true }) }

      context 'with a radio button response' do
        before do
          response.add_page(:test_survey, radio: 2)
          submit
        end

        it 'submits the survey responses' do
          expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
            .with(body: hash_including(pages: [{
                                         id: '123456',
                                         questions: [{ answers: [{ choice_id: '505573' }], id: '123' }]
                                       }]))
        end
      end

      context 'with a checkboxes response' do
        before do
          response.add_page(:test_survey, checkboxes: [1, 3])
          submit
        end

        it 'submits the survey responses' do
          expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
            .with(body: hash_including(pages: [{ id: '123456',
                                                 questions: [{ answers: [{ choice_id: '591' }, { choice_id: '593' }],
                                                               id: '456' }] }]))
        end
      end
    end

    context 'with an error response from Survey Monkey' do
      let(:response_body) do
        {
          error: {
            id: '1011',
            name: 'Authorization Error',
            docs: 'https://developer.eu.surveymonkey.com/api/v3/#error-codes',
            message: 'The authorization token provided was invalid.',
            http_status_code: 401
          }
        }.to_json
      end
      let(:response_status) { 401 }

      it { is_expected.to eq({ success: false, error_code: 1011 }) }
    end

    context 'with a server error response from Survey Monkey' do
      let(:response_body) do
        {
          error: {
            id: '1050',
            name: 'Internal Server Error',
            docs: 'https://developer.eu.surveymonkey.com/api/v3/#error-codes',
            message: 'Oh bananas! We couldn’t process your request.',
            http_status_code: 401
          }
        }.to_json
      end
      let(:response_status) { 500 }

      it { is_expected.to eq({ success: false, error_code: 1050 }) }
    end
  end

  describe '#add_page' do
    subject(:add_page) { response.add_page(page, **options) }

    let(:page) { :test_survey }
    let(:options) { { tasks: 2, ratings: 4 } }

    before do
      SurveyMonkey.configure do |config|
        config.register_collector(:test_collector, id: 99)
        config.register_page(
          :test_survey,
          id: 123_456,
          collector: :test_collector,
          questions: {
            tasks: { id: 123, format: :radio, answers: { 1 => 505_572, 2 => 505_573, 3 => 505_574 } },
            ratings: {
              id: 456, format: :radio,
              answers: { 1 => 599_991, 2 => 599_992, 3 => 599_993, 4 => 599_994 }
            }
          }
        )
      end

      stub_request(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
    end

    context 'with a registered page and registered options' do
      it { is_expected.to be_truthy }
    end

    context 'with an unregistered page' do
      let(:page) { :unknown_page }

      it { expect { add_page }.to raise_error(SurveyMonkey::UnregisteredPage) }
    end

    context 'with an unregistered question' do
      let(:options) { { favourite: 6 } }

      it { expect { add_page }.to raise_error(SurveyMonkey::UnregisteredQuestion) }
    end
  end
end
