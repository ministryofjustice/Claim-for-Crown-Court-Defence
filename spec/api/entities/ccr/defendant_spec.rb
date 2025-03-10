require 'rails_helper'

describe API::Entities::CCR::Defendant do
  subject(:response) { JSON.parse(described_class.represent(defendant).to_json).deep_symbolize_keys }

  let(:claim) { create(:advocate_claim) }
  let(:rep_orders) { create_list(:representation_order, 1, uuid: 'uuid', maat_reference: '2345678', representation_order_date: Time.zone.today - 30.days) }

  let(:defendant) do
    create(
      :defendant,
      uuid: 'uuid',
      first_name: 'Kaia',
      last_name: 'Casper',
      date_of_birth: Time.zone.today - 30.years,
      representation_orders: rep_orders,
      claim:,
      created_at: @created_at
    )
  end

  it 'has expected json key-value pairs' do
    expect(response).to include(main_defendant: false, first_name: 'Kaia', last_name: 'Casper', date_of_birth: (Time.zone.today - 30.years).strftime('%Y-%m-%d'))
  end

  it 'returns main defendant true for the defendant created first' do
    @created_at = 1.minute.ago
    expect(response[:main_defendant]).to be true
  end

  it 'returns main defendant false for defendant created after other defendants' do
    @created_at = 1.minute.from_now
    expect(response[:main_defendant]).to be false
  end

  it 'returns representation order' do
    expect(response[:representation_orders].first).to include(maat_reference: '2345678', representation_order_date: (Time.zone.today - 30.days).strftime('%Y-%m-%d'))
  end

  context 'when the defendant has more than one rep_order' do
    let(:rep_orders) do
      [
        create(:representation_order, maat_reference: '2345678', representation_order_date: Time.zone.today - 30.days),
        create(:representation_order, maat_reference: '8765432', representation_order_date: Time.zone.today - 29.days)
      ]
    end

    it 'returns a single rep_order' do
      expect(response[:representation_orders].count).to eq 1
    end

    it 'returns the first representation order entered' do
      expect(response[:representation_orders].first).to include(maat_reference: '2345678', representation_order_date: (Time.zone.today - 30.days).strftime('%Y-%m-%d'))
    end
  end
end
