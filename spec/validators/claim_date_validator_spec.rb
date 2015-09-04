require 'rails_helper'

describe ClaimDateValidator do 

  
  let(:cracked_case_type)                 { FactoryGirl.build :case_type, name: "Cracked Trial" }
  let(:cracked_before_retrial_case_type)  { FactoryGirl.build :case_type, name: "Cracked before retrial" }

  let(:claim)                             { FactoryGirl.build :claim, force_validation: true }
  let(:cracked_trial_claim)               { FactoryGirl.build :claim, force_validation: true, case_type: cracked_case_type }
  let(:cracked_before_retrial_claim)      { FactoryGirl.build :claim, force_validation: true, case_type: cracked_before_retrial_case_type }

  context 'trial_fixed_notice_at' do
    it 'should error if not present for cracked trials' do
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'Please enter valid date notice of first fixed/warned issued' ])
    end

    it 'should error if not present for Cracked before retrial' do
      expect(cracked_before_retrial_claim.valid?).to be false
      expect(cracked_before_retrial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'Please enter valid date notice of first fixed/warned issued' ])
    end

    it 'should error if in the future' do
      cracked_trial_claim.trial_fixed_notice_at = 3.days.from_now.to_date
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'Date notice of first fixed/warned issued may not be in the future' ])
    end

    it 'should error if more than 5 years old' do
      cracked_trial_claim.trial_fixed_notice_at = 61.months.ago.to_date
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'Date notice of first fixed/warned issued may not be older than 5 years' ])
    end

    it 'should error if earlier than the earliest representation order date' do
      repo = double RepresentationOrder
      allow(cracked_trial_claim).to receive(:earliest_representation_order).and_return(repo)
      allow(repo).to receive(:representation_order_date).and_return(1.year.ago.to_date)
      cracked_trial_claim.trial_fixed_notice_at = 13.months.ago.to_date
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'Date notice of first fixed/warned issued may not be earlier than the first representation order date' ])
    end

  end
  
end