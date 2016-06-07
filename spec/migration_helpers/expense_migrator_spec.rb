require 'rails_helper'
require File.join(Rails.root, 'db', 'migration_helpers', 'expense_type_migrator')

module MigrationHelpers
  class MockExpenseTypeMigrator < ExpenseTypeMigrator
    def initialize
    end
  end

  describe ExpenseTypeMigrator do
    let(:mock_migrator) { MockExpenseTypeMigrator.new }

    context 'conference and view - car' do
      before(:all) do
        @original_type = ExpenseType.create!(name: 'Conference and View - Car', roles: ['agfs'], reason_set: 'A')
        [
          'Car travel',
          'Train/public transport',
          'Parking',
          'Hotel accommodation'
        ].each do |expense_type_name|
          ExpenseType.create!(name: expense_type_name, roles: ['agfs', 'lgfs'], reason_set: 'A')
        end
        @migrated_type = ExpenseType.find_by(name: 'Car travel')
      end

      after(:all) do
        clean_database
      end

      before(:each) do
        allow(Settings).to receive(:expense_schema_version).and_return(1)
      end

      let(:migrator) { ExpenseTypeMigrator.new }
      let(:expense) { build(:expense, expense_type: @original_type, location: 'Here', quantity: 148.0, rate: 0.25, amount: 37.0) }

      it 'migrates with the correct quantity, rate, date and reason for single date attended' do
        expense.dates_attended << build(:single_date_attended)
        migrator.send(:migrate_expense, expense)
        expect(expense.expense_type).to eq @migrated_type
        expect(expense.date).to eq 12.days.ago.to_date
        expect(expense.reason_text).to eq 'Other: Originally Conference and View - Car; Qty: 148.0, Rate: 0.25;'
      end

      it 'migrates with the correct quantity, rate, date and reason for single date range attended' do
        expense.dates_attended << build(:date_range_attended, date: Date.new(2016, 3, 4), date_to: Date.new(2016, 3, 6))
        migrator.send(:migrate_expense, expense)
        expect(expense.expense_type).to eq @migrated_type
        expect(expense.date).to eq Date.new(2016, 3, 4)
        expect(expense.reason_text).to eq 'Other: Originally Conference and View - Car; Qty: 148.0, Rate: 0.25; 04/03/2016 - 06/03/2016'
      end
    end



    describe 'private method is_single_date' do
      it 'returns true for single date with no date_to' do
        ex = build :expense, :with_single_date_attended
        expect(mock_migrator.send(:is_single_date?, ex.dates_attended)).to be true
      end

      it 'returns true for single date with same date from and to' do
        ex = build :expense, :with_same_date_attended_to_as_from
        expect(mock_migrator.send(:is_single_date?, ex.dates_attended)).to be true
      end

      it 'returns false for single date with different dates from to' do
        ex = build :expense, :with_date_range_attended
        expect(mock_migrator.send(:is_single_date?, ex.dates_attended)).to be false
      end
    end

    describe 'extract_date_ranges_as_text' do
      it 'extracts one date range' do
        ex = build :expense
        start = Date.new(2016, 2, 14)
        finish = Date.new(2016, 2, 20)
        ex.dates_attended << build(:date_attended, date: start, date_to: finish)
        expect(mock_migrator.send(:extract_date_ranges_as_text, ex)).to eq '14/02/2016 - 20/02/2016'
      end

      it 'extracts multiple date ranges' do
        ex = build :expense
        ex.dates_attended << build(:date_attended, date: Date.new(2016, 2, 3), date_to: Date.new(2016, 2, 15))
        ex.dates_attended << build(:date_attended, date: Date.new(2016, 3, 4), date_to: Date.new(2016, 3, 8))
        ex.dates_attended << build(:date_attended, date: Date.new(2016, 3, 10), date_to: nil)
        expected_text = "03/02/2016 - 15/02/2016, 04/03/2016 - 08/03/2016, 10/03/2016"
        expect(mock_migrator.send(:extract_date_ranges_as_text, ex)).to eq expected_text
      end
    end
  end
end
