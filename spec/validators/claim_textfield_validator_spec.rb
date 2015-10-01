require 'rails_helper'

describe ClaimTextfieldValidator do

  let(:claim)                       { FactoryGirl.create :claim, force_validation: true }
  let(:guilty_plea)                 { FactoryGirl.build :case_type, name: 'Guilty plea'}
  let(:contempt)                    { FactoryGirl.build :case_type, :requires_trial_dates, name: 'Contempt' }
  let(:breach_of_crown_court_order) { FactoryGirl.build :case_type, name: 'Breach of Crown Court order'}
  let(:cracked_before_retrial)      { FactoryGirl.build :case_type, name: 'Cracked before retrial'}

  before(:each) do
    claim.estimated_trial_length = 1
    claim.actual_trial_length = 2
  end

  it 'test claim should be valid' do
    expect(claim.valid?).to be true
  end

context '#perform_validation?' do

    let(:claim_with_nil_values) do
      nilify_attributes_for_object(claim,:case_type, :court, :case_number, :advocate_category, :offence, :estimated_trial_length, :actual_trial_length)
      claim.defendants.destroy_all
      claim.fees.destroy_all
      claim.expenses.destroy_all
      claim
    end

    context 'when claim is draft' do

      context 'and validation is forced' do

        before { claim_with_nil_values.force_validation=true }

        it 'should validate presence of case_type, court, case_number, advocate_category, offence' do
          expect(claim_with_nil_values).to_not be_valid
        end
      end

      context 'and validation is NOT forced' do

        before { claim_with_nil_values.force_validation=false }

        context 'and it is coming from the api' do
          before { claim_with_nil_values.source = 'api' }
          it 'should validate presence of case_type, court, case_number, advocate_category, offence' do
            expect(claim_with_nil_values).to_not be_valid
          end
        end

        context 'and it is coming from the web app' do
          before { claim_with_nil_values.source = 'web' }
          it 'should NOT validate presence of case_type, court, case_number, advocate_category, offence' do
            expect(claim_with_nil_values).to be_valid
          end
        end

      end
    end

    context 'when claim is NOT draft' do

      before(:each) do
        claim.force_validation=false
      end

      context 'a submitted claim' do
        before { claim.submit! }
        it 'should error on any state-conditional validations (non-exhaustive test)' do
          nilify_attributes_for_object(claim,:case_type, :court, :case_number, :advocate_category, :offence, :estimated_trial_length, :actual_trial_length)
          expect(claim).to_not be_valid
        end
      end

      context 'an archived_pending_delete claim' do
        before { claim.archive_pending_delete! }
        it 'should NOT validate presence of case_type, court, case_number, advocate_category, offence' do
          nilify_attributes_for_object(claim,:case_type, :court, :case_number, :advocate_category, :offence, :estimated_trial_length, :actual_trial_length)
          expect(claim).to be_valid
        end

      end
    end

  end

  context 'advocate' do
    it 'should error if not present, regardless' do
      claim.force_validation=true
      claim.advocate = nil
      should_error_with(claim, :advocate, "Advocate cannot be blank, you must provide an advocate")
    end
  end

  context 'creator' do
    it 'should error if not present, regardless' do
      claim.force_validation=true
      claim.creator = nil
      should_error_with(claim, :creator, "Creator cannot be blank, you must provide an creator")
    end
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

    # invalid_formats = ['a12345678','A123456789','a12345678','a 1234567','ab1234567','A_1234567','A-1234567']
    invalid_formats = ['a12345678']
    invalid_formats.each do |invalid_format|
      it "should error if invalid format #{invalid_format}" do
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

  context 'trial_cracked_at_third' do
    context 'for cracked trials and cracked before retrials' do
      before { claim.case_type = cracked_before_retrial }
      it 'should error if not present' do
        claim.trial_cracked_at_third = nil
        should_error_with(claim,:trial_cracked_at_third,"Case cracked in cannot be blank for a #{claim.case_type.name}, please inidicate the third in which the case cracked")
      end

      it 'should error if not final third cracked before retrial' do
        claim.trial_cracked_at_third ='first_third'
        should_error_with(claim,:trial_cracked_at_third,"Case cracked in can only be Final Third for trials that cracked before retrial")
      end
    end

    context 'for other case types' do
      it 'should not error if not present' do
        claim.case_type = guilty_plea
        claim.trial_cracked_at_third = nil
        should_not_error(claim, :trial_cracked_at_third)

      end
    end
  end

  context 'amount_assessed' do
    before { claim.submit!; claim.allocate! }

    let(:assessed_claim)  {
     claim.assessment = FactoryGirl.build(:assessment, claim: claim)
     claim
    }

    it 'should NOT error if assessment provided prior to authorise! or part_authorise! transistions' do
      expect{ assessed_claim.authorise! }.to_not raise_error
    end

    it 'should error if NO assessment present and state is transitioned to authorised or part_authorised' do
      expect{ claim.authorise! }.to raise_error
      expect{ claim.part_authorise! }.to raise_error
    end

    it 'should error if authorised claim has assessment zeroized' do
      assessed_claim.authorise!
      assessed_claim.assessment.zeroize!
      expect(assessed_claim).to_not be_valid
      expect(assessed_claim.errors[:amount_assessed]).to eq( ['Amount assessed cannot be zero for claims in state Authorised'] )
    end

    it 'should error if authorised claim has assessment updated to zero' do
      assessed_claim.authorise_part!
      assessed_claim.assessment.update(fees: 0, expenses: 0)
      expect(assessed_claim).to_not be_valid
      expect(assessed_claim.errors[:amount_assessed]).to eq( ['Amount assessed cannot be zero for claims in state Part authorised'] )
    end

    context 'should be valid if amount assessed is zero' do
        %w{ draft allocated refused rejected submitted }.each do |state|
          it "for claims in state #{state}" do
            factory_name = "#{state}_claim".to_sym
            claim = FactoryGirl.create factory_name
            expect(claim.assessment.total).to eq 0
            expect(claim).to be_valid
          end
        end
    end

    context 'should be invalid if amount assessed is not zero' do
      %w{ draft refused rejected submitted }.each do |state|
        factory_name = "#{state}_claim".to_sym
        claim = FactoryGirl.create factory_name
        claim.assessment.fees = 35.22
        it "should error if amount assessed is not zero for #{state}" do
          expect(claim).to_not be_valid
          expect(claim.errors[:amount_assessed]).to eq( ["Amount assessed must be zero for claims in state #{state.humanize}"] )
        end
      end
    end
  end

  context 'evidence_checklist_ids' do

    let(:doc_types) { DocType.all.sample(4).map(&:id) }
    let(:invalid_ids) { ['a','ABC','??','-'] }

    it 'should serialize and deserialize as Array' do
      claim.evidence_checklist_ids = doc_types
      should_not_error(claim,:evidence_checklist_ids)
      claim.save!
      dup = Claim.find claim.id
      expect(dup.evidence_checklist_ids).to eq( doc_types )

    end

    it 'should NOT error if ids are string integers and should exclude blank strings' do
      claim.evidence_checklist_ids = ['9','2',' ']
      should_not_error(claim,:evidence_checklist_ids)
    end

    it 'should NOT error if ids are valid doctype ids' do
      claim.evidence_checklist_ids = doc_types
      should_not_error(claim,:evidence_checklist_ids)
    end

    it "should error if ids are zero or strings" do
      invalid_ids.each do |id|
        claim.evidence_checklist_ids = [id]
        should_error_with(claim,:evidence_checklist_ids,"Evidence checklist ids are of an invalid type or zero, please use valid Evidence checklist ids")
      end
    end

    it 'should error if, and for each, id that is not valid doctype ids' do
      claim.evidence_checklist_ids = [101,1001,200,32]
      expect(claim.valid?).to be false
      expect(claim.errors[:evidence_checklist_ids]).to include(/^Evidence checklist id 101 is invalid, please use valid evidence checklist ids/)
    end

    it 'should throw an exception for anything other than an array' do
      expect {
        claim.evidence_checklist_ids = '1, 45, 457'
        claim.save!
      }.to raise_error ActiveRecord::SerializationTypeMismatch, /Attribute was supposed to be a Array, but was a String. -- "1, 45, 457"/i
    end
  end

end


# local helpers
# ---------------------------------------------
def should_error_with(record, field, message)
  expect(record.valid?).to be false
  expect(record.errors[field]).to eq ([ message ])
end

def should_not_error(record, field)
  expect(record.valid?).to be true
  expect(record.errors[field]).to be_empty
end

def nilify_attributes_for_object(object, *attributes)
  attributes.each do |attribute|
    object.__send__("#{attribute}=", nil)
  end
  object
end
