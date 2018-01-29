require 'rails_helper'

RSpec.describe DateAttendedValidator, type: :validator do
  let(:claim) do
    claim = FactoryBot.create :claim,
                      total: 10,
                      force_validation: true,
                      first_day_of_trial: 5.weeks.ago,
                      fees: [ FactoryBot.build(:basic_fee, dates_attended: [ FactoryBot.build(:date_attended) ]) ],
                      defendants: [ FactoryBot.build(:defendant) ]
    fee = claim.fees.first
    fee.claim = claim
    date_attended = fee.dates_attended.first
    date_attended.attended_item = fee
    claim
  end

  let(:date_attended)                 { claim.fees.first.dates_attended.first }
  let(:earliest_reporder_date)        { claim.defendants.first.representation_orders.first.representation_order_date }

  context 'date' do
    it { should_error_if_not_present(date_attended, :date, 'blank') }
    it { should_error_if_before_specified_date(date_attended, :date, earliest_reporder_date - 2.years - 1.day, 'too_long_before_earliest_reporder') }
    it { should_error_if_too_far_in_the_past(date_attended, :date, 'not_before_earliest_permitted_date') }
    it 'should not error if less than two years before earliest rep order date' do
      date_attended.date = earliest_reporder_date - 369.days
      date_attended.date_to = nil
      expect(date_attended).to be_valid
    end
  end

  context 'date to' do
    it { should_error_if_earlier_than_other_date(date_attended, :date_to, :date, 'not_before_date_from') }
    it { should_error_if_in_future(date_attended, :date_to, 'not_after_today') }
    it 'should not error if nil' do
      date_attended.date_to = nil
      expect(date_attended).to be_valid
    end
  end

end
