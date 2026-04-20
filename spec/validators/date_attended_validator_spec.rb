require 'rails_helper'

RSpec.describe DateAttendedValidator, type: :validator do
  subject(:date_attended) { claim.fees.first.dates_attended.first }

  let(:claim) do
    create(:claim, :without_fees, create_defendant_and_rep_order: false, total: 10,
                                  first_day_of_trial: 5.weeks.ago).tap do |claim|
      create(:basic_fee, claim:).tap do |fee|
        create(:date_attended, date: attendance_date, attended_item: fee)
      end
    end
  end

  let(:attendance_date) { Date.new(2024, 12, 25) }

  before { claim.force_validation = true }

  it { should_error_if_not_present(date_attended, :date, 'Enter the date attended') }
  it { should_error_if_in_future(date_attended, :date, 'Enter a date that is not in the future') }

  context 'with earliest permitted date boundaries' do
    context 'when date attended is before the earliest permitted date' do
      let(:attendance_date) { Settings.earliest_permitted_date - 1.day }

      it { is_expected.not_to be_valid }
    end

    context 'when date attended is on the earliest permitted date' do
      let(:attendance_date) { Settings.earliest_permitted_date }

      it { is_expected.to be_valid }
    end
  end

  context 'with a representation order date' do
    let(:representation_order_date) { Date.new(2024, 5, 5) }

    before do
      claim.defendants << create(:defendant, representation_order_date:)
    end

    context 'when date attended is before representation order date' do
      let(:attendance_date) { representation_order_date - 1.day }

      it { is_expected.not_to be_valid }
    end

    context 'when date attended is on representation order date' do
      let(:attendance_date) { representation_order_date }

      it { is_expected.to be_valid }
    end

    context 'when date attended is after representation order date' do
      let(:attendance_date) { representation_order_date + 1.day }

      it { is_expected.to be_valid }
    end
  end

  context 'when there is no representation order date set' do
    before { claim.defendants << build(:defendant, :without_reporder, claim:) }

    it { is_expected.to be_valid }
  end
end
