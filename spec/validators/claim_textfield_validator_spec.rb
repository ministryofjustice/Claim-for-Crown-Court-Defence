require 'rails_helper'

describe ClaimTextfieldValidator do

  let(:claim)                 { FactoryGirl.build :unpersisted_claim, force_validation: true }
  let(:guilty_plea)           { FactoryGirl.build :case_type, name: 'Guilty plea'}
  let(:contempt)              { FactoryGirl.build :case_type, :requires_trial_dates, name: 'Contempt' }
  let(:breach_of_crown_court_order) { FactoryGirl.build :case_type, name: 'Breach of Crown Court order'}

  before(:each) do
    claim.estimated_trial_length = 1
    claim.actual_trial_length = 2
  end

  it 'test claim should be valid' do
    expect(claim.valid?).to be true
  end

  context 'case_type' do
    it 'should error if not present' do
      claim.case_type = nil
      should_error_with(claim, :case_type, "Case type cannot be blank, you must select a case type")
    end
  end

  context 'court' do
    it 'should error if not present' do
      claim.court = nil
      should_error_with(claim, :court, 'Court cannot be blank, you must select a court' )
    end
  end

  context 'case_number' do
    it 'should error if not present' do
      claim.case_number = nil
      should_error_with(claim, :case_number, "Case number cannot be blank, you must enter a case number")
    end

    invalid_formats = ['a12345678','A123456789','a12345678','a 1234567','ab1234567','A_1234567']
    invalid_formats.each do |invalid_format|
      it "should error if invalid valid format #{invalid_format}" do
        claim.case_number = invalid_format
        should_error_with(claim, :case_number,"Case number must be in format A12345678 (i.e. 1 capital Letter followed by exactly 8 digits)")
      end
    end
  end

  context 'advocate_category' do
    it 'should error if not present' do
      claim.advocate_category = nil
      should_error_with(claim, :advocate_category,"Advocate category cannot be blank, you must select an appropriate advocate category")
    end

    it 'should error if not in the available list' do
      claim.advocate_category = 'not-a-QC'
      should_error_with(claim, :advocate_category,"Advocate category must be one of those in the provided list")
    end

    valid_entries = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
    valid_entries.each do |valid_entry|
      it "should not error if '#{valid_entry}' specified" do
        claim.advocate_category = valid_entry
        should_not_error(claim, :advocate_category)
      end
    end
  end

  context 'offence' do
    it 'should error if not present and case type is not "Breach of Crown Court order"' do
      claim.case_type = guilty_plea
      claim.offence = nil
      should_error_with(claim, :offence, "Offence Category cannot be blank, you must select an offence category")
    end

    it 'should NOT error if not present and case type is "Breach of Crown Court order"' do
      claim.case_type = breach_of_crown_court_order
      claim.offence = nil
      should_not_error(claim,:offence)
    end
  end

  context 'estimated_trial_length' do
    it 'should error if not present and case type requires trial dates' do
      claim.case_type = contempt
      claim.estimated_trial_length = nil
      should_error_with(claim, :estimated_trial_length, "Estimated trial length cannot be blank, you must enter an estimated trial length")
    end

    it 'should NOT error if not present and case type does NOT require trial dates' do
      claim.case_type = guilty_plea
      claim.estimated_trial_length = nil
      should_not_error(claim,:estimated_trial_length)
    end

    it 'should error if less than zero' do
      claim.estimated_trial_length = -1
      should_error_with(claim, :estimated_trial_length, "Estimated trial length must be a whole number (0 or above)")
    end
  end

  context 'actual_trial_length' do
    it 'should error if not present and case type requires trial dates' do
      claim.case_type = contempt
      claim.actual_trial_length = nil
      should_error_with(claim, :actual_trial_length, "Actual trial length cannot be blank, you must enter an actual trial length")
    end

    it 'should NOT error if not present and case type does NOT require trial dates' do
      claim.case_type = guilty_plea
      claim.actual_trial_length = nil
      should_not_error(claim,:actual_trial_length)
    end

    it 'should error if less than zero' do
      claim.actual_trial_length = -1
      should_error_with(claim, :actual_trial_length, "Actual trial length must be a whole number (0 or above)")
    end
  end

end

# local helpers
# ---------------------------------------------
def should_error_with(record, field, message)
  expect(record.valid?).to be false
  expect(record.errors[field]).to eq( [ message ])
end

def should_not_error(record, field)
  expect(record.valid?).to be true
  expect(record.errors[field]).to be_empty
end
