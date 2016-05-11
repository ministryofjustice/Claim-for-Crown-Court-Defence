require 'rails_helper'

RSpec.describe Claim::LitigatorClaimPresenter do

  let(:claim) { create :claim, disbursements_total: 1.346, case_concluded_at: Time.utc(2015, 12, 31, 20, 15) }
  subject { Claim::LitigatorClaimPresenter.new(claim, view) }

  it { expect(subject).to be_instance_of(Claim::LitigatorClaimPresenter) }
  it { expect(subject).to be_kind_of(Claim::BaseClaimPresenter) }

  describe '#disbursements_total' do
    it 'returns the disbursements total rounded and formatted' do
      expect(subject.disbursements_total).to eq('£1.35')
    end
  end

  describe '#case_concluded_at' do
    it 'returns the case_concluded_at formatted' do
      expect(subject.case_concluded_at).to eq('31/12/2015')
    end
  end

  it 'should have expenses' do
    expect(subject.can_have_expenses?).to eq(true)
  end

  it 'should not have disbursements' do
    expect(subject.can_have_disbursements?).to eq(true)
  end
end
