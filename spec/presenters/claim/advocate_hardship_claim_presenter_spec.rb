require 'rails_helper'
require_relative 'shared_examples_for_claim_presenters'

RSpec.describe Claim::AdvocateHardshipClaimPresenter, type: :presenter do
  subject(:presenter) { described_class.new(claim, view) }

  let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_10) }

  it { is_expected.to be_a(Claim::BaseClaimPresenter) }

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Hardship') }
  end

  describe '#type_identifier' do
    specify { expect(presenter.type_identifier).to eq('agfs_hardship') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end

  describe '#requires_interim_claim_info?' do
    subject { presenter.requires_interim_claim_info? }

    it { is_expected.to be_falsey }
  end

  describe '#mandatory_case_details?' do
    subject { presenter.mandatory_case_details? }

    context 'when case_type, court, case number and provider details present' do
      before do
        allow(claim).to receive(:case_type).and_return 'a case type'
        allow(claim).to receive(:court).and_return 'a court'
        allow(claim).to receive(:case_number).and_return 'a case number'
        allow(claim).to receive(:external_user).and_return instance_double(ExternalUser)
      end

      it { is_expected.to be_truthy }
    end

    context 'when one of case_type, court, case number and provider details present' do
      before do
        allow(claim).to receive(:case_type).and_return nil
        allow(claim).to receive(:court).and_return 'a court'
        allow(claim).to receive(:case_number).and_return 'a case number'
        allow(claim).to receive(:external_user).and_return instance_double(ExternalUser)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#summary_sections' do
    subject { presenter.summary_sections }

    it {
      is_expected.to eq(
        {
          case_details: :case_details,
          defendants: :defendants,
          offence_details: :offence_details,
          basic_fees: :basic_fees,
          misc_fees: :miscellaneous_fees,
          expenses: :travel_expenses,
          supporting_evidence: :supporting_evidence,
          additional_information: :supporting_evidence
        }
      )
    }
  end

  include_examples 'common basic fees presenters'
end
