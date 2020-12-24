require 'rails_helper'

RSpec.describe 'Advocate interim claim WEB validations' do
  # TODO: this let! is necessary because the fee types are not seeded
  # by default (IMO they should as they're a basic part of the app)
  let!(:warrant_fee_type) { create(:warrant_fee_type, :warr) }
  let!(:parking_expense_type) { create(:expense_type, :parking) }
  let!(:subsistence_expense_type) { create(:expense_type, :subsistence) }
  let!(:offence) { create(:offence, :with_fee_scheme_ten) }
  let(:external_user) { create(:external_user, :advocate) }
  let(:court) { create(:court, name: 'Court Name') }
  let(:attributes) { valid_attributes }
  let(:params) { attributes.merge(form_step: form_step) }

  subject(:claim) { Claim::AdvocateInterimClaim.new(params) }

  before do
    claim.source = 'web'
    claim.force_validation = true
  end

  context 'when submission step is case details' do
    let(:valid_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false
      }
    }
    let(:form_step) { 'case_details' }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'but external user is not set' do
      let(:attributes) { valid_attributes.except(:external_user_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:external_user]).to match_array(['blank_advocate'])
      }
    end

    context 'but external user is not allowed to manage this kind of claim' do
      let(:external_user) { create(:external_user, :litigator) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:external_user]).to match_array(['must have advocate role'])
      }
    end

    context 'but creator is not set' do
      let(:attributes) { valid_attributes.except(:creator_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:creator]).to match_array(['blank'])
      }
    end

    context 'but external user and creator have different providers' do
      let(:other_external_user) { create(:external_user, :advocate) }
      let(:attributes) { valid_attributes.merge(creator_id: other_external_user.id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:external_user]).to match_array(['Creator and advocate must belong to the same provider'])
      }
    end

    context 'but court is not set' do
      let(:attributes) { valid_attributes.except(:court_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:court]).to match_array(['blank'])
      }
    end

    context 'but case number is not set' do
      let(:attributes) { valid_attributes.except(:case_number) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:case_number]).to match_array(['blank'])
      }
    end

    context 'but case number is invalid' do
      let(:attributes) { valid_attributes.merge(case_number: 'invalid-cn') }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:case_number]).to match_array(['invalid_case_number_or_urn'])
      }
    end

    context 'when case was transferred from another court' do
      let(:transfer_court) { create(:court, name: 'Transfer Court Name') }
      let(:valid_attributes) {
        {
          court_id: court.id,
          case_number: 'A20161234',
          external_user_id: external_user.id,
          creator_id: external_user.id,
          case_transferred_from_another_court: true,
          transfer_court_id: transfer_court.id,
          transfer_case_number: 'T20170101'
        }
      }

      context 'with valid attributes' do
        let(:attributes) { valid_attributes }

        specify { is_expected.to be_valid }
      end

      context 'but the transfer court is not supplied' do
        let(:attributes) { valid_attributes.except(:transfer_court_id) }

        specify {
          is_expected.to be_invalid
          expect(claim.errors[:transfer_court]).to match_array(['blank'])
        }
      end

      context 'but the transfer court is the same as the new court' do
        let(:attributes) { valid_attributes.merge(transfer_court_id: court.id) }

        specify {
          is_expected.to be_invalid
          expect(claim.errors[:transfer_court]).to match_array(['same'])
        }
      end

      context 'but the transfer case number is not supplied' do
        let(:attributes) { valid_attributes.except(:transfer_case_number) }

        specify { is_expected.to be_valid }
      end

      context 'but the transfer case number is invalid' do
        let(:attributes) { valid_attributes.merge(transfer_case_number: 'invalid-tcn') }

        specify {
          is_expected.to be_invalid
          expect(claim.errors[:transfer_case_number]).to match_array(['invalid_case_number_or_urn'])
        }
      end
    end
  end

  context 'when submission step is defendant details' do
    let(:form_step) { 'defendants' }
    let(:case_details_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false
      }
    }
    let(:release_date) { Date.parse(Settings.agfs_fee_reform_release_date.to_s) }
    let(:valid_one_one_representation_order_attrs) {
      {
        representation_order_date_dd: release_date.day.to_s,
        representation_order_date_mm: release_date.month.to_s,
        representation_order_date_yyyy: release_date.year.to_s
      }
    }
    let(:one_one_representation_order_attrs) { valid_one_one_representation_order_attrs }
    let(:valid_one_other_representation_order_attrs) {
      {
        representation_order_date_dd: (release_date + 2.day).day.to_s,
        representation_order_date_mm: (release_date + 2.day).month.to_s,
        representation_order_date_yyyy: (release_date + 2.day).year.to_s
      }
    }
    let(:one_other_representation_order_attrs) { valid_one_other_representation_order_attrs }
    let(:valid_one_defendant_attrs) {
      {
        first_name: 'John',
        last_name: 'Doe',
        date_of_birth_dd: '03',
        date_of_birth_mm: '11',
        date_of_birth_yyyy: '1967',
        order_for_judicial_apportionment: '0',
        representation_orders_attributes: {
          '0' => one_one_representation_order_attrs,
          '1' => one_other_representation_order_attrs
        }
      }
    }
    let(:one_defendant_attrs) { valid_one_defendant_attrs }
    let(:valid_other_one_representation_order_attrs) {
      {
        representation_order_date_dd: (release_date + 1.day).day.to_s,
        representation_order_date_mm: (release_date + 1.day).month.to_s,
        representation_order_date_yyyy: (release_date + 1.day).year.to_s
      }
    }
    let(:other_one_representation_order_attrs) { valid_other_one_representation_order_attrs }
    let(:valid_other_defendant_attrs) {
      {
        first_name: 'Jane',
        last_name: 'Doe',
        date_of_birth_dd: '26',
        date_of_birth_mm: '07',
        date_of_birth_yyyy: '1959',
        order_for_judicial_apportionment: '0',
        representation_orders_attributes: {
          '0' => other_one_representation_order_attrs
        }
      }
    }
    let(:other_defendant_attrs) { valid_other_defendant_attrs }
    let(:valid_attributes) {
      {
        defendants_attributes: {
          '0' => one_defendant_attrs,
          '1' => other_defendant_attrs
        }
      }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(case_details_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when no defendants are set' do
      let(:attributes) { valid_attributes.except(:defendants_attributes) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendants]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has no first name set' do
      let(:one_defendant_attrs) { valid_one_defendant_attrs.except(:first_name) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_first_name]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a first name over the permitted length' do
      let(:other_defendant_attrs) { valid_other_defendant_attrs.merge(first_name: 'A' * 41) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_2_first_name]).to match_array(['max_length'])
      }
    end

    context 'when one of the defendants has no last name set' do
      let(:one_defendant_attrs) { valid_one_defendant_attrs.except(:last_name) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_last_name]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a last name over the permitted length' do
      let(:other_defendant_attrs) { valid_other_defendant_attrs.merge(last_name: 'A' * 41) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_2_last_name]).to match_array(['max_length'])
      }
    end

    context 'when one of the defendants has no date of birth set' do
      let(:one_defendant_attrs) {
        valid_one_defendant_attrs.except(:date_of_birth_dd, :date_of_birth_mm, :date_of_birth_yyyy)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_date_of_birth]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a date of birth that is to recent' do
      let(:recent_date_of_birth) { 5.years.ago.to_date }
      let(:other_defendant_attrs) {
        valid_other_defendant_attrs.merge(
          date_of_birth_dd: recent_date_of_birth.day.to_s,
          date_of_birth_mm: recent_date_of_birth.month.to_s,
          date_of_birth_yyyy: recent_date_of_birth.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_2_date_of_birth]).to match_array(['check'])
      }
    end

    context 'when one of the defendants has a date of birth that is to old' do
      let(:recent_date_of_birth) { 140.years.ago.to_date }
      let(:other_defendant_attrs) {
        valid_other_defendant_attrs.merge(
          date_of_birth_dd: recent_date_of_birth.day.to_s,
          date_of_birth_mm: recent_date_of_birth.month.to_s,
          date_of_birth_yyyy: recent_date_of_birth.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_2_date_of_birth]).to match_array(['check'])
      }
    end

    context 'when one of the defendants has no representation orders set' do
      let(:one_defendant_attrs) {
        valid_one_defendant_attrs.except(:representation_orders_attributes)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_representation_order_1_representation_order_date]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a representation order with no date set' do
      let(:other_one_representation_order_attrs) {
        valid_other_one_representation_order_attrs.except(:representation_order_date_dd, :representation_order_date_mm, :representation_order_date_yyyy)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_2_representation_order_1_representation_order_date]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a representation order set in the future' do
      let(:future_date) { 2.days.from_now.to_date }
      let(:one_other_representation_order_attrs) {
        valid_one_other_representation_order_attrs.merge(
          representation_order_date_dd: future_date.day.to_s,
          representation_order_date_mm: future_date.month.to_s,
          representation_order_date_yyyy: future_date.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_representation_order_2_representation_order_date]).to match_array(['in_future'])
      }
    end

    context 'when one of the defendants has a representation order set before the earliest permitted date' do
      let(:earliest_permitted_date) { Date.parse(Settings.earliest_permitted_date.to_s) }
      let(:one_other_representation_order_attrs) {
        valid_one_other_representation_order_attrs.merge(
                                         representation_order_date_dd: (earliest_permitted_date - 1.day).day.to_s,
                                         representation_order_date_mm: (earliest_permitted_date - 1.day).month.to_s,
                                         representation_order_date_yyyy: (earliest_permitted_date - 1.day).year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_representation_order_2_representation_order_date]).to match_array(['check', 'not_before_earliest_permitted_date'])
      }
    end

    context 'when one of the defendants has a representation order set before the AGFS fee reform release date' do
      let(:release_date) { Date.parse(Settings.agfs_fee_reform_release_date.to_s) }
      let(:one_other_representation_order_attrs) {
        valid_one_other_representation_order_attrs.merge(
                                         representation_order_date_dd: (release_date - 1.day).day.to_s,
                                         representation_order_date_mm: (release_date - 1.day).month.to_s,
                                         representation_order_date_yyyy: (release_date - 1.day).year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:base]).to match_array(['unclaimable'])
      }
    end
  end

  context 'when submission step is offence details' do
    before do
      allow(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date)
    end

    let(:form_step) { 'offence_details' }
    let(:release_date) { 4.months.ago.to_date }
    let(:earliest_representation_order_date) { release_date + 1.day }
    let(:previous_step_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false,
        defendants_attributes: {
          '0' => {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth_dd: '03',
            date_of_birth_mm: '11',
            date_of_birth_yyyy: '1967',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: earliest_representation_order_date.day.to_s,
                representation_order_date_mm: earliest_representation_order_date.month.to_s,
                representation_order_date_yyyy: earliest_representation_order_date.year.to_s
              },
              '1' => {
                representation_order_date_dd: (release_date + 2.day).day.to_s,
                representation_order_date_mm: (release_date + 2.day).month.to_s,
                representation_order_date_yyyy: (release_date + 2.day).year.to_s
              }
            }
          },
          '1' => {
            first_name: 'Jane',
            last_name: 'Doe',
            date_of_birth_dd: '26',
            date_of_birth_mm: '07',
            date_of_birth_yyyy: '1959',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: (release_date + 3.day).day.to_s,
                representation_order_date_mm: (release_date + 3.day).month.to_s,
                representation_order_date_yyyy: (release_date + 3.day).year.to_s
              }
            }
          }
        }
      }
    }
    let(:valid_attributes) {
      { offence_id: offence.id }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(previous_step_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when offence id is not set' do
      let(:attributes) { valid_attributes.except(:offence_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:offence]).to match_array(['new_blank'])
      }
    end
  end

  context 'when submission step is interim fees details' do
    before do
      allow(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date)
    end

    let(:form_step) { 'interim_fees' }
    let(:release_date) { 4.months.ago.to_date }
    let(:earliest_representation_order_date) { release_date + 1.day }
    let(:previous_step_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false,
        defendants_attributes: {
          '0' => {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth_dd: '03',
            date_of_birth_mm: '11',
            date_of_birth_yyyy: '1967',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: earliest_representation_order_date.day.to_s,
                representation_order_date_mm: earliest_representation_order_date.month.to_s,
                representation_order_date_yyyy: earliest_representation_order_date.year.to_s
              },
              '1' => {
                representation_order_date_dd: (release_date + 2.day).day.to_s,
                representation_order_date_mm: (release_date + 2.day).month.to_s,
                representation_order_date_yyyy: (release_date + 2.day).year.to_s
              }
            }
          },
          '1' => {
            first_name: 'Jane',
            last_name: 'Doe',
            date_of_birth_dd: '26',
            date_of_birth_mm: '07',
            date_of_birth_yyyy: '1959',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: (release_date + 3.day).day.to_s,
                representation_order_date_mm: (release_date + 3.day).month.to_s,
                representation_order_date_yyyy: (release_date + 3.day).year.to_s
              }
            }
          }
        },
        offence_id: offence.id
      }
    }
    let(:warrant_issued_date) { 3.months.ago }
    let(:valid_warrant_fee_attributes) {
      {
        warrant_issued_date_dd: warrant_issued_date.day.to_s,
        warrant_issued_date_mm: warrant_issued_date.month.to_s,
        warrant_issued_date_yyyy: warrant_issued_date.year.to_s,
        amount: 20
      }
    }
    let(:warrant_fee_attributes) { valid_warrant_fee_attributes }
    let(:valid_attributes) {
      {
        advocate_category: 'QC',
        warrant_fee_attributes: warrant_fee_attributes
      }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(previous_step_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when an advocate category is not set' do
      let(:attributes) { valid_attributes.except(:advocate_category) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:advocate_category]).to match_array(['blank'])
      }
    end

    context 'when an invalid advocate category is set' do
      let(:attributes) { valid_attributes.merge(advocate_category: 'invalid-ac') }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:advocate_category]).to match_array(['Advocate category must be one of those in the provided list'])
      }
    end

    context 'when a warrant fee issued date is not set' do
      let(:warrant_fee_attributes) {
        valid_warrant_fee_attributes.except(:warrant_issued_date_dd,
                                            :warrant_issued_date_mm,
                                            :warrant_issued_date_yyyy)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.warrant_issued_date"]).to match_array(['blank'])
      }
    end

    context 'when a warrant fee issued date is set before the earliest permitted date' do
      let(:old_warrant_issued_date) { 15.years.ago }
      let(:warrant_fee_attributes) {
        valid_warrant_fee_attributes.merge(
          warrant_issued_date_dd: old_warrant_issued_date.day.to_s,
          warrant_issued_date_mm: old_warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: old_warrant_issued_date.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.warrant_issued_date"]).to match_array(['check_not_too_far_in_past', 'check_on_or_after_earliest_representation_order'])
      }
    end

    context 'when a warrant fee issued date is set in the future' do
      let(:future_warrant_issued_date) { 6.days.from_now }
      let(:warrant_fee_attributes) {
        valid_warrant_fee_attributes.merge(
          warrant_issued_date_dd: future_warrant_issued_date.day.to_s,
          warrant_issued_date_mm: future_warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: future_warrant_issued_date.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.warrant_issued_date"]).to match_array(['check_not_in_future', 'on_or_before'])
      }
    end

    context 'when a warrant fee has been issued less than 3 months ago' do
      let(:new_warrant_issued_date) { 2.months.ago }
      let(:warrant_fee_attributes) {
        valid_warrant_fee_attributes.merge(
          warrant_issued_date_dd: new_warrant_issued_date.day.to_s,
          warrant_issued_date_mm: new_warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: new_warrant_issued_date.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.warrant_issued_date"]).to match_array(['on_or_before'])
      }
    end

    context 'when a warrant issued date has been set before the earliest representation order date' do
      let(:new_warrant_issued_date) { earliest_representation_order_date - 1.day }
      let(:warrant_fee_attributes) {
        valid_warrant_fee_attributes.merge(
          warrant_issued_date_dd: new_warrant_issued_date.day.to_s,
          warrant_issued_date_mm: new_warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: new_warrant_issued_date.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.warrant_issued_date"]).to match_array(['check_on_or_after_earliest_representation_order'])
      }
    end

    context 'when a warrant fee amount was not set' do
      let(:warrant_fee_attributes) { valid_warrant_fee_attributes.except(:amount) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.amount"]).to match_array(['numericality'])
      }
    end

    context 'when the warrant fee amount is zero' do
      let(:warrant_fee_attributes) { valid_warrant_fee_attributes.merge(amount: '0.00') }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:"warrant_fee.amount"]).to match_array(['numericality'])
      }
    end
  end

  context 'when submission step is travel expenses details' do
    before do
      allow(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date)
    end

    let(:form_step) { 'travel_expenses' }
    let(:release_date) { 4.months.ago.to_date }
    let(:earliest_representation_order_date) { release_date + 1.day }
    let(:warrant_issued_date) { 3.months.ago }
    let(:previous_steps_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false,
        defendants_attributes: {
          '0' => {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth_dd: '03',
            date_of_birth_mm: '11',
            date_of_birth_yyyy: '1967',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: earliest_representation_order_date.day.to_s,
                representation_order_date_mm: earliest_representation_order_date.month.to_s,
                representation_order_date_yyyy: earliest_representation_order_date.year.to_s
              },
              '1' => {
                representation_order_date_dd: (release_date + 2.day).day.to_s,
                representation_order_date_mm: (release_date + 2.day).month.to_s,
                representation_order_date_yyyy: (release_date + 2.day).year.to_s
              }
            }
          },
          '1' => {
            first_name: 'Jane',
            last_name: 'Doe',
            date_of_birth_dd: '26',
            date_of_birth_mm: '07',
            date_of_birth_yyyy: '1959',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: (release_date + 3.day).day.to_s,
                representation_order_date_mm: (release_date + 3.day).month.to_s,
                representation_order_date_yyyy: (release_date + 3.day).year.to_s
              }
            }
          }
        },
        offence_id: offence.id,
        advocate_category: 'QC',
        warrant_fee_attributes: {
          warrant_issued_date_dd: warrant_issued_date.day.to_s,
          warrant_issued_date_mm: warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: warrant_issued_date.year.to_s,
          amount: 20
        }
      }
    }
    let(:court_hearing_reason) { ExpenseType::REASON_SET_A[1] }
    let(:valid_one_expense_attributes) {
      {
        expense_type_id: parking_expense_type.id.to_s,
        reason_id: court_hearing_reason.id.to_s,
        date_dd: earliest_representation_order_date.day.to_s,
        date_mm: earliest_representation_order_date.month.to_s,
        date_yyyy: earliest_representation_order_date.year.to_s,
        amount: 50
      }
    }
    let(:one_expense_attributes) { valid_one_expense_attributes }
    let(:pre_trial_conference_defendant_reason) { ExpenseType::REASON_SET_A[3] }
    let(:valid_other_expense_attributes) {
      {
        expense_type_id: subsistence_expense_type.id.to_s,
        reason_id: pre_trial_conference_defendant_reason.id.to_s,
        location: 'Luton',
        date_dd: (earliest_representation_order_date + 1.day).day.to_s,
        date_mm: (earliest_representation_order_date + 1.day).month.to_s,
        date_yyyy: (earliest_representation_order_date + 1.day).year.to_s,
        amount: 32.5
      }
    }
    let(:other_expense_attributes) { valid_other_expense_attributes }
    let(:valid_expenses_attributes) {
      {
        '0' => one_expense_attributes,
        '1' => other_expense_attributes
      }
    }
    let(:expenses_attributes) { valid_expenses_attributes }
    let(:valid_attributes) {
      {
        expenses_attributes: expenses_attributes
      }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(previous_steps_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when one of the expenses requires an expense type  but its not given' do
      let(:one_expense_attributes) { valid_one_expense_attributes.except(:expense_type_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_1_expense_type]).to match_array(['blank'])
      }
    end

    context 'when one of the expenses requires an expense type  but an invalid one is given' do
      let(:other_expense_attributes) { valid_other_expense_attributes.merge(expense_type_id: 99999) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_2_expense_type]).to match_array(['blank'])
      }
    end

    context 'when one of the expenses requires a reason but its not given' do
      let(:one_expense_attributes) { valid_one_expense_attributes.except(:reason_id) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_1_reason_id]).to match_array(['blank'])
      }
    end

    context 'when one of the expenses requires a reason but an invalid one is given' do
      let(:one_expense_attributes) { valid_one_expense_attributes.merge(reason_id: 9999999) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_1_reason_id]).to match_array(['invalid'])
      }
    end

    context 'when one of the expenses requires a date but its not given' do
      let(:other_expense_attributes) { valid_other_expense_attributes.except(:date_dd, :date_mm, :date_yyyy) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_2_date]).to match_array(['blank'])
      }
    end

    context 'when one of the expenses requires a date but its in the future' do
      let(:date_in_future) { 5.days.from_now.to_date }
      let(:one_expense_attributes) { valid_one_expense_attributes.merge(
        date_dd: date_in_future.day.to_s,
        date_mm: date_in_future.month.to_s,
        date_yyyy: date_in_future.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_1_date]).to match_array(['future'])
      }
    end

    context 'when one of the expenses requires a date but its before the earliest permitted date' do
      let(:date_too_old) { Date.parse(Settings.earliest_permitted_date.to_s) - 2.days }
      let(:one_expense_attributes) { valid_one_expense_attributes.merge(
        date_dd: date_too_old.day.to_s,
        date_mm: date_too_old.month.to_s,
        date_yyyy: date_too_old.year.to_s)
      }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_1_date]).to match_array(['check_not_earlier_than_rep_order'])
      }
    end

    context 'when one of the expenses requires an amount but its not given' do
      let(:other_expense_attributes) { valid_other_expense_attributes.except(:amount) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_2_amount]).to match_array(['blank'])
      }
    end

    context 'when one of the expenses requires a positive amount but its not given' do
      let(:other_expense_attributes) { valid_other_expense_attributes.merge(amount: 0) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:expense_2_amount]).to match_array(['numericality'])
      }
    end
  end

  context 'when submission step is supporting evidence details' do
    before do
      allow(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date)
    end

    let(:form_step) { 'supporting_evidence' }
    let(:release_date) { 4.months.ago.to_date }
    let(:earliest_representation_order_date) { release_date + 1.day }
    let(:warrant_issued_date) { 3.months.ago }
    let(:court_hearing_reason) { ExpenseType::REASON_SET_A[1] }
    let(:pre_trial_conference_defendant_reason) { ExpenseType::REASON_SET_A[3] }
    let(:previous_steps_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false,
        defendants_attributes: {
          '0' => {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth_dd: '03',
            date_of_birth_mm: '11',
            date_of_birth_yyyy: '1967',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: earliest_representation_order_date.day.to_s,
                representation_order_date_mm: earliest_representation_order_date.month.to_s,
                representation_order_date_yyyy: earliest_representation_order_date.year.to_s
              },
              '1' => {
                representation_order_date_dd: (release_date + 2.day).day.to_s,
                representation_order_date_mm: (release_date + 2.day).month.to_s,
                representation_order_date_yyyy: (release_date + 2.day).year.to_s
              }
            }
          },
          '1' => {
            first_name: 'Jane',
            last_name: 'Doe',
            date_of_birth_dd: '26',
            date_of_birth_mm: '07',
            date_of_birth_yyyy: '1959',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: (release_date + 3.day).day.to_s,
                representation_order_date_mm: (release_date + 3.day).month.to_s,
                representation_order_date_yyyy: (release_date + 3.day).year.to_s
              }
            }
          }
        },
        offence_id: offence.id,
        advocate_category: 'QC',
        warrant_fee_attributes: {
          warrant_issued_date_dd: warrant_issued_date.day.to_s,
          warrant_issued_date_mm: warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: warrant_issued_date.year.to_s,
          amount: 20
        },
        expenses_attributes: {
          '0' => {
            expense_type_id: parking_expense_type.id.to_s,
            reason_id: court_hearing_reason.id.to_s,
            date_dd: earliest_representation_order_date.day.to_s,
            date_mm: earliest_representation_order_date.month.to_s,
            date_yyyy: earliest_representation_order_date.year.to_s,
            amount: 50
          },
          '1' => {
            expense_type_id: subsistence_expense_type.id.to_s,
            reason_id: pre_trial_conference_defendant_reason.id.to_s,
            location: 'Luton',
            date_dd: (earliest_representation_order_date + 1.day).day.to_s,
            date_mm: (earliest_representation_order_date + 1.day).month.to_s,
            date_yyyy: (earliest_representation_order_date + 1.day).year.to_s,
            amount: 32.5
          }
        }
      }
    }
    let(:valid_attributes) {
      {
        disk_evidence: false,
        evidence_checklist_ids: DocType::FEE_REFORM_DOC_TYPE_IDS
      }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(previous_steps_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when disk evidence flag is not set' do
      let(:attributes) { valid_attributes.except(:disk_evidence) }

      specify {
        is_expected.to be_valid
        expect(claim.disk_evidence).to be_falsey
      }
    end

    context 'when disk evidence flag is set to true' do
      let(:attributes) { valid_attributes.merge(disk_evidence: true) }

      specify {
        is_expected.to be_valid
        expect(claim.disk_evidence).to be_truthy
      }
    end

    context 'when evidence checklist is not set' do
      let(:attributes) { valid_attributes.except(:evidence_checklist_ids) }

      specify {
        is_expected.to be_valid
        expect(claim.evidence_checklist_ids).to be_empty
      }
    end

    context 'when evidence checklist is set with invalid document types for this claim' do
      let(:invalid_checklist_ids) { [2, 5, 7, 8, 9, 10, 11] }
      let(:attributes) { valid_attributes.merge(evidence_checklist_ids: invalid_checklist_ids) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:evidence_checklist_ids].length).to eq(invalid_checklist_ids.length)
        claim.errors[:evidence_checklist_ids].each do |error_message|
          expect(error_message).to match(/is invalid/)
        end
      }
    end
  end

  context 'when submission step is additional information' do
    before do
      allow(Settings).to receive(:agfs_fee_reform_release_date).and_return(release_date)
    end

    let(:form_step) { 'additional_information' }
    let(:release_date) { 4.months.ago.to_date }
    let(:earliest_representation_order_date) { release_date + 1.day }
    let(:warrant_issued_date) { 3.months.ago }
    let(:court_hearing_reason) { ExpenseType::REASON_SET_A[1] }
    let(:pre_trial_conference_defendant_reason) { ExpenseType::REASON_SET_A[3] }
    let(:previous_steps_attributes) {
      {
        court_id: court.id,
        case_number: 'T20170101',
        external_user_id: external_user.id,
        creator_id: external_user.id,
        case_transferred_from_another_court: false,
        defendants_attributes: {
          '0' => {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth_dd: '03',
            date_of_birth_mm: '11',
            date_of_birth_yyyy: '1967',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: earliest_representation_order_date.day.to_s,
                representation_order_date_mm: earliest_representation_order_date.month.to_s,
                representation_order_date_yyyy: earliest_representation_order_date.year.to_s
              },
              '1' => {
                representation_order_date_dd: (release_date + 2.day).day.to_s,
                representation_order_date_mm: (release_date + 2.day).month.to_s,
                representation_order_date_yyyy: (release_date + 2.day).year.to_s
              }
            }
          },
          '1' => {
            first_name: 'Jane',
            last_name: 'Doe',
            date_of_birth_dd: '26',
            date_of_birth_mm: '07',
            date_of_birth_yyyy: '1959',
            order_for_judicial_apportionment: '0',
            representation_orders_attributes: {
              '0' => {
                representation_order_date_dd: (release_date + 3.day).day.to_s,
                representation_order_date_mm: (release_date + 3.day).month.to_s,
                representation_order_date_yyyy: (release_date + 3.day).year.to_s
              }
            }
          }
        },
        offence_id: offence.id,
        advocate_category: 'QC',
        warrant_fee_attributes: {
          warrant_issued_date_dd: warrant_issued_date.day.to_s,
          warrant_issued_date_mm: warrant_issued_date.month.to_s,
          warrant_issued_date_yyyy: warrant_issued_date.year.to_s,
          amount: 20
        },
        expenses_attributes: {
          '0' => {
            expense_type_id: parking_expense_type.id.to_s,
            reason_id: court_hearing_reason.id.to_s,
            date_dd: earliest_representation_order_date.day.to_s,
            date_mm: earliest_representation_order_date.month.to_s,
            date_yyyy: earliest_representation_order_date.year.to_s,
            amount: 50
          },
          '1' => {
            expense_type_id: subsistence_expense_type.id.to_s,
            reason_id: pre_trial_conference_defendant_reason.id.to_s,
            location: 'Luton',
            date_dd: (earliest_representation_order_date + 1.day).day.to_s,
            date_mm: (earliest_representation_order_date + 1.day).month.to_s,
            date_yyyy: (earliest_representation_order_date + 1.day).year.to_s,
            amount: 32.5
          }
        },
        disk_evidence: false,
        evidence_checklist_ids: DocType::FEE_REFORM_DOC_TYPE_IDS
      }
    }
    let(:valid_attributes) {
      {
        additional_information: 'Some additional information'
      }
    }

    subject(:claim) {
      Claim::AdvocateInterimClaim.create(previous_steps_attributes).tap do |record|
        record.assign_attributes(params)
      end
    }

    context 'with valid attributes' do
      let(:attributes) { valid_attributes }

      specify { is_expected.to be_valid }
    end

    context 'when no additional information is provided' do
      let(:attributes) { valid_attributes.except(:additional_information) }

      specify { is_expected.to be_valid }
    end

    context 'when additional information is blank' do
      let(:attributes) { valid_attributes.merge(additional_information: '') }

      specify { is_expected.to be_valid }
    end
  end
end
