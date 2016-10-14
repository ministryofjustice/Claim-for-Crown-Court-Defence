require 'rails_helper'
require 'spec_helper'

describe API::Entities::Fee do

  let(:fee) { build(:interim_fee, :warrant, date: Date.new(1995, 6, 20), quantity: 148.0, amount: 37.0) }

  it 'represents the fee entity' do
    result = described_class.represent(fee)
    expect(result.to_json).to eq '{"type":"Warrant","code":"IWARR","date":"1995-06-20T00:00:00Z","quantity":148.0,"amount":37.0,"rate":0.0,"dates_attended":[]}'
  end
end
