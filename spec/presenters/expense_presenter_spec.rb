require 'rails_helper'

RSpec.describe ExpensePresenter do
  let(:claim) { create(:advocate_claim) }
  let(:expense_type) { create(:expense_type) }
  let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type) }

  subject(:presenter) { described_class.new(expense, view) }

  describe '#dates_attended_delimited_string' do

    before {
      claim.expenses.each do |fee|
        expense.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('21/05/2015'), date_to: Date.parse('23/05/2015'))
        expense.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('25/05/2015'), date_to: nil)
      end
    }

    it 'outputs string of dates or date ranges separated by comma' do
      claim.expenses.each do |fee|
        expense = ExpensePresenter.new(fee, view)
        expect(expense.dates_attended_delimited_string).to eql('21/05/2015 - 23/05/2015, 25/05/2015')
      end
    end
  end

  describe '#amount' do
    it 'formats as currency' do
      expense.amount = 32456.3
      expect(presenter.amount).to eq '£32,456.30'
    end
  end

  describe '#vat_amount' do
    it 'formats as currency' do
      expense.vat_amount = 1222.3
      expect(presenter.vat_amount).to eq '£1,222.30'
    end
  end

  describe '#total' do
    it 'formats as currency' do
      expense.amount = 32456.3
      expense.vat_amount = 1.3
      expect(presenter.total).to eq '£32,457.60'
    end
  end

  describe '#distance' do
    it 'formats as decimal number, 2 decimals precision, with rounding' do
      expense.distance = 324.479
      expect(presenter.distance).to eq '324.48'
    end

    it 'strips insignificant zeros' do
      expense.distance = 324.00
      expect(presenter.distance).to eq '324'
    end
  end

  describe '#calculated_distance' do
    let(:calculated_distance) { 234 }
    let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type, calculated_distance: calculated_distance) }

    it 'formats as decimal number, 2 decimals precision, with rounding' do
      expense.calculated_distance = 324.479
      expect(presenter.calculated_distance).to eq '324.48'
    end

    it 'strips insignificant zeros' do
      expense.calculated_distance = 324.00
      expect(presenter.calculated_distance).to eq '324'
    end

    context 'when is not set' do
      let(:calculated_distance) { nil }

      it { expect(presenter.calculated_distance).to be_nil }
    end
  end

  describe '#pretty_calculated_distance' do
    let(:calculated_distance) { 234 }
    let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type, calculated_distance: calculated_distance) }

    it 'returns the value with the locale unit' do
      expense.calculated_distance = 324.479
      expect(presenter.pretty_calculated_distance).to eq '324.48 miles'
    end

    context 'when is not set' do
      let(:calculated_distance) { nil }

      it { expect(presenter.pretty_calculated_distance).to eq('n/a') }
    end
  end

  describe '#hours' do
    it 'formats as decimal number, 2 decimals precision with rounding' do
      expense.hours = 35.239
      expect(presenter.hours).to eq '35.24'
    end

    it 'strips insignificant zeros' do
      expense.hours = 35.0
      expect(presenter.hours).to eq '35'
    end
  end

  describe '#name' do
    it 'outputs "Not selected" if there is no expense type' do
      expense.expense_type_id = nil
      expect(presenter.name).to eql('Not selected')
    end

    it 'outputs the type name is there is an expense type' do
      expense.expense_type_id = expense_type.id
      expect(presenter.name).to eql(expense.expense_type.name)
    end
  end

  describe '#display_reason_text_css' do
    def reason_requiring_text
      ExpenseType::REASON_SET_A.map { |reason| reason[1] if reason[1].allow_explanatory_text? }.compact.sample
    end

    it 'should return "none" for expense reasons NOT requiring explanantory' do
      expect(presenter.display_reason_text_css).to eql 'none'
    end

    it 'should return "inline-block" for expense reasons requiring explanantory text' do
      expense.reason_id = reason_requiring_text.id
      expect(presenter.display_reason_text_css).to eql 'inline-block'
    end
  end

  describe '#reason' do
    context 'when a specific reason was selected' do
      before do
        expense.reason_id = 1
      end

      it 'outputs the reason text' do
        expect(presenter.reason).to eq('Court hearing')
      end
    end

    context 'when Other was selected' do
      before do
        expense.reason_id = 5
      end

      it 'outputs a placeholder text if no free text reason was provided' do
        expect(presenter.reason).to eq('Not provided')
      end

      it 'outputs the free text reason if provided' do
        expense.reason_text = 'This is a test reason'
        expect(presenter.reason).to eq('This is a test reason')
      end
    end
  end

  describe '#mileage_rate' do
    it 'outputs the mileage rate name if any' do
      expense.mileage_rate_id = 1
      expect(presenter.mileage_rate).to eq('25p')
    end

    it 'outputs n/a if no mileage rate was selected' do
      expense.mileage_rate_id = nil
      expect(presenter.mileage_rate).to eq('n/a')
    end
  end
end
