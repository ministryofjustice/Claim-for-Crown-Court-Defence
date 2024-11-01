require 'rails_helper'

RSpec.describe SurveyMonkey::Configuration do
  let(:survey_monkey_root) { 'https://surveymonkey.test/v3/' }
  let(:authorization_bearer) { 'abc123' }

  before do
    SurveyMonkey.configure do |config|
      config.root_url = survey_monkey_root
      config.bearer = authorization_bearer
    end
  end

  describe '#register_page' do
    subject(:register) { SurveyMonkey.configure { |config| config.register_page(page_name, id:, collector:) } }

    let(:page_name) { :page_one }
    let(:id) { 123 }
    let(:collector) { :collector_one }

    before { SurveyMonkey.configure { |config| config.register_collector(collector, id: 999) } }

    after do
      SurveyMonkey.configure(&:clear_pages)
      SurveyMonkey.configure(&:clear_collectors)
    end

    context 'with a new page' do
      it do
        register
        expect(SurveyMonkey.page_by_name(page_name).id).to eq(123)
      end
    end

    context 'with an existing page' do
      before { SurveyMonkey.configure { |config| config.register_page(page_name, id: 456, collector:) } }

      it 'replaces an existing page' do
        expect { register }.to change { SurveyMonkey.page_by_name(page_name).id }.from(456).to(123)
      end
    end
  end

  describe '#register_collector' do
    subject(:register) { SurveyMonkey.configure { |config| config.register_collector(collector_name, id:) } }

    after { SurveyMonkey.configure(&:clear_collectors) }

    let(:collector_name) { :collector_one }
    let(:id) { 123 }

    context 'with a new collector' do
      it do
        register
        expect(SurveyMonkey.collector_by_name(collector_name).id).to eq(123)
      end
    end

    context 'with an existing collector with the same name' do
      before { SurveyMonkey.configure { |config| config.register_collector(collector_name, id: 456) } }

      it { expect { register }.to change { SurveyMonkey.collector_by_name(collector_name).id }.from(456).to(123) }
    end
  end
end
