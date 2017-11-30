require 'rails_helper'

require('support/shared_examples_for_expenses')
require('fixtures/ccr_test_expenses_fixtures')

module CCR

  describe ExpensesAdapter do
    subject { ::CCR::ExpensesAdapter.new(expense) }

    include TestExpenses

    describe 'car travel' do
      TestExpenses.for_car_travel.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :car_travel, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'parking' do
      TestExpenses.for_parking.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :parking, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'hotel accommodation' do
      TestExpenses.for_hotel_accommodation.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :hotel_accommodation, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'train transport' do
      TestExpenses.for_train_public_transport.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :train, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'travel time' do
      TestExpenses.for_travel_time.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :travel_time, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'road and tunnel tolls' do
      TestExpenses.for_road_or_tunnel_tolls.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :road_tolls, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'cab fares' do
      TestExpenses.for_cab_fares.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :cab_fares, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'subsistence' do
      TestExpenses.for_subsistence.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :subsistence, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end

    describe 'bicycle travel' do
      TestExpenses.for_bike_travel.each do |row|
        context "with reason_id of #{row[:source_expense][:reason_id]}" do
          let(:test) { row }
          let(:expense) { create(:expense, :bike_travel, test[:source_expense]) }

          it_behaves_like 'an adapted expense'
        end
      end
    end
  end
end

