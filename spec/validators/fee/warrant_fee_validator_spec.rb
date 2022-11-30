require 'rails_helper'

RSpec.describe Fee::WarrantFeeValidator, type: :validator do
  let(:fee) { build(:warrant_fee) }

  before do
    allow(fee).to receive(:perform_validation?).and_return(true)
  end

  include_examples 'common LGFS amount validations'
  include_examples 'common warrant fee validations'

  describe '#validate_warrant_issued_date' do
    it 'is valid if present and issued at least 3 months ago' do
      fee.warrant_issued_date = 3.months.ago
      expect(fee).to be_valid
    end
  end

  describe '#validate_warrant_executed_date' do
    it 'is invalid if present and too far in the past' do
      fee.warrant_executed_date = 11.years.ago
      expect(fee).to_not be_valid
      expect(fee.errors[:warrant_executed_date]).to include 'Warrant executed date cannot be too far in the past'
    end
  end
end
