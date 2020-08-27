require 'rails_helper'
require_relative 'shared_examples_for_advocate_litigator'
require_relative 'shared_examples_for_step_validators'

RSpec.describe Claim::LitigatorHardshipClaimValidator, type: :validator do
  include_context 'force-validation'

  let(:claim) { create(:litigator_hardship_claim, case_type: create(:case_type, :all_roles, is_fixed_fee: false)) }

  before { seed_fee_schemes }

  include_examples 'common advocate litigator validations', :litigator, case_type: false
  include_examples 'common litigator validations', :hardship_claim

  context 'case_type_id' do
    before { claim.case_type_id = 1 }

    it { should_error_with(claim, :case_type_id, 'present') }
  end

  context 'case_stage' do
    let(:eligible_case_stages) { create_list(:case_stage, 2) }
    let(:ineligible_case_stage) { create(:case_stage, roles: %w[lgfs]) }

    before do
      claim.case_stage = nil
      allow(claim).to receive(:eligible_case_stages).and_return(eligible_case_stages)
    end

    context 'when not present' do
      before { claim.case_stage = nil }

      it { should_error_with(claim, :case_stage, 'blank') }
    end

    context 'when present but ineligible' do
      before { claim.case_stage = ineligible_case_stage }

      it { should_error_with(claim, :case_stage, 'inclusion') }
    end

    context 'when present and eligible' do
      before { claim.case_stage = eligible_case_stages.first }

      it { should_not_error(claim, :case_stage) }
    end
  end
end
