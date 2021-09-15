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

    stub_request(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
  end

  describe '#submit' do
    subject(:submit) { response.submit }

    it 'submits to survey monkey' do
      submit
      expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
        .with(headers: { 'Authorization' => "Bearer #{authorization_bearer}" })
    end

    context 'with a survey response' do
      before do
        SurveyMonkey.configure do |config|
          config.register_page(
            :test_survey, 123_456,
            tasks: { id: 123, answers: { 1 => 505_487_572, 2 => 505_487_573, 3 => 505_487_574 } },
            ratings: { id: 456, answers: { 1 => 599_999_991, 2 => 599_999_992, 3 => 599_999_993, 4 => 599_999_994 } }
          )
        end

        response.add_page(:test_survey, tasks: 2, ratings: 4)
        submit
      end

      it 'submits the survey responses' do
        expect(WebMock).to have_requested(:post, "#{survey_monkey_root}collectors/#{collector_id}/responses")
          .with(body: hash_including(pages: [{ id: '123456', questions: [
                                       { answers: [{ choice_id: '505487573' }], id: '123' },
                                       { answers: [{ choice_id: '599999994' }], id: '456' }
                                     ] }]))
      end
    end
  end

  describe '#add_page' do
    subject(:add_page) { response.add_page(page, **options) }

    let(:page) { :test_survey }
    let(:options) { { tasks: 2, ratings: 4 } }

    before do
      SurveyMonkey.configure do |config|
        config.register_page(
          :test_survey, 123_456,
          tasks: { id: 123, answers: { 1 => 505_487_572, 2 => 505_487_573, 3 => 505_487_574 } },
          ratings: { id: 456, answers: { 1 => 599_999_991, 2 => 599_999_992, 3 => 599_999_993, 4 => 599_999_994 } }
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
