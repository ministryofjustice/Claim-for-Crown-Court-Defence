require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter, type: :presenter do
  let(:claim) { build(:advocate_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Final') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_final') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  specify {
    expect(presenter.summary_sections).to eq({
      case_details: :case_details,
      defendants: :defendants,
      offence_details: :offence_details,
      basic_fees: :basic_fees,
      fixed_fees: :fixed_fees,
      misc_fees: :miscellaneous_fees,
      expenses: :travel_expenses,
      supporting_evidence: :supporting_evidence,
      additional_information: :supporting_evidence
    })
  }
end
