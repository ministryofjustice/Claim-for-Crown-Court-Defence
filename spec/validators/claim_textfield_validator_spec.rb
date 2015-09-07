require 'rails_helper'

describe ClaimTextfieldValidator do

  let(:claim)                 { FactoryGirl.build :unpersisted_claim, force_validation: true }
  let(:guilty_plea)           { FactoryGirl.build :case_type, name: 'Guilty plea'}
  let(:breach_of_crown_court_order) { FactoryGirl.build :case_type, name: 'Breach of Crown Court order'}


  # TODO: keep in model since they are hidden values?
  # context 'advocate' do
  #   skip
  # end

  # context 'creator' do
  #   skip
  # end

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
      should_error_with(claim,:advocate_category,"Advocate category cannot be blank, you must select an appropriate advocate category")
    end

    it 'should error if not in the available list' do
      claim.advocate_category = 'not-a-QC'
      should_error_with(claim,:advocate_category,"Advocate category must be one of those in the provided list")
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
      expect(claim.valid?).to be true
      expect(claim.errors[:offence]).to be_empty
    end
  end

  context 'estimated_trial_length' do
    skip
  end

  context 'actual_trial_length' do
    skip
  end

end

# local helpers
def should_error_with(record, field, message)
  expect(record.send(:valid?)).to be false
  expect(record.errors[field]).to eq( [ message ])
end