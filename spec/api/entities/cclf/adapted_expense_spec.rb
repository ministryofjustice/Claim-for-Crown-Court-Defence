require 'rails_helper'

RSpec.describe API::Entities::CCLF::AdaptedExpense, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(expense).to_json, symbolize_names: true) }

  let(:expense_type) { instance_double(::ExpenseType, unique_code: 'CAR') }
  let(:case_type) { instance_double(::CaseType, fee_type_code: 'FXACV') }
  let(:claim) { instance_double(::Claim::BaseClaim, case_type: case_type) }
  let(:expense) { instance_double(::Expense, claim: claim, expense_type: expense_type, amount: 9.99, vat_amount: 1.99) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype net_amount vat_amount])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'DISBURSEMENT',
      bill_subtype: 'TRAVEL COSTS',
      net_amount: '9.99',
      vat_amount: '1.99'
    )
  end

  it 'delegates bill type attributes to ExpenseAdapter' do
    adapter = instance_double(::CCLF::ExpenseAdapter)
    expect(::CCLF::ExpenseAdapter).to receive(:new).with(expense).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    subject
  end
end
