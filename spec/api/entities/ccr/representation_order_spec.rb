require 'rails_helper'

describe API::Entities::CCR::RepresentationOrder do
  subject(:response) { JSON.parse(described_class.represent(representation_order).to_json).deep_symbolize_keys }

  let(:representation_order) { build(:representation_order, uuid: 'uuid', maat_reference: '2345678', representation_order_date: Time.zone.today - 30.days) }

  it 'has expected json key-value pairs' do
    expect(response).to include(maat_reference: '2345678', representation_order_date: (Time.zone.today - 30.days).strftime('%Y-%m-%d'))
  end

  it 'returns representation_order_date in UTC format' do
    expect(response[:representation_order_date]).to eql (Time.zone.today - 30.days).strftime('%Y-%m-%d')
  end
end
