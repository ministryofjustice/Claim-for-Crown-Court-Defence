# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string
#  last_name                        :string
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

require 'rails_helper'

RSpec.describe Defendant, type: :model do
  it { should belong_to(:claim) }

  describe 'validations' do
    context 'draft claim' do
      before { subject.claim = create(:claim) }

      it { should validate_presence_of(:claim).with_message('blank') }
    end

    context 'non-draft claim' do
      before { subject.claim = create(:submitted_claim) }

      it { should validate_presence_of(:claim).with_message('blank')  }
      it { should validate_presence_of(:first_name).with_message('blank') }
      it { should validate_presence_of(:last_name).with_message('blank')  }
    end

    context 'draft claim from api' do
      before { 
        subject.claim = create(:draft_claim) 
        subject.claim.source = 'api'
      }

      it { should validate_presence_of(:claim).with_message('blank')  }
      it { should validate_presence_of(:first_name).with_message('blank')  }
      it { should validate_presence_of(:last_name).with_message('blank')  }
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

      it 'should not be valid if there are no representation orders' do
        defendant.representation_orders = []
        expect(defendant).not_to be_valid
        expect(defendant.errors).not_to be_blank
      end
    end
  end

  describe '#name' do
    let(:claim) { create(:claim) }
    subject { create(:defendant, first_name: 'Roberto', last_name: 'Smith', claim_id: claim.id) }

    it 'joins first name and last name together' do
      expect(subject.name).to eq('Roberto Smith')
    end
  end
end
