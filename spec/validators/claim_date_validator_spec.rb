require 'rails_helper'

describe ClaimDateValidator do 

  
  let(:cracked_case_type)                 { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked Trial"  }
  let(:cracked_before_retrial_case_type)  { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked before retrial" }

  let(:claim)                             { FactoryGirl.build :claim, force_validation: true }
  let(:cracked_trial_claim) do 
    claim = FactoryGirl.build :claim, force_validation: true, case_type: cracked_case_type
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end

  let(:cracked_before_retrial_claim) do  
    claim = FactoryGirl.build :claim, force_validation: true, case_type: cracked_before_retrial_case_type 
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end


  context 'trial_fixed_notice_at' do
    context 'cracked_trial_claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_notice_at, 'Please enter valid date notice of first fixed/warned issued') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be earlier than the first representation order date') }
    end

    context 'cracked_before_retrial claim' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Please enter valid date notice of first fixed/warned issued') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Date notice of first fixed/warned issued may not be earlier than the first representation order date') }
    end
  end

  context 'trial fixed at' do
    context 'cracked trial claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_at, 'Please enter valid date first fixed/warned') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_fixed_at, 'Date first fixed/warned may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_fixed_at, 'Date first fixed/warned may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_at, 'Date first fixed/warned may not be earlier than the first representation order date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'Date first fixed/warned may not be earlier than the date notice of first fixed/warned issued') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_at, 'Please enter valid date first fixed/warned') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_fixed_at, 'Date first fixed/warned may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_at, 'Date first fixed/warned may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_at, 'Date first fixed/warned may not be earlier than the first representation order date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'Date first fixed/warned may not be earlier than the date notice of first fixed/warned issued') }
    end
  end

  context 'trial cracked at' do
    context 'cracked trial' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_cracked_at, 'Please enter valid date when case cracked') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_cracked_at, 'Date case cracked may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_cracked_at, 'Date case cracked may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_cracked_at, 'Date case cracked may not be earlier than the first representation order date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'Date case cracked may not be earlier than the date notice of first fixed/warned issued') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_cracked_at, 'Please enter valid date when case cracked') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_cracked_at, 'Date case cracked may not be in the future') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_cracked_at, 'Date case cracked may not be older than 5 years') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_cracked_at, 'Date case cracked may not be earlier than the first representation order date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'Date case cracked may not be earlier than the date notice of first fixed/warned issued') }
    end
  end

  context 'first day of trial' do
    let(:claim_with_nil_first_day)       { nulify_fields_on_record(claim, :first_day_of_trial) }

    it { should_error_if_not_present(claim_with_nil_first_day, :first_day_of_trial, "Please enter a valid date for first day of trial") }
    it { should_errror_if_later_than_other_date(claim, :first_day_of_trial, :trial_concluded_at, "First day of trial must not be after date trial concluded") }
    it { should_error_if_earlier_than_earliest_repo_date(claim, :first_day_of_trial, 'First day of trial must not be earlier than the first representation order date') }
    it { should_error_if_not_too_far_in_the_past(claim, :first_day_of_trial, 'First day of trial must not be more than 5 years ago') }
  end
end


def nulify_fields_on_record(record, *fields)
  fields.each do |field|
    record.send("#{field}=", nil)
  end
  record
end

def should_error_if_not_present(record, field, message)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_error_if_in_future(record, field, message)
  record.send("#{field}=", 2.days.from_now)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_error_if_not_too_far_in_the_past(record, field, message) 
  record.send("#{field}=", 61.months.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_error_if_earlier_than_earliest_repo_date(record, field, message)
  repo = double RepresentationOrder
  allow(record).to receive(:earliest_representation_order).and_return(repo)
  allow(repo).to receive(:representation_order_date).and_return(1.year.ago.to_date)
  record.send("#{field}=", 13.months.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_error_if_earlier_than_other_date(record, field, other_date, message)
  record.send("#{field}=", 5.day.ago)
  record.send("#{other_date}=", 3.day.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_errror_if_later_than_other_date(record, field, other_date, message)
  record.send("#{field}=", 5.day.ago)
  record.send("#{other_date}=", 7.day.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end



















