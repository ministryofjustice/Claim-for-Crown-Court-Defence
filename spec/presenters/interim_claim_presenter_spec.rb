require 'rails_helper'

RSpec.describe Claim::InterimClaimPresenter do
  let(:claim) { create :interim_claim }

  subject { described_class.new(claim, view) }

  it { expect(subject).to be_a(Claim::BaseClaimPresenter) }

  it 'has disbursements' do
    expect(subject.can_have_disbursements?).to be(true)
  end
end
