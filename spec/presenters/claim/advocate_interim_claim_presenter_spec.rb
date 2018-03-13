require 'rails_helper'

RSpec.describe Claim::AdvocateInterimClaimPresenter, type: :presenter do
  let(:claim) { build(:advocate_interim_claim) }

  subject(:presenter) { described_class.new(claim, view) }

  # TODO: Ideally this should have a
  # it_behaves_like 'a claim presenter'
  # but the spec for the base claim is quite complex to be able
  # to change that pattern. Something to address in the near future

  describe '#pretty_type' do
    specify { expect(presenter.pretty_type).to eq('AGFS Interim') }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_falsey }
  end
end
