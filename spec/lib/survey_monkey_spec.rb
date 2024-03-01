require 'rails_helper'

RSpec.describe SurveyMonkey do
  let(:survey_monkey_root) { 'https://surveymonkey.test/v3/' }
  let(:authorization_bearer) { 'abc123' }

  before do
    described_class.configure do |config|
      config.root_url = survey_monkey_root
      config.bearer = authorization_bearer
      config.register_page(:test_survey, 123)
    end
  end

  describe '.page_by_name' do
    subject(:page) { described_class.page_by_name(page_name) }

    context 'with a known page' do
      let(:page_name) { :test_survey }

      it { expect(page.id).to eq(123) }
    end

    context 'with an unknown page' do
      let(:page_name) { :unknown }

      it { expect { page }.to raise_error(described_class::UnregisteredPage) }
    end
  end
end
