require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_fee_validators_spec'

module Fee
  describe InterimFeeValidator do
    include ValidationHelpers

    let(:fee) { build :interim_fee }
    let(:disbursement_fee) { build :interim_fee, :disbursement }
    let(:interim_warrant_fee) { build :interim_fee, :warrant }

    before(:each) do
      allow(fee).to receive(:perform_validation?).and_return(true)
      allow(disbursement_fee).to receive(:perform_validation?).and_return(true)
      allow(interim_warrant_fee).to receive(:perform_validation?).and_return(true)
    end

    context 'assume valid fees' do
      it 'fee is valid' do
        expect(fee).to be_valid
      end

      it 'disbursement_fee is valid' do
        expect(disbursement_fee).to be_valid
      end

      it 'interim_warrant_fee is valid' do
        expect(interim_warrant_fee).to be_valid
      end
    end

    describe '#validate_rate' do
      context 'disbursement fee' do
        it 'is invalid if present' do
          disbursement_fee.rate = 3
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:rate]).to eq ['present']
        end
      end

      context 'warrant fee' do
        it 'is invalid if present' do
          interim_warrant_fee.rate = 3
          expect(interim_warrant_fee).not_to be_valid
          expect(interim_warrant_fee.errors[:rate]).to eq ['present']
        end
      end

      context 'other fee' do
        it 'is invalid if present' do
          fee.rate = 3
          expect(fee).not_to be_valid
          expect(fee.errors[:rate]).to eq ['present']
        end
      end
    end

    describe '#validate_quantity' do
      context 'disbursement fee' do
        it 'is invalid if present' do
          disbursement_fee.quantity = 3
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:quantity]).to eq ['present']
        end
      end

      context 'warrant fee' do
        it 'is invalid if present' do
          interim_warrant_fee.quantity = 3
          expect(interim_warrant_fee).not_to be_valid
          expect(interim_warrant_fee.errors[:quantity]).to eq ['present']
        end
      end

      context 'other fee' do
        it 'numericality, must be between 0 and 999999' do
          # note: before validation hook sets nil to zero
          fee.quantity = nil
          expect(fee).to be_valid

          fee.quantity = 0
          expect(fee).to be_valid

          fee.quantity = 1
          expect(fee).to be_valid

          fee.quantity = 99999
          expect(fee).to be_valid

          fee.quantity = 100000
          expect(fee).to_not be_valid
          expect(fee.errors[:quantity]).to eq ['numericality']

          fee.quantity = -10
          expect(fee).not_to be_valid
          expect(fee.errors[:quantity]).to eq ['numericality']
        end
      end
    end

    describe 'amount validations' do
      include_examples 'common amount validations'

      context 'disbursement fee' do
        it 'is invalid if present' do
          disbursement_fee.amount = 3
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:amount]).to eq ['present']
        end
      end

      context 'warrant fee' do
        it 'is invalid if absent' do
          allow(interim_warrant_fee).to receive(:amount).and_return nil
          expect(interim_warrant_fee).not_to be_valid
          expect(interim_warrant_fee.errors[:amount]).to eq ['blank']
        end
      end
    end

    describe '#fee_type' do
      it 'is not valid when fee type is not an InterimFeeType' do
        expect {
          fee.fee_type = build(:misc_fee_type)
        }.to raise_error ActiveRecord::AssociationTypeMismatch
      end
    end

    describe 'interim warrant fee' do
      it 'should validate there are no disbursements in the claim' do
        allow(interim_warrant_fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
        expect(interim_warrant_fee).not_to be_valid
        expect(interim_warrant_fee.errors[:disbursements]).to eq ['present']
      end
    end

    describe 'disbursement only interim fee' do
      it 'should validate existence of disbursements in the claim' do
        allow(disbursement_fee.claim).to receive(:disbursements).and_return([])
        expect(disbursement_fee).not_to be_valid
        expect(disbursement_fee.errors[:disbursements]).to eq ['blank']
      end
    end

    describe 'any other interim fee type' do
      it 'should allow having disbursements in the claim' do
        allow(fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
        expect(fee).to be_valid
      end
    end

    describe 'common warrant fee validations' do
      # TODO: share these with warrant fee validator spec

      let(:fee) { interim_warrant_fee }

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
          expect(fee.errors[:warrant_issued_date]).to eq( [ 'blank' ] )
        end
      end

      describe '#validate_warrant_executed_date' do

        it 'should raise error if before warrant_issued_date' do
          fee.warrant_executed_date = fee.warrant_issued_date - 1.day
          expect(fee).not_to be_valid
          expect(fee.errors[:warrant_executed_date]).to eq( [ 'warrant_executed_before_issued'] )
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
end
