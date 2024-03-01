require 'rails_helper'

RSpec.describe SurveyMonkey::Question do
  describe '.create' do
    subject { described_class.create(123, format, **options) }

    context 'with a radio question' do
      let(:format) { :radio }
      let(:options) { { answers: { one: 505_572, two: 505_573, three: 505_574 } } }

      it { is_expected.to be_a described_class::Radio }
    end

    context 'with a checkboxes question' do
      let(:format) { :checkboxes }
      let(:options) { { answers: { one: 505_572, two: 505_573, three: 505_574 } } }

      it { is_expected.to be_a described_class::Checkboxes }
    end

    context 'with a text question' do
      let(:format) { :text }
      let(:options) { {} }

      it { is_expected.to be_a described_class::Text }
    end
  end
end
