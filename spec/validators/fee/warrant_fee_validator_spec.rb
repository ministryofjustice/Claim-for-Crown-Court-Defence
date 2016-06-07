require 'rails_helper'

module Fee
  describe WarrantFee do

    let(:fee) { build :warrant_fee }

    before(:each) do
      allow(fee).to receive(:perform_validation?).and_return(true)
    end

    describe '#amount' do
      it 'should be invalid if absent' do
        allow(fee).to receive(:amount).and_return nil # NOTE: need to mock nil amount as callback will set to 0
        expect(fee).to_not be_valid
        expect(fee.errors[:amount]).to include 'blank'
      end

      it 'should be invalid if less than 0.01 ' do
        fee.amount = 0.00999
        expect(fee).to_not be_valid
        expect(fee.errors[:amount]).to include 'numericality'
      end

    end

    describe '#validate_warrant_issued_date' do
      it 'should be valid if present and in the past' do
        fee.warrant_issued_date = Date.today
        expect(fee).to be_valid
      end

      it 'should be invalid if present and too far in the past' do
        fee.warrant_issued_date = 6.years.ago
        expect(fee).to_not be_valid
        expect(fee.errors[:warrant_issued_date]).to include 'check_not_too_far_in_past'
      end

      it 'should be invalid if present and in the future' do
        fee.warrant_issued_date = 3.days.from_now
        expect(fee).not_to be_valid
        expect(fee.errors[:warrant_issued_date]).to include 'check_not_in_future'
      end

      it 'should be invalid if not present' do
        fee.warrant_issued_date = nil
        expect(fee).not_to be_valid
        expect(fee.errors[:warrant_issued_date]).to eq(['blank'])
      end
    end

    describe '#validate_warrant_executed_date' do

      it 'should raise error if before warrant_issued_date' do
        fee.warrant_executed_date = fee.warrant_issued_date - 1.day
        expect(fee).not_to be_valid
        expect(fee.errors[:warrant_executed_date]).to eq(['warrant_executed_before_issued'])
      end

      it 'should be invalid if present and too far in the past' do
        fee.warrant_executed_date = 6.years.ago
        expect(fee).to_not be_valid
        expect(fee.errors[:warrant_executed_date]).to include 'check_not_too_far_in_past'
      end

      it 'should raise error if in future' do
        fee.warrant_executed_date = 3.days.from_now
        expect(fee).not_to be_valid
        expect(fee.errors[:warrant_executed_date]).to include 'check_not_in_future'
      end

      it 'should not raise error if absent' do
        fee.warrant_executed_date = nil
        expect(fee).to be_valid
      end

      it 'should not raise error if present and in the past' do
        fee.warrant_executed_date = 1.day.ago
        expect(fee).to be_valid
      end
    end
  end
end