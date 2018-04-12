require 'rails_helper'

RSpec.describe GeckoboardPublisher::InjectionAttemptReport, geckoboard: true do
  it_behaves_like 'geckoboard publishable report'

  # calls to api.geckoboard.com are stubbed in rails_helper in case future reports are generated

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:succeeded, name: 'Succeeded'),
        Geckoboard::NumberField.new(:failed, name: 'Failed'),
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::PercentageField.new(:success_percentage, name: 'Success-Percentage')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) { [ { date: Date.today.iso8601, succeeded: 3, failed: 2, total: 5, success_percentage: 0.6 } ] }

    before do
      create_list(:injection_attempt, 3, :with_success)
      create_list(:injection_attempt, 2, :with_errors)
    end

    include_examples 'returns valid items structure'

    context 'when run' do
      it 'returns expected data item count' do
        expect(subject.size).to eql 1
      end

      it { is_expected.to match_array expected_items }
    end
  end
end
