require 'rails_helper'

RSpec.describe 'Advocate interim claim WEB validations' do
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
        expect(claim.errors[:case_number]).to match_array(['invalid'])
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
          expect(claim.errors[:transfer_case_number]).to match_array(['invalid'])
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

      # TODO: shouldn't this be failing?
      specify { is_expected.to be_valid }
    end

    context 'when one of the defendants has no first name set' do
      let(:one_defendant_attrs) { valid_one_defendant_attrs.except(:first_name) }

      specify {
        is_expected.to be_invalid
        expect(claim.errors[:defendant_1_first_name]).to match_array(['blank'])
      }
    end

    context 'when one of the defendants has a first name over the permitted length' do
      let(:other_defendant_attrs) { valid_other_defendant_attrs.merge(first_name: 'A'*41) }

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
      let(:other_defendant_attrs) { valid_other_defendant_attrs.merge(last_name: 'A'*41) }

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
end
