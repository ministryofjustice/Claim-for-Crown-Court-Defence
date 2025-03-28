require 'rails_helper'

RSpec.describe Claim::BaseClaimValidator, type: :validator do
  let(:claim)                       { create(:claim) }
  let(:guilty_plea)                 { build(:case_type, :fixed_fee, name: 'Guilty plea') }
  let(:contempt)                    { build(:case_type, :requires_trial_dates, name: 'Contempt') }
  let(:retrial)                     { build(:case_type, :retrial) }
  let(:breach_of_crown_court_order) { build(:case_type, name: 'Breach of Crown Court order') }
  let(:cracked_trial)               { build(:case_type, :requires_cracked_dates, name: 'Cracked trial') }
  let(:cracked_before_retrial)      { build(:case_type, :requires_cracked_dates, name: 'Cracked before retrial') }

  before do
    claim.force_validation = true
    claim.estimated_trial_length = 1
    claim.actual_trial_length = 2
  end

  it 'test claim should be valid' do
    expect(claim.valid?).to be true
  end

  context 'transition state dependant validation' do
    let(:invalid_claim) do
      nulify_fields_on_record(claim, :court)
      claim.fees.destroy_all
      claim.expenses.destroy_all
      claim
    end

    context 'when claim is in draft state' do
      context 'during submission' do
        before do
          invalid_claim.defendants.first.update_attribute(:first_name, nil)
          invalid_claim.defendants.first.representation_orders.first.update_attribute(:maat_reference, nil)
          invalid_claim.form_step = :defendants
        end

        context 'of case details' do
          before do
            invalid_claim.form_step = :case_details
          end

          it 'validation is performed on claim' do
            expect { invalid_claim.submit! }.to raise_error StateMachines::InvalidTransition, /reason.*court/i
          end
        end

        it 'validation is performed on defendants sub model' do
          expect { invalid_claim.submit! }.to raise_error StateMachines::InvalidTransition, /reason.*defendant.*first name.*/i
        end

        it 'validation is performed on representation_orders sub-sub-model' do
          expect { invalid_claim.submit! }.to raise_error StateMachines::InvalidTransition, /reason.*representation order.*maat reference.*/i
        end
      end

      context 'when saving as draft' do
        context 'and validation is forced' do
          before { invalid_claim.force_validation = true }

          it 'validation is performed' do
            expect(invalid_claim).to_not be_valid
          end
        end

        context 'and validation is NOT forced' do
          before { invalid_claim.force_validation = false }

          context 'and it is coming from the api' do
            before { invalid_claim.source = 'api' }

            it 'validation is performed' do
              expect(invalid_claim).to_not be_valid
            end
          end

          context 'and it is coming from the web app' do
            before { invalid_claim.source = 'web' }

            it 'validation is NOT performed' do
              expect(invalid_claim).to be_valid
            end
          end
        end
      end
    end

    context 'when claim is in archived_pending_delete state' do
      let(:claim) { create(:archived_pending_delete_claim) }

      before do
        nulify_fields_on_record(claim, :case_type, :court, :case_number, :advocate_category, :offence, :estimated_trial_length, :actual_trial_length)
        claim.force_validation = false
      end

      it 'validation is NOT performed' do
        expect(claim).to be_valid
      end
    end

    context 'when claim is in submitted state' do
      before do
        claim.submit!
        claim.force_validation = false
        nulify_fields_on_record(claim, :case_type, :court, :case_number, :advocate_category, :offence, :estimated_trial_length, :actual_trial_length)
        claim.defendants.destroy_all
        claim.fees.destroy_all
        claim.expenses.destroy_all
      end

      it 'validation is performed' do
        expect(claim).to_not be_valid
      end

      context 'during allocation' do
        it 'validation is NOT performed' do
          expect { claim.allocate! }.to_not raise_error
        end
      end

      context 'during authorisation' do
        before { claim.allocate! }

        context 'when assessment included' do
          it 'raises no errors' do
            claim.assessment.update!(fees: 100.00)
            expect { claim.authorise! }.to_not raise_only_amount_assessed_error
          end
        end

        context 'when assessment NOT included' do
          it 'raises only amount assessed errors' do
            expect { claim.authorise! }.to raise_only_amount_assessed_error
          end
        end
      end

      context 'during part authorisation' do
        before { claim.allocate! }

        context 'when assessment included' do
          it 'raises no errors' do
            claim.assessment.update!(fees: 100.00)
            expect { claim.authorise_part! }.to_not raise_only_amount_assessed_error
          end
        end

        context 'when assessment NOT included' do
          it 'raises only amount assessed errors' do
            expect { claim.authorise_part! }.to raise_only_amount_assessed_error
          end
        end
      end

      context 'during redetermination' do
        before {
          claim.allocate!
          claim.reject!
        }

        it 'validation is NOT performed' do
          expect { claim.redetermine! }.to_not raise_error
        end
      end

      context 'during awaiting_written_reasons' do
        before {
          claim.allocate!
          claim.reject!
        }

        it 'validation is NOT performed' do
          expect { claim.await_written_reasons! }.to_not raise_error
        end
      end

      context 'during refusal' do
        before { claim.allocate! }

        it 'validation is NOT performed' do
          expect { claim.refuse! }.to_not raise_error
        end
      end

      context 'during rejection' do
        before { claim.allocate! }

        it 'validation is NOT performed' do
          expect { claim.reject! }.to_not raise_error
        end
      end

      context 'during deallocation' do
        before { claim.allocate! }

        it 'validation is NOT performed' do
          expect { claim.deallocate! }.to_not raise_error
        end
      end
    end
  end

  context 'total' do
    before do
      allow(claim).to receive(:total).and_return(total)
      claim.form_step = :basic_fees
    end

    context 'when total is not greater than 0' do
      let(:total) { 0.0 }

      it 'errors' do
        should_error_with(claim, :total, 'numericality')
      end
    end

    context 'when total is greater than the max limit' do
      let(:total) { 1_000_123 }

      it 'errors' do
        should_error_with(claim, :total, 'claim_max_amount')
      end
    end
  end

  context 'case_number' do
    it 'errors if not present' do
      claim.case_number = nil
      should_error_with(claim, :case_number, 'Enter a case number')
    end

    context 'with URN format' do
      it 'does not error if valid' do
        claim.case_number = 'ABCDEFGHIJ1234567890'
        expect(claim).to be_valid
      end

      it 'invalid if contains non alphanumeric characters' do
        %w[_ - * ? ,].each do |character|
          claim.case_number = 'KLMNOPQRST134456789' + character
          should_error_with(claim, :case_number, 'Enter a valid case number or URN')
        end
      end

      it 'invalid if the URN is too long' do
        claim.case_number = '1234567890UVWXYZABCDE'
        should_error_with(claim, :case_number, 'Enter a valid case number or URN')
      end
    end

    context 'with T-type format' do
      it 'does not error if valid' do
        claim.case_number = 'T20161234'
        expect(claim).to be_valid
      end

      it 'errors if too short' do
        claim.case_number = 'T2020432'
        should_error_with(claim, :case_number, 'Enter a valid case number')
      end

      it 'errors if too long' do
        claim.case_number = 'T202043298'
        should_error_with(claim, :case_number, 'Enter a valid case number')
      end

      it 'errors if it doesnt start with BAST or U' do
        claim.case_number = 'G20204321'
        should_error_with(claim, :case_number, 'Enter a valid case number')
      end

      it 'upcases the first letter and does not error' do
        claim.case_number = 't20161234'
        expect(claim).to be_valid
        expect(claim.case_number).to eq 'T20161234'
      end

      it 'validates against the regex' do
        %w[A S T U].each do |letter|
          (1990..2020).each do |year|
            %w[0001 1111 9999].each do |number|
              case_number = [letter, year, number].join
              expect(case_number.match(BaseValidator::CASE_NUMBER_PATTERN)).to be_truthy
            end
          end
        end
      end
    end
  end

  context 'estimated_trial_length' do
    it 'errors if not present and case type requires trial dates' do
      claim.case_type = contempt
      claim.estimated_trial_length = nil
      should_error_with(claim, :estimated_trial_length, 'Enter an estimated trial length')
    end

    it 'does not error if not present and case type does NOT require trial dates' do
      claim.case_type = guilty_plea
      claim.estimated_trial_length = nil
      should_not_error(claim, :estimated_trial_length)
    end

    it 'errors if less than zero' do
      claim.case_type = contempt
      claim.estimated_trial_length = -1
      should_error_with(claim, :estimated_trial_length, 'Enter a whole number of days for the estimated trial length')
    end
  end

  context 'actual_trial_length' do
    it 'errors if not present and case type requires trial dates' do
      claim.case_type = contempt
      claim.actual_trial_length = nil
      should_error_with(claim, :actual_trial_length, 'Enter an actual trial length')
    end

    it 'does not error if not present and case type does NOT require trial dates' do
      claim.case_type = guilty_plea
      claim.actual_trial_length = nil
      should_not_error(claim, :actual_trial_length)
    end

    it 'errors if less than zero' do
      claim.case_type = contempt
      claim.actual_trial_length = -1
      should_error_with(claim, :actual_trial_length, 'Enter a whole number of days')
    end
  end

  context 'retrial_estimated_length' do
    it 'errors if not present and case type requires retrial dates' do
      claim.case_type = retrial
      claim.retrial_estimated_length = nil
      should_error_with(claim, :retrial_estimated_length, 'blank')
    end

    it 'does not error if not present and case type does NOT require retrial dates' do
      claim.case_type = guilty_plea
      claim.retrial_estimated_length = nil
      should_not_error(claim, :retrial_estimated_length)
    end

    it 'errors if less than zero' do
      claim.case_type = retrial
      claim.retrial_estimated_length = -1
      should_error_with(claim, :retrial_estimated_length, 'invalid')
    end
  end

  context 'retrial_actual_length' do
    it 'errors if not present and case type requires retrial dates' do
      claim.case_type = retrial
      claim.retrial_actual_length = nil
      should_error_with(claim, :retrial_actual_length, 'blank')
    end

    it 'does not error if not present and case type does NOT require retrial dates' do
      claim.case_type = guilty_plea
      claim.retrial_actual_length = nil
      should_not_error(claim, :retrial_actual_length)
    end

    it 'errors if less than zero' do
      claim.case_type = retrial
      claim.retrial_actual_length = -1
      should_error_with(claim, :retrial_actual_length, 'invalid')
    end
  end

  context 'trial_cracked_at_third' do
    context 'for cracked trials' do
      before { claim.case_type = cracked_trial }

      it 'errors if NOT present' do
        claim.trial_cracked_at_third = nil
        should_error_with(claim, :trial_cracked_at_third, 'Choose which third Case cracked in')
      end

      it 'errors if NOT in expected value list' do
        # NOTE: stored value is snake case
        claim.trial_cracked_at_third = 'Final third'
        should_error_with(claim, :trial_cracked_at_third, 'Choose a valid option for Case cracked in')
      end

      Settings.trial_cracked_at_third.each do |third|
        it "can be \"#{third}\" third for Cracked trials" do
          claim.trial_cracked_at_third = third
          claim.valid?
          expect(claim.errors[:trial_cracked_at_third]).to be_empty
        end
      end
    end

    context 'for cracked before retrial' do
      before { claim.case_type = cracked_before_retrial }

      it 'errors if NOT present' do
        claim.trial_cracked_at_third = nil
        should_error_with(claim, :trial_cracked_at_third, 'Choose which third Case cracked in')
      end

      it 'errors if NOT in expected value list' do
        # NOTE: stored value is snake case
        claim.trial_cracked_at_third = 'Final third'
        should_error_with(claim, :trial_cracked_at_third, 'Choose a valid option for Case cracked in')
      end

      it 'errors if NOT final third' do
        claim.trial_cracked_at_third = 'first_third'
        should_error_with(claim, :trial_cracked_at_third, 'Case cracked in can only be Final Third for trials that cracked before retrial')
      end
    end

    context 'for other case types' do
      before { claim.case_type = guilty_plea }

      it 'does not error if not present' do
        claim.trial_cracked_at_third = nil
        should_not_error(claim, :trial_cracked_at_third)
      end
    end
  end

  context 'amount_assessed' do
    before {
      claim.submit!
      claim.allocate!
    }

    let(:assessed_claim) do
      claim.assessment.update!(fees: 101.22, expenses: 28.55, disbursements: 92.66)
      claim
    end

    it 'does not error if assessment provided prior to authorise! or part_authorise! transistions' do
      expect { assessed_claim.authorise! }.to_not raise_error
    end

    it 'errors if NO assessment present and state is transitioned to authorised or part_authorised' do
      expect { claim.authorise! }.to raise_error(StateMachines::InvalidTransition)
      expect { claim.authorise_part! }.to raise_error(StateMachines::InvalidTransition)
    end

    it 'errors if authorised claim has assessment zeroized' do
      assessed_claim.authorise!
      assessed_claim.assessment.zeroize!
      expect(assessed_claim).to_not be_valid
      expect(assessed_claim.errors[:amount_assessed]).to eq(['Amount assessed cannot be zero for claims in state Authorised'])
    end

    it 'errors if authorised claim has assessment updated to zero' do
      assessed_claim.authorise_part!
      assessed_claim.assessment.update(fees: 0, expenses: 0, disbursements: 0)
      expect(assessed_claim).to_not be_valid
      expect(assessed_claim.errors[:amount_assessed]).to eq(['Amount assessed cannot be zero for claims in state Part authorised'])
    end

    context 'should be valid if amount assessed is zero' do
      %w[draft allocated refused rejected submitted].each do |state|
        it "for claims in state #{state}" do
          factory_name = :"#{state}_claim"
          claim = create(factory_name)
          expect(claim.assessment.total).to eq 0
          expect(claim).to be_valid
        end
      end
    end

    context 'should be invalid if amount assessed is not zero' do
      %w[draft refused rejected submitted].each do |state|
        it "errors if amount assessed is not zero for #{state}" do
          factory_name = :"#{state}_claim"
          claim = create(factory_name)
          claim.assessment.fees = 35.22
          expect(claim).to_not be_valid
          expect(claim.errors[:amount_assessed]).to eq(["Amount assessed must be zero for claims in state #{state.humanize}"])
        end
      end
    end

    context 'when creator has been made invalid' do
      before { assessed_claim.creator = create(:external_user, :litigator) }

      context 'and validation has been overridden' do
        before { assessed_claim.disable_for_state_transition = :all }

        it { expect(assessed_claim.valid?).to be true }
      end

      context 'and validation has been overridden only for amount_assessed' do
        before { assessed_claim.disable_for_state_transition = :only_amount_assessed }

        it { expect(assessed_claim.valid?).to be false }
      end

      context 'and validation has not been overridden' do
        before { assessed_claim.disable_for_state_transition = nil }

        it { expect(assessed_claim.valid?).to be false }
      end
    end
  end

  context 'evidence_checklist_ids' do
    let(:doc_types) { DocType.all.sample(4).map(&:id) }
    let(:invalid_ids) { ['a', 'ABC', '??', '-'] }

    it 'serializes and deserialize as Array' do
      claim.evidence_checklist_ids = doc_types
      should_not_error(claim, :evidence_checklist_ids)
      claim.save!
      dup = Claim::BaseClaim.active.find claim.id
      expect(dup.evidence_checklist_ids).to eq(doc_types)
    end

    it 'does not error if ids are string integers and should exclude blank strings' do
      claim.evidence_checklist_ids = ['6', '3', ' ']
      should_not_error(claim, :evidence_checklist_ids)
    end

    it 'does not error if ids are valid doctype ids' do
      claim.evidence_checklist_ids = doc_types
      should_not_error(claim, :evidence_checklist_ids)
    end

    it 'errors if ids are zero or strings' do
      invalid_ids.each do |id|
        claim.evidence_checklist_ids = [id]
        should_error_with(claim, :evidence_checklist_ids, 'Evidence checklist ids are of an invalid type or zero, please use valid Evidence checklist ids')
      end
    end

    it 'errors if, and for each, id that is not valid doctype ids' do
      claim.evidence_checklist_ids = [101, 1001, 200, 32]
      expect(claim.valid?).to be false
      expect(claim.errors[:evidence_checklist_ids]).to include(/^Evidence checklist id 101 is invalid, please use valid evidence checklist ids/)
    end

    it 'throws an exception for anything other than an array' do
      expect {
        claim.evidence_checklist_ids = '1, 45, 457'
        claim.save!
      }.to raise_error(ActiveRecord::SerializationTypeMismatch, /was supposed to be a Array, but was a String/)
    end

    context 'when evidence_checklist_ids have been made invalid' do
      before { claim.evidence_checklist_ids = [101, 1001, 200, 32] }

      context 'and validation has been overridden' do
        before { claim.disable_for_state_transition = :all }

        it { expect(claim.valid?).to be true }
      end

      describe 'and validation has been overridden for amount_assessed' do
        context 'using the correct symbol' do
          before { claim.disable_for_state_transition = :only_amount_assessed }

          it { expect(claim.valid?).to be true }
        end

        context 'using the wrong symbol' do
          before { claim.disable_for_state_transition = :leave_amount }

          it { expect(claim.valid?).to be false }
        end
      end

      context 'and validation has not been overridden' do
        before { claim.disable_for_state_transition = nil }

        it { expect(claim.valid?).to be false }
      end
    end
  end

  context 'cracked (re)trials' do
    let(:cracked_trial_claim) do
      claim = create(:claim, case_type: cracked_trial)
      nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
    end

    let(:cracked_before_retrial_claim) do
      claim = create(:claim, case_type: cracked_before_retrial)
      nulify_fields_on_record(claim, :trial_fixed_notice_at, :trial_fixed_at, :trial_cracked_at)
    end

    RSpec.shared_examples 'validates trial_fixed_notice_at compared to trial_fixed_at' do
      context 'compared to trial_fixed_at' do
        let(:options) do
          {
            field: :trial_fixed_notice_at,
            other_field: :trial_fixed_at,
            message: 'Date must be 2+ days before the Notice of 1st fixed/warned issued'
          }
        end

        [4, 3, 2].each do |num|
          it { is_expected.to include_field_error_when(options.merge(field_value: 3.days.ago.to_date, other_field_value: num.days.ago.to_date)) }
        end

        it { is_expected.to_not include_field_error_when(options.merge(field_value: 3.days.ago.to_date, other_field_value: 1.day.ago.to_date)) }
      end
    end

    RSpec.shared_examples 'validates trial_fixed_at compared to trial_fixed_notice_at' do
      context 'compared to trial_fixed_notice_at' do
        let(:options) do
          {
            field: :trial_fixed_at,
            other_field: :trial_fixed_notice_at,
            message: 'Date must be 2+ days after Notice of 1st fixed/warned issued'
          }
        end

        [4, 3, 2].each do |num|
          it { is_expected.to include_field_error_when(options.merge(field_value: 3.days.ago.to_date, other_field_value: num.days.ago.to_date)) }
        end

        it { is_expected.to_not include_field_error_when(options.merge(field_value: 5.days.ago.to_date, other_field_value: 7.days.ago.to_date)) }
      end
    end

    before do
      cracked_trial_claim.force_validation = true
      cracked_before_retrial_claim.force_validation = true
    end

    context 'trial_fixed_notice_at' do
      context 'cracked_trial_claim' do
        subject { cracked_trial_claim }

        it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_notice_at, 'Enter a date for Notice of 1st fixed/warned issued') }
        it { should_error_if_in_future(cracked_trial_claim, :trial_fixed_notice_at, 'Notice of 1st fixed/warned issued cannot be in the future') }
        it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_fixed_notice_at, 'Notice of 1st fixed/warned issued cannot be too far in the past') }
        it { should_error_if_after_specified_field(cracked_trial_claim, :trial_fixed_notice_at, :trial_cracked_at, 'Date must be before Case cracked') }
        it { should_error_if_field_dates_match(cracked_trial_claim, :trial_fixed_notice_at, :trial_cracked_at, 'Date must be before Case cracked') }
        it { should_error_if_field_dates_match(cracked_trial_claim, :trial_fixed_notice_at, :trial_fixed_at, 'Date must be 2+ days before the Notice of 1st fixed/warned issued') }

        include_examples 'validates trial_fixed_notice_at compared to trial_fixed_at'
      end

      context 'cracked_before_retrial claim' do
        subject { cracked_before_retrial_claim }

        it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Enter a date for Notice of 1st fixed/warned issued') }
        it { should_error_if_in_future(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Notice of 1st fixed/warned issued cannot be in the future') }
        it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_notice_at, 'Notice of 1st fixed/warned issued cannot be too far in the past') }
        it { should_error_if_after_specified_field(cracked_before_retrial_claim, :trial_fixed_notice_at, :trial_cracked_at, 'Date must be before Case cracked') }
        it { should_error_if_field_dates_match(cracked_before_retrial_claim, :trial_fixed_notice_at, :trial_cracked_at, 'Date must be before Case cracked') }
        it { should_error_if_field_dates_match(cracked_before_retrial_claim, :trial_fixed_notice_at, :trial_fixed_at, 'Date must be 2+ days before the Notice of 1st fixed/warned issued') }

        include_examples 'validates trial_fixed_notice_at compared to trial_fixed_at'
      end
    end

    context 'trial fixed at' do
      context 'cracked trial claim' do
        subject { cracked_trial_claim }

        it { should_error_if_not_present(cracked_trial_claim, :trial_fixed_at, 'Enter a date for 1st fixed/warned trial') }
        it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_fixed_at, '1st fixed/warned trial cannot be too far in the past') }

        include_examples 'validates trial_fixed_at compared to trial_fixed_notice_at'
      end

      context 'cracked before retrial' do
        subject { cracked_before_retrial_claim }

        it { should_error_if_not_present(cracked_before_retrial_claim, :trial_fixed_at, 'Enter a date for 1st fixed/warned trial') }
        it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_fixed_at, '1st fixed/warned trial cannot be too far in the past') }

        include_examples 'validates trial_fixed_at compared to trial_fixed_notice_at'
      end
    end

    context 'trial cracked at' do
      context 'cracked trial' do
        it { should_error_if_not_present(cracked_trial_claim, :trial_cracked_at, 'Enter a date for Case cracked') }
        it { should_error_if_in_future(cracked_trial_claim, :trial_cracked_at, 'Case cracked date cannot be in the future') }
        it { should_error_if_too_far_in_the_past(cracked_trial_claim, :trial_cracked_at, 'Case cracked date cannot be too far in the past') }
        it { should_error_if_earlier_than_other_date(cracked_trial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'Case cracked date cannot be before Notice of 1st fixed/warned issued') }
      end

      context 'cracked before retrial' do
        it { should_error_if_not_present(cracked_before_retrial_claim, :trial_cracked_at, 'Enter a date for Case cracked') }
        it { should_error_if_in_future(cracked_before_retrial_claim, :trial_cracked_at, 'Case cracked date cannot be in the future') }
        it { should_error_if_too_far_in_the_past(cracked_before_retrial_claim, :trial_cracked_at, 'Case cracked date cannot be too far in the past') }
        it { should_error_if_earlier_than_other_date(cracked_before_retrial_claim, :trial_cracked_at, :trial_fixed_notice_at, 'Case cracked date cannot be before Notice of 1st fixed/warned issued') }
      end
    end
  end

  context 'with elected cases not proceeded' do
    subject(:claim) { create(:claim, case_type:, create_defendant_and_rep_order: false) }

    let(:case_type) { build(:case_type, :elected_cases_not_proceeded) }

    context 'with no defendants' do
      it { should_not_error(claim, :earliest_representation_order_date) }
    end

    context 'with no selected case type' do
      let(:case_type) { nil }

      it { should_not_error(claim, :earliest_representation_order_date) }
    end

    context 'when defendant has a rep order before fee scheme 13' do
      before { claim.defendants = create_list(:defendant, 1, scheme: 'scheme 12') }

      it { should_not_error(claim, :earliest_representation_order_date) }
    end

    context 'when defendant has a rep order in fee scheme 13' do
      before { claim.defendants = create_list(:defendant, 1, scheme: 'scheme 13') }

      it { should_error_with(claim, :earliest_representation_order_date, 'invalid for elected case not proceeded and main hearing date') }
    end

    context 'when one defendant of two has a rep order in fee scheme 13' do
      before { claim.defendants = [create(:defendant, scheme: 'scheme 12'), create(:defendant, scheme: 'scheme 13')] }

      it { should_not_error(claim, :earliest_representation_order_date) }
    end

    context 'when two defendants both have rep orders in fee scheme 13' do
      before { claim.defendants = create_list(:defendant, 2, scheme: 'scheme 13') }

      it { should_error_with(claim, :earliest_representation_order_date, 'invalid for elected case not proceeded and main hearing date') }
    end

    context 'when defendant has a rep order in fee scheme 12 and a CLAIR contingency main hearing date' do
      before do
        claim.defendants = create_list(:defendant, 1, scheme: 'scheme 12')
        claim.main_hearing_date = Settings.clair_contingency_date
      end

      it { should_error_with(claim, :earliest_representation_order_date, 'invalid for elected case not proceeded and main hearing date') }
    end

    context 'when defendant has a rep order in fee scheme 12 and a pre-CLAIR contingency main hearing date' do
      before do
        claim.defendants = create_list(:defendant, 1, scheme: 'scheme 12')
        claim.main_hearing_date = Settings.clair_contingency_date - 1
      end

      it { should_not_error(claim, :earliest_representation_order_date) }
    end
  end

  context 'for claims requiring trial details' do
    context 'first day of trial' do
      let(:contempt_claim_with_nil_first_day) { nulify_fields_on_record(create(:claim, case_type: contempt), :first_day_of_trial) }

      before { contempt_claim_with_nil_first_day.force_validation = true }

      it { should_error_if_not_present(contempt_claim_with_nil_first_day, :first_day_of_trial, 'Enter a date for the first day of trial') }
      it { should_error_if_later_than_other_date(contempt_claim_with_nil_first_day, :first_day_of_trial, :trial_concluded_at, 'First day of trial cannot be after the trial has concluded') }
      # it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_first_day, :first_day_of_trial, 'check_not_earlier_than_rep_order', translated_message: 'Check combination of representation order date and trial dates') }
      it { should_error_if_too_far_in_the_past(contempt_claim_with_nil_first_day, :first_day_of_trial, 'First day of trial cannot be too far in the past') }
    end

    context 'trial_concluded_at' do
      let(:contempt_claim_with_nil_concluded_at) { nulify_fields_on_record(create(:claim, case_type: contempt), :trial_concluded_at) }

      before { contempt_claim_with_nil_concluded_at.force_validation = true }

      it { should_error_if_not_present(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'Enter the date on which the trial concluded') }
      it { should_error_if_earlier_than_other_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, :first_day_of_trial, 'Trial concluded cannot be before the First day of trial') }
      it { should_error_if_earlier_than_earliest_repo_date(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'check_not_earlier_than_rep_order', translated_message: 'Check combination of representation order date and trial dates') }
      it { should_error_if_too_far_in_the_past(contempt_claim_with_nil_concluded_at, :trial_concluded_at, 'Trial concluded date cannot be too far in the past') }
    end
  end

  context 'for claims requiring retrial details' do
    subject(:claim) { create(:claim, case_type: retrial) }

    context 'retrial_started_at' do
      context 'when not present' do
        it { should_error_if_not_present(claim, :retrial_started_at, 'Enter a date for the first day of retrial') }
      end

      context 'when later than retrial_concluded_at' do
        it { should_error_if_later_than_other_date(claim, :retrial_started_at, :retrial_concluded_at, 'Check the date for First day of retrial') }
      end

      context 'when earlier than earliest_representation_order_date' do
        it { should_error_if_earlier_than_earliest_repo_date(claim, :retrial_started_at, 'Check the date for First day of retrial') }
      end

      context 'when too far in past' do
        it { should_error_if_too_far_in_the_past(claim, :retrial_started_at, 'First day of retrial cannot be too far in the past') }
      end

      context 'when earlier than trial_concluded_at' do
        it {
          is_expected.to include_field_error_when(
            field: :retrial_started_at, other_field: :trial_concluded_at,
            field_value: 7.days.ago.to_date, other_field_value: 6.days.ago.to_date,
            message: 'First day of retrial cannot be before Trial concluded'
          )
        }
      end

      it 'shoud NOT error if first day of trial is before the claims earliest rep order' do
        stub_earliest_rep_order(claim, 1.month.ago)
        claim.advocate_category = 'KC'
        claim.first_day_of_trial = 2.months.ago
        expect(claim.valid?).to be true
        expect(claim.errors[:retrial_started_at]).to be_empty
      end
    end

    context 'retrial_concluded_at' do
      context 'when not present' do
        it { should_error_if_not_present(claim, :retrial_concluded_at, 'Enter the date on which the retrial concluded') }
      end

      context 'when earlier than retrial_started_at' do
        it { should_error_if_earlier_than_other_date(claim, :retrial_concluded_at, :retrial_started_at, 'Check the date for retrial concluded') }
      end

      context 'when earlier than earliest_representation_order_date' do
        it {
          should_error_if_earlier_than_earliest_repo_date(claim, :retrial_concluded_at, 'Retrial conclusion cannot be before the rep order')
        }
      end

      context 'when to far in past' do
        it { should_error_if_too_far_in_the_past(claim, :retrial_concluded_at, 'Retrial conclusion cannot be too far in the past') }
      end

      it 'shoud NOT error if first day of trial is before the claims earliest rep order' do
        stub_earliest_rep_order(claim, 1.month.ago)
        claim.advocate_category = 'KC'
        claim.first_day_of_trial = 2.months.ago
        expect(claim.valid?).to be true
        expect(claim.errors[:retrial_concluded_at]).to be_empty
      end
    end
  end

  context 'travel expense additional information' do
    subject { claim.valid? }

    context 'for car travel' do
      before do
        claim.expenses.delete_all
        create(:expense, :car_travel, calculated_distance:, mileage_rate_id: mileage_rate, location:, date: 3.days.ago, claim:)
        claim.reload
        claim.form_step = :travel_expenses
      end

      let(:location) { 'Basildon' }

      context 'from the web' do
        context 'when the claim has no additional travel information' do
          let(:additional_travel_info) { nil }

          context 'when the mileage rate is lower' do
            let(:mileage_rate) { 1 }

            context 'and the calculated distance is accepted' do
              let(:calculated_distance) { 27 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is reduced' do
              let(:calculated_distance) { 28 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is increased' do
              let(:calculated_distance) { 26 }

              it { is_expected.to be false }
            end

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end

          context 'when the mileage rate is higher' do
            let(:mileage_rate) { 2 }

            context 'and the location is a Crown Court' do
              let(:establishment) { create(:establishment, :crown_court) }
              let(:location) { establishment.name }

              context 'and the calculated distance is accepted' do
                let(:calculated_distance) { 27 }

                it { is_expected.to be false }
              end

              context 'and the calculated distance is reduced' do
                let(:calculated_distance) { 28 }

                it { is_expected.to be false }
              end

              context 'and the calculated distance is increased' do
                let(:calculated_distance) { 26 }

                it { is_expected.to be false }
              end

              context 'and the calculated distance is nil' do
                let(:calculated_distance) { nil }

                it { is_expected.to be false }
              end
            end

            context 'and the location is a Prison' do
              let(:establishment) { create(:establishment, :prison) }
              let(:location) { establishment.name }

              context 'and the calculated distance is accepted' do
                let(:calculated_distance) { 27 }

                it { is_expected.to be true }
              end

              context 'and the calculated distance is reduced' do
                let(:calculated_distance) { 28 }

                it { is_expected.to be true }
              end

              context 'and the calculated distance is increased' do
                let(:calculated_distance) { 26 }

                # This is still false because the user increased the distance
                it { is_expected.to be false }
              end

              context 'and the calculated distance is nil' do
                let(:calculated_distance) { nil }

                it { is_expected.to be true }
              end
            end

            context 'and the location is a Magistrates court' do
              let(:establishment) { create(:establishment, :magistrates_court) }
              let(:location) { establishment.name }

              context 'and the calculated distance is accepted' do
                let(:calculated_distance) { 27 }

                it { is_expected.to be true }
              end

              context 'and the calculated distance is reduced' do
                let(:calculated_distance) { 28 }

                it { is_expected.to be true }
              end

              context 'and the calculated distance is increased' do
                let(:calculated_distance) { 26 }

                # This is still false because the user increased the distance
                it { is_expected.to be false }
              end

              context 'and the calculated distance is nil' do
                let(:calculated_distance) { nil }

                it { is_expected.to be true }
              end
            end
          end
        end

        context 'when the claim has additional travel information' do
          before { claim.travel_expense_additional_information = 'this is info' }

          context 'when the mileage rate is lower' do
            let(:mileage_rate) { 1 }

            context 'and the calculated distance is accepted' do
              let(:calculated_distance) { 27 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is reduced' do
              let(:calculated_distance) { 28 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is increased' do
              let(:calculated_distance) { 26 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end

          context 'when the mileage rate is higher' do
            let(:mileage_rate) { 2 }

            context 'and the calculated distance is accepted' do
              let(:calculated_distance) { 27 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is reduced' do
              let(:calculated_distance) { 28 }

              it { is_expected.to be true }
            end

            context 'and the calculated distance is increased' do
              let(:calculated_distance) { 26 }

              it { is_expected.to be true }
            end
          end
        end
      end

      context 'from the API' do
        before { claim.source = 'api' }

        context 'when the claim has no additional travel information' do
          let(:additional_travel_info) { nil }

          context 'when the mileage rate is lower' do
            let(:mileage_rate) { 1 }

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end

          context 'when the mileage rate is higher' do
            let(:mileage_rate) { 2 }

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end
        end

        context 'when the claim has additional travel information' do
          before { claim.travel_expense_additional_information = 'this is info' }

          context 'when the mileage rate is lower' do
            let(:mileage_rate) { 1 }

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end

          context 'when the mileage rate is higher' do
            let(:mileage_rate) { 2 }

            context 'and the calculated distance is nil' do
              let(:calculated_distance) { nil }

              it { is_expected.to be true }
            end
          end
        end
      end
    end

    context 'with simulation of duplicated car_travel > parking' do
      before do
        claim.expenses.delete_all
        create(:expense, :parking, calculated_distance: 27, distance: nil, date: 3.days.ago, claim:)
        claim.reload
        claim.form_step = :travel_expenses
      end

      it { is_expected.to be true }
    end
  end
end
