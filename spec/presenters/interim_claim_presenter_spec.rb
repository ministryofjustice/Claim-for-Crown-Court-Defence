require 'rails_helper'

RSpec.describe Claim::InterimClaimPresenter do

  let(:claim) { create :interim_claim }
  subject { described_class.new(claim, view) }

  it { expect(subject).to be_kind_of(Claim::BaseClaimPresenter) }

  it 'should not have expenses' do
    expect(subject.can_have_expenses?).to eq(false)
  end

  it 'should have disbursements' do
    expect(subject.can_have_disbursements?).to eq(true)
  end
end
