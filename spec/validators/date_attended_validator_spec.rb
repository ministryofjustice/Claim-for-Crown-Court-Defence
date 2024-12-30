require 'rails_helper'

RSpec.describe DateAttendedValidator, type: :validator do
  let(:claim) do
    create(:claim, :without_fees, create_defendant_and_rep_order_for_scheme_13: true, total: 10, first_day_of_trial: 5.weeks.ago).tap do |claim|
      create(:basic_fee, claim:).tap do |fee|
        create(:date_attended, attended_item: fee)
      end
    end
  end

  let(:date_attended)          { claim.fees.first.dates_attended.first }
  let(:earliest_reporder_date) { claim.defendants.first.representation_orders.first.representation_order_date }

  before do
    claim.force_validation = true
  end

  context 'date' do
    it { should_error_if_not_present(date_attended, :date, 'Enter the date attended') }
    it { should_error_if_before_specified_date(date_attended, :date, earliest_reporder_date - 2.years - 1.day, 'The fee date cannot be more than two years before the earliest representation order date') }
    it { should_error_if_too_far_in_the_past(date_attended, :date, 'Enter a date later than two years before the earliest representation order date') }
    it { should_error_if_in_future(date_attended, :date, 'Enter a date that is not in the future') }

    context 'when there is no representation order date set' do
      before do
        claim.defendants.each do |defendant|
          defendant.representation_orders.clear
        end
      end

      it { expect(date_attended).to be_valid }
    end

    it 'does not error if less than two years before earliest rep order date' do
      date_attended.date = earliest_reporder_date - 369.days
      date_attended.date_to = nil
      expect(date_attended).to be_valid
    end
  end
end
