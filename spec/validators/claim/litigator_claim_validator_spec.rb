require 'rails_helper'
require_relative '../validation_helpers'
require_relative 'shared_examples_for_advocate_litigator'

describe Claim::LitigatorClaimValidator do

  include ValidationHelpers
  include_context "force-validation"

  let(:advocate)      { build(:external_user, :advocate) }
  let(:litigator)     { build(:external_user, :litigator) }
  let(:claim)         { create(:litigator_claim) }
  let(:offence)       { build(:offence) }
  let(:offence_class) { build(:offence_class, class_letter: 'X', description: 'Offences of dishonesty in Class F where the value in is in excess of £100,000') }
  let(:misc_offence)  { create(:offence, description: 'Miscellaneous/other', offence_class: offence_class) }

  include_examples "common advocate litigator validations", :litigator

  context 'case concluded at date' do
    let(:claim)    { build :litigator_claim }
    before(:each)  { claim.force_validation = true}

    it 'is invalid when absent' do
      claim.case_concluded_at = nil
      claim.valid?
      expect(claim.errors[:case_concluded_at]).to eq([ 'blank' ])
    end

    it 'is valid when present' do
      claim.case_concluded_at = 1.month.ago
      expect(claim).not_to be_valid
      expect(claim.errors.key?(:case_concluded_at)).to be false
    end
  end

  context 'creator' do
    it 'should error when their provider does not have LGFS role' do
      claim.creator = advocate
      should_error_with(claim, :creator, "must be from a provider with permission to submit LGFS claims")
    end
  end

  context 'advocate_category' do
    it 'should be absent' do
      claim.advocate_category = 'QC'
      should_error_with(claim, :advocate_category, "invalid")
      claim.advocate_category = nil
      expect(claim).to be_valid
    end
  end

  context 'offence' do
    before { claim.offence = nil }

    it 'should error if NOT present for any case type' do
      claim.case_type.is_fixed_fee = false
      should_error_with(claim, :offence, "blank")
      claim.case_type.is_fixed_fee = true
      should_error_with(claim, :offence, "blank")
    end

    it 'should error if NOT a Miscellaneous/other offence' do
      claim.offence = offence
      should_error_with(claim, :offence, "invalid")
    end

    it 'should NOT error if a Miscellaneous/other offence' do
      claim.offence = misc_offence
      expect(claim).to be_valid
    end

  end

end
