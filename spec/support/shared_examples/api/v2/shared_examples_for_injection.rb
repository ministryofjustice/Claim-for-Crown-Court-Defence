RSpec.shared_examples 'injection data with defendants' do
  subject(:response) { do_request.body }

  let(:defendants) { create_list(:defendant, 2) }

  it 'returns multiple defendants' do
    is_expected.to have_json_size(2).at_path('defendants')
  end

  it 'returns defendants in order created marking earliest created as the "main" defendant' do
    is_expected.to be_json_eql('true').at_path('defendants/0/main_defendant')
  end

  context 'with representation orders' do
    let(:defendants) do
      [
        create(
          :defendant,
          representation_orders: create_list(:representation_order, 2, representation_order_date: 5.days.ago)
        ),
        create(
          :defendant,
          representation_orders: [create(:representation_order, representation_order_date: 2.days.ago)]
        )
      ]
    end

    it 'returns the earliest of the representation orders' do
      is_expected.to have_json_size(1).at_path('defendants/0/representation_orders')
    end

    it 'returns earliest rep order first (per defendant)' do
      is_expected
        .to be_json_eql(claim.earliest_representation_order_date.to_json)
        .at_path('defendants/0/representation_orders/0/representation_order_date')
    end
  end
end
