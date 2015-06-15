require 'rails_helper'

RSpec.describe EvidenceListItemClaim, type: :model do

  let(:evidence_list_item_claim) { create(:evidence_list_item_claim) }
  let(:evidence_list_item_claim_dup) { evidence_list_item_claim.dup }

  it "has a valid factory" do
    create(:evidence_list_item_claim).should be_valid
  end

  it { should belong_to :claim }
  it { should belong_to :evidence_list_item }

  it { should validate_presence_of :claim }
  it { should validate_presence_of :evidence_list_item }

  it "must have composite unique index on claim_id and evidence_list_item_id" do
    expect { evidence_list_item_claim_dup.save! }.to raise_error(ActiveRecord::RecordNotUnique,/duplicate key/)
  end

end