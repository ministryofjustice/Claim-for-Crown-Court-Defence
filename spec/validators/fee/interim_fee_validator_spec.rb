require 'rails_helper'

module Fee
  describe InterimFeeValidator do

    let(:fee) { build :interim_fee }
    let(:disbursement_fee) { build :interim_fee, :disbursement }
    let(:warrant_fee) { build :interim_fee, :warrant }

    before(:each) do
      allow(fee).to receive(:perform_validation?).and_return(true)
      allow(disbursement_fee).to receive(:perform_validation?).and_return(true)
      allow(warrant_fee).to receive(:perform_validation?).and_return(true)
    end

    context 'assume valid fees' do
      it 'fee is valid' do
        expect(fee).to be_valid
      end

      it 'disbursement_fee is valid' do
        expect(disbursement_fee).to be_valid
      end

      it 'disbursement_fee is valid' do
        expect(warrant_fee).to be_valid
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
          warrant_fee.rate = 3
          expect(warrant_fee).not_to be_valid
          expect(warrant_fee.errors[:rate]).to eq ['present']
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
          warrant_fee.quantity = 3
          expect(warrant_fee).not_to be_valid
          expect(warrant_fee.errors[:quantity]).to eq ['present']
        end
      end

      context 'other fee' do
        it 'validates numericality' do
          fee.quantity = -10
          expect(fee).not_to be_valid
          expect(fee.errors[:quantity]).to eq ['invalid']
        end
      end
    end

    describe '#validate_amount' do
      context 'disbursement fee' do
        it 'is invalid if present' do
          disbursement_fee.amount = 3
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:amount]).to eq ['present']
        end
      end

      context 'warrant fee' do
        it 'is invalid if present' do
          warrant_fee.amount = 3
          expect(warrant_fee).not_to be_valid
          expect(warrant_fee.errors[:amount]).to eq ['present']
        end
      end

      context 'other fee' do
        it 'validates numericality' do
          fee.amount = -10
          expect(fee).not_to be_valid
          expect(fee.errors[:amount]).to eq ['invalid']
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

    describe 'validate associated warrant if required' do
      context 'for a warrant interim fee' do
        it 'should validate an existing warrant fee in the claim' do
          allow(warrant_fee.claim).to receive(:warrant_fee).and_return(nil)
          expect(warrant_fee).not_to be_valid
          expect(warrant_fee.errors[:warrant]).to eq ['blank']
        end

        it 'should validate there are no disbursements in the claim' do
          allow(warrant_fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
          expect(warrant_fee).not_to be_valid
          expect(warrant_fee.errors[:disbursements]).to eq ['present']
        end
      end

      context 'for a disbursement interim fee' do
        it 'should validate existing disbursements in the claim' do
          allow(disbursement_fee.claim).to receive(:disbursements).and_return([])
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:disbursements]).to eq ['blank']
        end

        it 'should validate there is no warrant fee in the claim' do
          allow(disbursement_fee.claim).to receive(:warrant_fee).and_return(instance_double(Fee::WarrantFee))
          expect(disbursement_fee).not_to be_valid
          expect(disbursement_fee.errors[:warrant]).to eq ['present']
        end
      end

      context 'for another kind of interim fee' do
        it 'should validate there is no warrant fee in the claim' do
          allow(fee.claim).to receive(:warrant_fee).and_return(instance_double(Fee::WarrantFee))
          expect(fee).not_to be_valid
          expect(fee.errors[:warrant]).to eq ['present']
        end

        it 'should allow having disbursements in the claim' do
          allow(fee.claim).to receive(:disbursements).and_return([instance_double(Disbursement)])
          expect(fee).to be_valid
        end
      end
    end
  end
end
