require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorClaimValidator, type: :validator do
  include_context "force-validation"

  let(:litigator) { build(:external_user, :litigator) }
  let(:claim) { create(:litigator_claim) }

  include_examples "common advocate litigator validations", :litigator
  include_examples "common litigator validations"

  include_examples 'common partial validations', {
    case_details: %i[
      case_type
      court
      case_number
      case_transferred_from_another_court
      transfer_court
      transfer_case_number
      case_concluded_at
    ],
    defendants: [],
    offence_details: %i[offence],
    graduated_fees: %i[actual_trial_length total],
    miscellaneous_fees: %i[defendant_uplifts],
    supporting_evidence: []
  }

  describe '#validate_defendant_uplifts' do
    let(:claim) { create(:litigator_claim, :without_fees) }
    let(:miupl) { create(:misc_fee_type, :miupl) }

    before do
      create(:misc_fee, fee_type: miupl, claim: claim, quantity: 0, amount: 250.01)
      claim.reload
      claim.form_step = :miscellaneous_fees
    end

    it 'test setup' do
      expect(claim.defendants.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type).to have_attributes(unique_code: 'MIUPL')
    end

    context 'with 1 defendant' do
      context 'when there are 0 defendant uplift fees' do
        before { claim.misc_fees.delete_all }

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees).to be_empty
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end
      end

      context 'when there is 1 defendant uplift fee' do
        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIUPL])
        end

        it 'should error' do
          should_error_with(claim, :base, 'lgfs_defendant_uplifts_mismatch')
        end

        context 'when from api' do
          before do
            allow(claim).to receive(:from_api?).and_return true
          end

         it 'should not error' do
            should_not_error(claim, :base)
          end
        end
      end
    end

    context 'with 2 defendants' do
      before do
        create(:defendant, claim: claim)
      end

      context 'when there is 1 defendant uplift fee' do
        it 'test setup' do
          expect(claim.defendants.size).to eql 2
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIUPL])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end
      end

      context 'when there are multiple defendant uplifts (2 or more), per fee type' do
        before do
          create_list(:misc_fee, 2, fee_type: miupl, claim: claim, quantity: 0, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 2
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIUPL MIUPL MIUPL])
        end

        it 'should add one error only' do
          should_error_with(claim, :base, 'lgfs_defendant_uplifts_mismatch')
          expect(claim.errors[:base].size).to eql 1
        end
      end
    end

    context 'defendant uplifts fee marked for destruction' do
      it 'test setup' do
        expect(claim.defendants.size).to eql 1
        expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIUPL])
        expect(claim).to be_invalid
      end

      it 'are ignored' do
        miupl_fee = claim.fees.joins(:fee_type).where(fee_types: { unique_code: 'MIUPL' }).first
        claim.update_attributes(
          :misc_fees_attributes => {
            '0' => {
              'id' => miupl_fee.id,
              '_destroy' => '1'
            }
          }
        )
        expect(claim).to be_valid
      end
    end

    context 'defendants marked for destruction' do
      before do
        create(:defendant, claim: claim)
      end

      it 'test setup' do
        expect(claim.defendants.size).to eql 2
        expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIUPL])
        expect(claim).to be_valid
      end

      it 'are ignored' do
        claim.update_attributes(
          :defendants_attributes => {
            '0' => {
              'id' => claim.defendants.first.id,
              '_destroy' => '1'
            }
          }
        )
        expect(claim).to be_invalid
      end
    end
  end
end
