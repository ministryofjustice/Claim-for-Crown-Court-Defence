require 'rails_helper'

RSpec.describe SurveyMonkey::Response do
  subject(:response) { described_class.new }

  let(:collector_id) { 999 }

  after do
    SurveyMonkey.configure do |config|
      config.clear_pages
      config.clear_collectors
    end
  end

  describe '#submit' do
    subject(:submit) { response.submit }

    let(:response_body) { { id: '10203456789' }.to_json }
    let(:response_status) { 201 }

    let(:survey_monkey_root) { 'https://surveymonkey.test/v3/' }

    before do
      SurveyMonkey.configure do |config|
        config.root_url = survey_monkey_root
        config.bearer = 'authorization_bearer'
        config.register_collector(:test_collector, id: collector_id)
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
      let(:survey_results) { { radio: 2 } }

      before { response.add_page(:test_survey, **survey_results) }

      it 'submits to survey monkey' do
        submit
        expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
          .with(headers: { 'Authorization' => 'Bearer authorization_bearer' })
      end

      it { is_expected.to eq({ id: 10_203_456_789, success: true }) }

      context 'with a radio button response' do
        let(:survey_results) { { radio: 2 } }

        before { submit }

        it 'submits the survey responses' do
          expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
            .with(body: hash_including(pages: [{
                                         id: '123456',
                                         questions: [{ answers: [{ choice_id: '505573' }], id: '123' }]
                                       }]))
        end
      end

      context 'with a checkboxes response' do
        let(:survey_results) { { checkboxes: [1, 3] } }

        before { submit }

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

      before { response.add_page(:test_survey, radio: 1) }

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

      before { response.add_page(:test_survey, radio: 1) }

      it { is_expected.to eq({ success: false, error_code: 1050 }) }
    end
  end

  describe '#add_page' do
    subject(:add_page) { response.add_page(page, **options) }

    let(:page) { :test_survey }
    let(:options) { { tasks: 2, ratings: 4 } }

    before do
      SurveyMonkey.configure do |config|
        config.register_collector(:test_collector, id: collector_id)
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

    context 'with pages for the same collector' do
      before do
        SurveyMonkey.configure do |config|
          config.register_collector(:other_collector, id: 200)
          config.register_page(
            :other_page,
            id: 123_457,
            collector: :test_collector,
            questions: { comment: { id: 789, format: :text } }
          )
        end
        response.add_page(:other_page, comment: 'Boo')
      end

      it { expect { add_page }.not_to raise_error }
    end

    context 'with pages for different collectors' do
      before do
        SurveyMonkey.configure do |config|
          config.register_collector(:other_collector, id: 200)
          config.register_page(
            :other_page,
            id: 123_457,
            collector: :other_collector,
            questions: { comment: { id: 789, format: :text } }
          )
        end
        response.add_page(:other_page, comment: 'Boo')
      end

      it { expect { add_page }.to raise_error(SurveyMonkey::MismatchedCollectors) }
    end
  end
end
