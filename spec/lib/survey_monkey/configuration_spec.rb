require 'rails_helper'

RSpec.describe SurveyMonkey::Configuration do
  let(:survey_monkey_root) { 'https://surveymonkey.test/v3/' }
  let(:authorization_bearer) { 'abc123' }

  before do
    SurveyMonkey.configure do |config|
      config.root_url = survey_monkey_root
      config.bearer = authorization_bearer
      config.register_page(:test_survey, 123)
    end
  end

  describe '#register_page' do
    subject(:register_page) { SurveyMonkey.configure { |config| config.register_page(new_page, new_id) } }

    context 'with the re-registering of the same page name' do
      let(:new_page) { :test_survey }
      let(:new_id) { 456 }

      it 'replaces an existing page' do
        expect { register_page }.to change { SurveyMonkey.page_by_name(new_page).id }.from(123).to(456)
      end
    end
  end

  describe '#register_collector' do
    subject(:register) { SurveyMonkey.configure { |config| config.register_collector(collector_name, id:) } }

    context 'with a new collector' do
      let(:collector_name) { :collector_one }
      let(:id) { 123 }

      before { SurveyMonkey.configure(&:clear_collectors) }

      it do
        register
        expect(SurveyMonkey.collector_by_name(collector_name).id).to eq(123)
      end
    end

    context 'with an existing collector with the same name' do
      let(:collector_name) { :collector_one }
      let(:id) { 123 }

      before { SurveyMonkey.configure { |config| config.register_collector(collector_name, id: 456) } }

      it { expect { register }.to change { SurveyMonkey.collector_by_name(collector_name).id }.from(456).to(123) }
    end
  end
end
