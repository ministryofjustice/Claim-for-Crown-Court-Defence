require 'rails_helper'
require 'spec_helper'

describe API::Entities::Expense do

  let(:expense) { build(:expense, :car_travel, date: Date.new(1995, 6, 20), location: 'Here', quantity: 148.0, rate: 0.25, amount: 37.0, vat_amount: 5.2) }

  it 'represents the expense entity' do
    result = described_class.represent(expense)
    expect(result.to_json).to eq '{"date":"1995-06-20T00:00:00Z","type":"Car travel","location":"Here","mileage_rate":"45p","reason":"Pre-trial conference expert witnesses","distance":27.0,"hours":0.0,"quantity":148.0,"rate":0.25,"net_amount":37.0,"vat_amount":5.2}'
  end
end
