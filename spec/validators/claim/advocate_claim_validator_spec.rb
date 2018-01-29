require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::AdvocateClaimValidator, type: :validator do
  include_context "force-validation"

  let(:litigator)     { create(:external_user, :litigator) }
  let(:claim)         { create :advocate_claim }

  include_examples "common advocate litigator validations", :advocate

  context 'case concluded at date' do
    let(:claim)    { build :claim }

    it 'is valid when absent' do
      expect(claim.case_concluded_at).to be_nil
      claim.valid?
      expect(claim.errors.key?(:case_concluded_at)).to be false
    end

    it 'is invalid when present' do
      claim.case_concluded_at = 1.month.ago
      expect(claim).not_to be_valid
      expect(claim.errors[:case_concluded_at]).to eq([ 'present' ])
    end
  end

  context 'external_user' do
    it 'should error when does not have advocate role' do
      claim.external_user = litigator
      should_error_with(claim, :external_user, "must have advocate role")
    end

    it 'should error if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user, "blank_advocate")
    end

    it 'should error if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, :advocate)
      claim.external_user = create(:external_user, :advocate)
      should_error_with(claim, :external_user, "Creator and advocate must belong to the same provider")
    end
  end

  context 'creator' do
    before { claim.creator = litigator }

    it 'should error when their provider does not have AGFS role' do
      should_error_with(claim, :creator, "must be from a provider with permission to submit AGFS claims")
    end

    context 'when validation has been overridden' do
      before { claim.disable_for_state_transition = :all }

      it { expect(claim.valid?).to be true }
    end
  end

  context 'supplier_number' do
    # NOTE: In reality supplier number is derived from external_user which in turn is validated in any event
    let(:advocate)  { build(:external_user, :advocate, supplier_number: '9G606X') }
    it 'should error when the supplier number does not match pattern' do
      claim.external_user = advocate
      should_error_with(claim, :supplier_number, 'invalid')
    end
  end

  context 'advocate_category' do
    it 'should error if not present' do
      claim.advocate_category = nil
      should_error_with(claim, :advocate_category,"blank")
    end

    it 'should error if not in the available list' do
      claim.advocate_category = 'not-a-QC'
      should_error_with(claim, :advocate_category, "Advocate category must be one of those in the provided list")
    end

    valid_entries = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
    valid_entries.each do |valid_entry|
      it "should not error if '#{valid_entry}' specified" do
        claim.advocate_category = valid_entry
        should_not_error(claim, :advocate_category)
      end
    end
  end

  context 'offence' do
    before { claim.offence = nil }

    it 'should error if not present for non-fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(false)
      should_error_with(claim, :offence, "blank")
    end

    it 'should NOT error if not present for fixed fee case types' do
      allow(claim.case_type).to receive(:is_fixed_fee?).and_return(true)
      should_not_error(claim,:offence)
    end
  end

  context 'defendant uplift fees aggregation validation' do
    include_context 'step-index', 2

    let(:miaph) { create(:misc_fee_type, :miaph) }
    let(:miahu) { create(:misc_fee_type, :miahu) }
    let(:midtw) { create(:misc_fee_type, :midtw) }
    let(:midwu) { create(:misc_fee_type, :midwu) }
    let(:misc_fee) { claim.misc_fees.find_by(fee_type_id: miaph.id) }

    before do
      claim.misc_fees.delete_all
      create(:misc_fee, fee_type: miaph, claim: claim, quantity: 1, rate: 25.1)
      claim.reload
    end

    it 'test setup' do
      expect(claim.defendants.size).to eql 1
      expect(claim.misc_fees.size).to eql 1
      expect(claim.misc_fees.first.fee_type).to have_attributes(unique_code: 'MIAPH')
    end

    context 'with 1 defendant' do
      context 'when there are 0 uplifts' do
        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }).to eql(%w[MIAPH])
        end

        it 'should not error' do
          should_not_error(claim, :base)
        end
      end

      context 'when there is 1 miscellanoues fee uplift' do
        before do
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
        end

        it 'should error' do
          should_error_with(claim, :base, 'defendant_uplifts_mismatch')
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

      context 'when there is 1 basic fee uplift' do
        before do
          create(:basic_fee, :ndr_fee, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.basic_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[BANDR])
        end

        it 'should error' do
          should_error_with(claim, :base, 'defendant_uplifts_mismatch')
        end
      end


      context 'with 2 defendants' do
        before do
          create(:defendant, claim: claim)
          create(:misc_fee, fee_type: midtw, claim: claim, quantity: 1, amount: 21.01)
        end

        context 'when there are multiple uplifts of 1 per fee type' do
          before do
            create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 1, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH MIDTW MIDWU])
          end

          it 'should not error' do
            should_not_error(claim, :base)
          end
        end

        context 'when there are multiple uplifts of 2 (or more) per fee type' do
          before do
            create(:misc_fee, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
            create(:misc_fee, fee_type: midwu, claim: claim, quantity: 2, amount: 21.01)
          end

          it 'test setup' do
            expect(claim.defendants.size).to eql 2
            expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH MIDTW MIDWU])
          end

          it 'should add one error only' do
            should_error_with(claim, :base, 'defendant_uplifts_mismatch')
            expect(claim.errors[:base].size).to eql 1
          end
        end
      end

      context 'defendant uplifts fee marked for destruction' do
        before do
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 1
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
          expect(claim).to be_invalid
        end

        it 'are ignored' do
          miahu_fee = claim.fees.joins(:fee_type).where(fee_type: { unique_code: 'MIAHU' }).first
          claim.update_attributes(
            :misc_fees_attributes => {
              '0' => {
                'id' => miahu_fee.id,
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
          create(:misc_fee, fee_type: miahu, claim: claim, quantity: 1, amount: 21.01)
        end

        it 'test setup' do
          expect(claim.defendants.size).to eql 2
          expect(claim.misc_fees.map { |f| f.fee_type.unique_code }.sort).to eql(%w[MIAHU MIAPH])
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

  include_examples 'common partial validations', [
      %i[
          case_type
          court
          case_number
          transfer_court
          transfer_case_number
          advocate_category
          offence
          estimated_trial_length
          actual_trial_length
          retrial_estimated_length
          retrial_actual_length
          trial_cracked_at_third
          trial_fixed_notice_at
          trial_fixed_at
          trial_cracked_at
          first_day_of_trial
          trial_concluded_at
          retrial_started_at
          retrial_concluded_at
          case_concluded_at
          supplier_number
      ],
      [],
      %i[
        total
        defendant_uplifts
      ]
  ]
end
