require 'rails_helper'


RSpec.describe EvidenceListItem, type: :model do

	let(:evidence_list_item) { create(:evidence_list_item) }
	let(:evidence_list_item_dup) { evidence_list_item.dup }

 	it { should have_many :evidence_list_item_claims }

	it "has a valid factory" do
		expect(create(:evidence_list_item)).to be_valid
	end

	context "description" do

		it { should validate_presence_of :description }

		# note: shoulda-matcher validate_uniqueness_of fails due to two unique columns//attributes
		it "must be unique" do
				evidence_list_item_dup.item_order = evidence_list_item_dup.item_order+1
				expect { evidence_list_item_dup.save! }.to raise_error(ActiveRecord::RecordInvalid,/Description has already been taken/)
		end

		it "is case-insensitive" do
			expect(create(:evidence_list_item, description: 'Evidence Test Document')).to be_valid
		end

	end

	context "item_order" do

		it { should validate_presence_of :item_order }

		# note: shoulda-matcher validate_uniqueness_of fails due to two unique columns//attributes
		it "must be unique" do
			evidence_list_item_dup.description = evidence_list_item_dup.description << 'modifier'
			expect { evidence_list_item_dup.save! }.to raise_error(ActiveRecord::RecordInvalid,/Item order has already been taken/)
		end

	end

end