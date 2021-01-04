require 'rails_helper'

RSpec.describe InterimClaimInfoValidator, type: :validator do
  let(:info) { build(:interim_claim_info) }

  before do
    allow(info).to receive(:perform_validation?).and_return(true)
  end

  it 'is valid if warrant issued date is not set' do
    info.warrant_issued_date = nil
    expect(info).to be_valid
  end

  it 'is valid if warrant executed date is not set' do
    info.warrant_executed_date = nil
    expect(info).to be_valid
  end

  context 'when a warrant fee was paid in a previous interim claim' do
    let(:info) { build(:interim_claim_info, :with_warrant_fee_paid) }

    describe '#validate_warrant_issued_date' do
      it 'is valid if present and issued at least 3 months ago' do
        info.warrant_issued_date = 3.months.ago
        expect(info).to be_valid
      end

      it 'is invalid if present and too far in the past' do
        info.warrant_issued_date = 11.years.ago
        expect(info).to_not be_valid
        expect(info.errors[:warrant_issued_date]).to include 'check_not_too_far_in_past'
      end

      it 'is invalid if present and in the future' do
        info.warrant_issued_date = 3.days.from_now
        expect(info).not_to be_valid
        expect(info.errors[:warrant_issued_date]).to include 'check_not_in_future'
      end

      it 'is invalid if not present' do
        info.warrant_issued_date = nil
        expect(info).not_to be_valid
        expect(info.errors[:warrant_issued_date]).to eq(['blank'])
      end
    end

    describe '#validate_warrant_executed_date' do
      it 'is invalid if before warrant_issued_date' do
        info.warrant_executed_date = info.warrant_issued_date - 1.day
        expect(info).not_to be_valid
        expect(info.errors[:warrant_executed_date]).to eq(['warrant_executed_before_issued'])
      end

      it 'is invalid if present and too far in the past' do
        info.warrant_executed_date = 11.years.ago
        expect(info).to_not be_valid
        expect(info.errors[:warrant_executed_date]).to include 'check_not_too_far_in_past'
      end

      it 'is invalid if in future' do
        info.warrant_executed_date = 3.days.from_now
        expect(info).not_to be_valid
        expect(info.errors[:warrant_executed_date]).to include 'check_not_in_future'
      end

      it 'is invalid if absent' do
        info.warrant_executed_date = nil
        expect(info).not_to be_valid
        expect(info.errors[:warrant_executed_date]).to include 'blank'
      end

      it 'is valid if present and in the past' do
        info.warrant_executed_date = 1.day.ago
        expect(info).to be_valid
      end
    end
  end
end
