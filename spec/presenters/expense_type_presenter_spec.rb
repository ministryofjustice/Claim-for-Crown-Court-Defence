require 'rails_helper'

RSpec.describe ExpenseTypePresenter do

  let(:expense)   { build(:expense, expense_type) }
  let(:presenter) { ExpenseTypePresenter.new(expense.expense_type, view) }

  describe '#data_attributes' do
    context 'Car Travel' do
      let(:expense_type) { :car_travel }

      it 'returns the right data attributes' do
        expect(presenter.data_attributes).to \
          eq({ location: true, location_label: 'Destination', distance: true, mileage: true, hours: false, reason_set: 'A' })
      end
    end

    context 'Train/public transport' do
      let(:expense_type) { :train }

      it 'returns the right data attributes' do
        expect(presenter.data_attributes).to \
          eq({ location: true, location_label: 'Destination', distance: true, mileage: false, hours: false, reason_set: 'A' })
      end
    end

    context 'Parking' do
      let(:expense_type) { :parking }

      it 'returns the right data attributes' do
        expect(presenter.data_attributes).to \
          eq({ location: false, location_label: '', distance: false, mileage: false, hours: false, reason_set: 'A' })
      end
    end

    context 'Hotel accommodation' do
      let(:expense_type) { :hotel_accommodation }

      it 'returns the right data attributes' do
        expect(presenter.data_attributes).to \
          eq({ location: true, location_label: 'Location', distance: false, mileage: false, hours: false, reason_set: 'A' })
      end
    end

    context 'Travel time' do
      let(:expense_type) { :travel_time }

      it 'returns the right data attributes' do
        expect(presenter.data_attributes).to \
          eq({ location: true, location_label: 'Destination', distance: false, mileage: false, hours: true, reason_set: 'B' })
      end
    end
  end
end
