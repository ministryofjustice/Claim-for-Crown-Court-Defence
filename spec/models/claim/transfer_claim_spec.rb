require "rails_helper"
require "custom_matchers"

describe Claim::TransferClaim, type: :model do

  let(:claim) { build :transfer_claim }

  it "Delegates attributes to transfer details" do
    claim.attributes = { litigator_type: "new", elected_case: false, transfer_stage_id: 1, transfer_date: Time.now, case_conclusion_id: 1 }
    claim.save
    expect(claim.litigator_type).to eq("new")
    expect(claim.transfer_detail.litigator_type).to eq("new")
  end

  context "New unsaved transfer claim" do
    it "Has a transfer detail" do
      expect(claim.transfer_detail).not_to be_nil
      expect(claim.transfer_detail).to be_a(Claim::TransferDetail)
    end
  end

  describe '#eligible_case_types' do
    it 'should return only Interim case types' do
      CaseType.delete_all

      c1 = create :case_type, name: 'AGFS case type', roles: ['agfs']
      c2 = create :case_type, name: 'LGFS case type', roles: ['lgfs']
      c3 = create :case_type, name: 'LGFS and Interim case type', roles: %w(lgfs interim)
      c4 = create :case_type, name: 'AGFS, LGFS and Interim case type', roles: %w(agfs lgfs interim)

      expect(claim.eligible_case_types).not_to include(c1)
      expect(claim.eligible_case_types).to include(c2)
      expect(claim.eligible_case_types).to include(c3)
      expect(claim.eligible_case_types).to include(c4)
    end
  end

  describe '#vat_registered?' do
    it 'returns the value from the provider' do
      expect(claim.provider).to receive(:vat_registered?)
      claim.vat_registered?
    end
  end
end
