# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :datetime
#  representation_order_date        :datetime
#  order_for_judicial_apportionment :boolean
#  maat_reference                   :string(255)
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'rails_helper'

RSpec.describe Defendant, type: :model do
  it { should belong_to(:claim) }

  describe 'validations' do
    context 'draft claim' do
      before { subject.claim = create(:claim) }

      it { should validate_presence_of(:claim) }
    end

    context 'non-draft claim' do
      before { subject.claim = create(:submitted_claim) }

      it { should validate_presence_of(:claim) }
      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
      it { should validate_presence_of(:date_of_birth) }
      it { should validate_presence_of(:maat_reference) }
    end
  end

  context 'validate uniqueness of maat_reference scoped by claim_id' do
    it 'should be valid if unique within claim id' do
      claim_1 = FactoryGirl.create :claim
      claim_2 = FactoryGirl.create :claim
      defendant_1 = FactoryGirl.build :defendant, claim: claim_1, maat_reference: 'ABC1234'
      defendant_2 = FactoryGirl.build :defendant, claim: claim_2, maat_reference: 'ABC1234'
      expect(defendant_1).to be_valid
    end

    it 'should not be valid if not unique within claim id' do
      claim_1 = FactoryGirl.create :claim
      defendant_1 = FactoryGirl.create :defendant, claim: claim_1, maat_reference: 'ABC1234'
      defendant_2 = FactoryGirl.build :defendant, claim: claim_1, maat_reference: 'ABC1234'
      expect(defendant_2).not_to be_valid
      expect(defendant_2.errors[:maat_reference]). to eq( ['has already been taken'] )
    end
  end


  context 'MAAT reference number after save' do
    let(:claim) { create(:claim) }
    subject { create(:defendant, first_name: 'John', last_name: 'Smith', claim_id: claim.id, maat_reference: 'abc123') }


    it 'makes MAAT reference name uppercase' do
      expect(subject.maat_reference).to eq('ABC123')
    end
  end

  context 'representation orders' do

    let(:defendant)  { FactoryGirl.create :defendant, claim: FactoryGirl.create(:claim) }

    it 'should be valid if there is one representation order that isnt blank' do
      expect(defendant).to be_valid
    end

    context 'draft claim' do
      it 'should be valid if there is more than one representation order' do
        defendant.representation_orders << FactoryGirl.create(:representation_order)
        expect(defendant).to be_valid
      end
    end

    context 'submitted claim' do
      before do
        defendant.claim = create(:submitted_claim)
        defendant.save
      end

      it 'should not be valid if there is more than one representation order' do
        defendant.representation_orders << FactoryGirl.create(:representation_order)
        expect(defendant).not_to be_valid
        expect(defendant.errors[:representation_order]).to eq [ 'There must be exactly one per defendant' ]
      end

      it 'should not be valid if there are no representation orders' do
        defendant.representation_orders = []
        expect(defendant).not_to be_valid
        expect(defendant.errors[:representation_order]).to eq [ 'There must be exactly one per defendant' ]
      end

      it 'should not be valid if there is one representation order which is blank' do
        defendant = FactoryGirl.build :defendant
        defendant.claim = create(:submitted_claim)
        defendant.representation_orders = [ RepresentationOrder.new ]
        expect(defendant).not_to be_valid
        expect(defendant.errors.full_messages.include?("Representation orders document can't be blank")).to be true
      end
    end

    describe '#representation_order' do
      it 'should return the representation order object' do
        expect(defendant.representation_order).to be_instance_of(RepresentationOrder)
      end
    end
  end

  describe '#name' do
    let(:claim) { create(:claim) }
    subject { create(:defendant, first_name: 'John', last_name: 'Smith', claim_id: claim.id) }

    it 'joins first name and last name together' do
      expect(subject.name).to eq('John Smith')
    end
  end
end
