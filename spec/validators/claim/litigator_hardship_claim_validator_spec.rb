require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorHardshipClaimValidator, type: :validator do
  include_context "force-validation"

  let(:claim) { create(:litigator_hardship_claim, case_type: create(:case_type, :all_roles, is_fixed_fee: false)) }

  before { seed_fee_schemes }

  include_examples "common advocate litigator validations", :litigator, case_type: false
  include_examples "common litigator validations", :hardship_claim

  context 'case_type' do
    let(:eligible_case_types) { create_list(:case_type, 2, :all_roles, is_fixed_fee: false) }
    let(:ineligible_case_type) { create(:case_type, :agfs_roles, is_fixed_fee: true) }

    before do
      claim.case_type = nil
      allow(claim).to receive(:eligible_case_types).and_return(eligible_case_types)
    end

    context 'when not present' do
      before { claim.case_type = nil }

      it { should_error_with(claim, :case_type, 'case_type_blank') }
    end

    context 'when present but ineligible' do
      before { claim.case_type = ineligible_case_type }

      it { should_error_with(claim, :case_type, 'inclusion') }
    end

    context 'when present and eligible' do
      before { claim.case_type = eligible_case_types.first }

      it { should_not_error(claim, :case_type) }
    end
  end
end
