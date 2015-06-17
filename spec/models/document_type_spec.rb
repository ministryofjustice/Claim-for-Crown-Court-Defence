# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe DocumentType, type: :model do

  let(:document_type) { create(:document_type) }
  let(:document_type_dup) { document_type.dup }

  it { should have_many :document_type_claims }

  it "has a valid factory" do
    expect(create(:document_type)).to be_valid
  end

  context "description" do
    it { should validate_presence_of :description }

    it "must be unique" do
      expect { document_type_dup.save! }.to raise_error(ActiveRecord::RecordInvalid,/Description has already been taken/)
    end

    it "is case-insensitive" do
      expect(create(:document_type, description: 'Evidence Test Document')).to be_valid
    end

  end

end
