require 'rails_helper'

module Fee
  describe InterimFeeValidator do

    let(:fee)               { build :interim_fee }
    let(:disbursement_fee)  { build :interim_fee, :disbursement }
    let(:warrant_fee)       { build :interim_fee, :warrant }

    context 'perform_validation true' do
      before(:each) do
        allow(disbursement_fee).to receive(:perform_validation?).and_return(true)
        allow(warrant_fee).to receive(:perform_validation?).and_return(true)
      end

      describe '#validate_quantity' do

        context 'disbursement fee' do
          it 'is invalid if present' do
            disbursement_fee.quantity = 3
            expect(disbursement_fee).not_to be_valid
            expect(disbursement_fee.errors[:quantity]).to eq ['present']
          end

          it 'is valid if absent' do
            expect(disbursement_fee).to be_valid
          end
        end

        context 'warrant fee' do
          it 'is invalid if present' do
            warrant_fee.quantity = 3
            expect(warrant_fee).not_to be_valid
            expect(warrant_fee.errors[:quantity]).to eq ['present']
          end

          it 'is valid if absent' do
            expect(warrant_fee).to be_valid
          end
        end

      end

      describe '#validate_claim' do
        it 'is invalid when no claim' do
          fee.claim = nil
          expect(fee).not_to be_valid
          expect(fee.errors[:claim]).to eq(['blank'])
        end
      end

      describe '#fee_type' do
        it 'is not valid when fee type is not an InterimFeeType' do
          expect {
            fee.fee_type = build(:misc_fee_type)
          }.to raise_error ActiveRecord::AssociationTypeMismatch
        end
      end


      describe '#validate_disbursement_type' do
        context 'warrant interim fee types' do
          it 'is valid when blank for warrant fee types' do
            expect(warrant_fee.disbursement_type).to be_nil
            expect(warrant_fee).to be_valid
          end

          it 'is invalid when present for warrant fee types' do
            warrant_fee.disbursement_type = build(:disbursement_type)
            expect(warrant_fee).not_to be_valid
            expect(warrant_fee.errors[:disbursement_type]).to eq( [ 'present'] )
          end

        end

        context 'non-warrant interim fee types' do
          it 'is valid when present' do
            expect(fee.disbursement_type).not_to be_nil
            expect(fee).to be_valid
          end

          it 'is invalid when absent' do
            fee.disbursement_type = nil
            expect(fee).not_to be_valid
            expect(fee.errors[:disbursement_type]).to eq( ['blank'] )
          end
        end
      end


    end
  end
end
