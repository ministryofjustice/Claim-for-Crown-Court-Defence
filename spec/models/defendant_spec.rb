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

  describe '#validate_date?' do

    let(:defendant) { Defendant.new(claim: Claim::AdvocateClaim.new(case_type: CaseType.new)) }

    before(:each) do
      expect(defendant).to receive(:perform_validation?).and_return(true)
    end

    
    it 'should return false if there is no associated claim' do
      defendant.claim = nil
      expect(defendant.validate_date?).to be_falsey
    end

    it 'should return false if there is a claim but no case type' do
      defendant.claim.case_type = nil
      expect(defendant.validate_date?).to be_falsey
    end

    it 'should return false if there is a claim with a case type that does not require a date of birth' do
      expect(defendant.claim.case_type).to receive(:requires_defendant_dob?).and_return false
      expect(defendant.validate_date?).to be_falsey
    end

    it 'should return true if there is a claim with a case type that requires a date of birth' do
      expect(defendant.claim.case_type).to receive(:requires_defendant_dob?).and_return true
      expect(defendant.validate_date?).to be true
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

  context 'name presentation methods' do
    let(:claim) { create(:claim) }

    describe '#name' do
      it 'joins first name and last name together' do
        defendant = create(:defendant, first_name: 'Roberto', last_name: 'Smith', claim_id: claim.id)
        expect(defendant.name).to eq('Roberto Smith')
      end

      it 'returns empty string if defendant is uninitialized' do
        defendant = Defendant.new(claim_id: claim.id)
        expect(defendant.name).to eq ' '
      end
    end

    describe '#name and initial' do
      it 'returns initial and surname' do
        defendant = create(:defendant, first_name: 'Roberto', last_name: 'Smith', claim_id: claim.id)
        expect(defendant.name_and_initial).to eq('R. Smith')
      end

      it 'returns empty string if defendant is uninitialised' do
        defendant = Defendant.new(claim_id: claim.id)
        expect(defendant.name_and_initial).to eq ''
      end
    end


  end
end
