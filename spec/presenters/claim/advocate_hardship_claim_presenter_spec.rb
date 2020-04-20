require 'rails_helper'
require_relative 'shared_examples_for_claim_presenters'

RSpec.describe Claim::AdvocateHardshipClaimPresenter, type: :presenter do
  subject(:presenter) { described_class.new(claim, view) }

  let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_10) }

  it { is_expected.to be_kind_of(Claim::BaseClaimPresenter) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Hardship') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_hardship') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#can_have_expenses?' do
    specify { expect(presenter.can_have_expenses?).to be_truthy }
  end

  describe '#requires_interim_claim_info?' do
    subject { presenter.requires_interim_claim_info? }

    before { seed_fee_schemes }

    context 'when claim is pre agfs reform' do
      let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_9) }

      it { is_expected.to be_falsey }
    end

    context 'when claim is post agfs reform' do
      let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_10) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#summary_sections' do
    subject { presenter.summary_sections }

    it {
      is_expected.to eq({
        case_details: :case_details,
        defendants: :defendants,
        offence_details: :offence_details,
        basic_fees: :basic_fees,
        misc_fees: :miscellaneous_fees,
        expenses: :travel_expenses,
        supporting_evidence: :supporting_evidence,
        additional_information: :supporting_evidence
      })
    }
  end

  include_examples 'common basic fees presenters'
end
