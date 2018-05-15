require 'rails_helper'

describe API::Entities::CCR::Defendant do
  subject(:response) { JSON.parse(described_class.represent(defendant).to_json).deep_symbolize_keys }

  let(:claim) { create(:advocate_claim) }
  let(:rep_orders) { create_list(:representation_order, 1, uuid: 'uuid', maat_reference: '1234567890', representation_order_date: Date.new(2016, 1, 10)) }

  let(:defendant) do
    create(:defendant,
      uuid: 'uuid',
      first_name: 'Kaia',
      last_name: 'Casper',
      date_of_birth: Date.new(1995, 6, 20),
      representation_orders: rep_orders,
      claim: claim,
      created_at: @created_at
    )
  end

  it 'has expected json key-value pairs' do
    expect(response).to include(main_defendant: false, first_name: 'Kaia', last_name: 'Casper', date_of_birth: '1995-06-20')
  end

  it 'returns main defendant true for the defendant created first' do
    @created_at = 1.minute.ago
    expect(response[:main_defendant]).to eql true
  end

  it 'returns main defendant false for defendant created after other defendants' do
    @created_at = 1.minute.from_now
    expect(response[:main_defendant]).to eql false
  end

  it 'returns representation order' do
    expect(response[:representation_orders].first).to include(maat_reference: '1234567890', representation_order_date: '2016-01-10')
  end

end
