require 'rails_helper'
require 'spec_helper'

RSpec.describe API::Entities::CCLF::AdaptedExpense, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(expense).to_json, symbolize_names: true) }

  let(:expense_type) { instance_double(::ExpenseType, unique_code: 'CAR') }
  let(:case_type) { instance_double(::CaseType, fee_type_code: 'FXACV') }
  let(:claim) { instance_double(::Claim::BaseClaim, case_type: case_type) }
  let(:expense) { instance_double(::Expense, claim: claim, expense_type: expense_type, amount: 9.99, vat_amount: 1.99) }

  it 'exposes the required keys' do
    expect(response.keys).to match_array(%i[bill_type bill_subtype total vat_included])
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'DISBURSEMENT',
      bill_subtype: 'TRAVEL COSTS',
      total: '11.98',
      vat_included: true
    )
  end

  it 'delegates bill mappings to DisbursementAdapter' do
    adapter = instance_double(::CCLF::ExpenseAdapter)
    expect(::CCLF::ExpenseAdapter).to receive(:new).with(expense).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    expect(adapter).to receive(:total)
    expect(adapter).to receive(:vat_included)
    subject
  end
end
