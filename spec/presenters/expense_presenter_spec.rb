require 'rails_helper'

RSpec.describe ExpensePresenter do

  let(:claim) { create(:claim) }
  let(:expense_type)  { create(:expense_type) }
  let(:expense)       { create(:expense, quantity: 4, claim: claim, expense_type: expense_type) }
  let(:presenter) {ExpensePresenter.new(expense, view) }

  describe '#dates_attended_delimited_string' do

    before {
      claim.expenses .each do |fee|
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

end
