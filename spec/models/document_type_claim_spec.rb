require 'rails_helper'

RSpec.describe DocumentTypeClaim, type: :model do

  let(:document_type_claim) { create(:document_type_claim) }
  let(:document_type_claim_dup) { document_type_claim.dup }

  it "has a valid factory" do
    expect(create(:document_type_claim)).to be_valid
  end

  it { should belong_to :claim }
  it { should belong_to :document_type }

  it { should validate_presence_of :claim }
  it { should validate_presence_of :document_type }

  it "must have composite unique index on claim_id and document_type_id" do
    expect { document_type_claim_dup.save! }.to raise_error(ActiveRecord::RecordNotUnique,/duplicate key/)
  end

end