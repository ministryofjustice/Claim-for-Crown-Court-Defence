require "rails_helper"
require "custom_matchers"

describe Claim::TransferClaim, type: :model do

  let(:claim) { build :transfer_claim }

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

      expect(claim.eligible_case_types.sort).to eq([c2, c3, c4].sort)
    end
  end

  it "Delegates attributes to transfer details" do
    claim.attributes = { litigator_type: "new", elected_case: false, transfer_stage_id: 1, transfer_date: Time.now, case_conclusion_id: 1 }
    claim.save
    expect(claim.litigator_type).to eq("new")
    expect(claim.transfer_detail.litigator_type).to eq("new")
  end
end
