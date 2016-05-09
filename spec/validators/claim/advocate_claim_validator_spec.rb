require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

describe Claim::AdvocateClaimValidator do

  include ValidationHelpers
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
    it 'should error when their provider does not have AGFS role' do
      claim.creator = litigator
      should_error_with(claim, :creator, "must be from a provider with permission to submit AGFS claims")
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
      should_error_with(claim, :advocate_category,"Advocate category must be one of those in the provided list")
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

  include_examples 'common partial validations', [
      [
          :case_type,
          :court,
          :case_number,
          :advocate_category,
          :offence,
          :estimated_trial_length,
          :actual_trial_length,
          :retrial_estimated_length,
          :retrial_actual_length,
          :trial_cracked_at_third,
          :trial_fixed_notice_at,
          :trial_fixed_at,
          :trial_cracked_at,
          :first_day_of_trial,
          :trial_concluded_at,
          :retrial_started_at,
          :retrial_concluded_at,
          :case_concluded_at
      ],
      [
          :total
      ]
  ]
end
