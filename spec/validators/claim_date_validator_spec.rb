require 'rails_helper'

describe ClaimDateValidator do

  let(:cracked_case_type)                 { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked Trial"  }
  let(:cracked_before_retrial_case_type)  { FactoryGirl.build :case_type, :requires_cracked_dates, name: "Cracked before retrial" }
  let(:contempt_case_type)                { FactoryGirl.build :case_type, :requires_trial_dates,    name: 'Contempt'}

  let(:claim)                             { FactoryGirl.create :claim }
  let(:cracked_trial_claim) do
    claim = FactoryGirl.create :claim, case_type: cracked_case_type
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end

  let(:cracked_before_retrial_claim) do
    claim = FactoryGirl.create :claim, case_type: cracked_before_retrial_case_type
    nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
  end

  before do
    claim.force_validation = true
    cracked_trial_claim.force_validation = true
    cracked_before_retrial_claim.force_validation = true
  end

  context 'trial_fixed_notice_at' do
    context 'cracked_trial_claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_notice_at, 'blank_cracked_trial_date') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    it 'should error if not present for Cracked before retrial' do
      expect(cracked_before_retrial_claim.valid?).to be false
      expect(cracked_before_retrial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'blank_cracked_before_retrial_date' ])
    end

    it 'should error if in the future' do
      cracked_trial_claim.trial_fixed_notice_at = 3.days.from_now.to_date
      expect(cracked_trial_claim.valid?).to be false
      expect(cracked_trial_claim.errors[:trial_fixed_notice_at]).to eq( [ 'check_cracked_trial_date' ])
    end

    context 'cracked_before_retrial claim' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_notice_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'trial fixed at' do
    context 'cracked trial claim' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_at, 'blank_cracked_trial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_fixed_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_fixed_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_fixed_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_fixed_at, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'trial cracked at' do
    context 'cracked trial' do
      it { should_error_if_not_present(cracked_trial_claim, :trial_cracked_at, 'blank_cracked_trial_date') }
      it { should_error_if_in_future(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_trial_claim, :trial_cracked_at, 'check_cracked_trial_date') }
      it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'check_cracked_trial_date') }
    end

    context 'cracked before retrial' do
      it { should_error_if_not_present(cracked_before_retrial_claim, :trial_cracked_at, 'blank_cracked_before_retrial_date') }
      it { should_error_if_in_future(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_not_too_far_in_the_past(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_earliest_repo_date(cracked_before_retrial_claim, :trial_cracked_at, 'check_cracked_before_retrial_date') }
      it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'check_cracked_before_retrial_date') }
    end
  end

  context 'first day of trial' do
    let(:contempt_claim_with_nil_first_day) { nulify_fields_on_record(FactoryGirl.create(:claim, case_type: contempt_case_type), :first_day_of_trial) }
    before { contempt_claim_with_nil_first_day.force_validation = true }
    it { should_error_if_not_present(contempt_claim_with_nil_first_day, :first_day_of_trial, "blank")  }
    it { should_errror_if_later_than_other_date(contempt_claim_with_nil_first_day, :first_day_of_trial, :trial_concluded_at, "blank") }
    it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_first_day, :first_day_of_trial, 'blank') }
    it { should_error_if_not_too_far_in_the_past(contempt_claim_with_nil_first_day, :first_day_of_trial, 'blank') }
  end

  context 'trial_concluded_at' do
    let(:contempt_claim_with_nil_concluded_at) { nulify_fields_on_record(FactoryGirl.create(:claim, case_type: contempt_case_type), :trial_concluded_at) }
    before { contempt_claim_with_nil_concluded_at.force_validation = true }
    it { should_error_if_not_present(contempt_claim_with_nil_concluded_at, :trial_concluded_at, "blank") }
    it {should_error_if_earlier_than_other_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, :first_day_of_trial, "blank") }
    it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'blank') }
    it { should_error_if_not_too_far_in_the_past(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'blank') }
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
  expect(record.errors[field]).to include(message)
end

def should_error_if_in_future(record, field, message)
  record.send("#{field}=", 2.days.from_now)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to include(message)
end

def should_error_if_not_too_far_in_the_past(record, field, message)
  record.send("#{field}=", 61.months.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to include(message)
end

def should_error_if_earlier_than_earliest_repo_date(record, field, message)
  repo = double RepresentationOrder
  allow(record).to receive(:earliest_representation_order).and_return(repo)
  allow(repo).to receive(:representation_order_date).and_return(1.year.ago.to_date)
  record.send("#{field}=", 13.months.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to include(message)
end

def should_error_if_earlier_than_other_date(record, field, other_date, message)
  record.send("#{field}=", 5.day.ago)
  record.send("#{other_date}=", 3.day.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to include(message)
end

def should_errror_if_later_than_other_date(record, field, other_date, message)
  record.send("#{field}=", 5.day.ago)
  record.send("#{other_date}=", 7.day.ago)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to include(message)
end



















