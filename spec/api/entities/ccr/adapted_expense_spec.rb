require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::AdaptedExpense do
  subject(:response) { JSON.parse(described_class.represent(expense).to_json) }

  let(:expense) { create(:expense, :bike_travel, location: 'A court') }

  describe 'exposes the correct keys' do
    subject { JSON.parse(described_class.represent(expense).to_json) }

    it 'exposes the correct keys' do
      expect(response.keys).to match(%w[bill_type bill_subtype date_incurred description quantity rate])
    end
  end

  it 'exposes expected json key-value pairs' do
    expect(response).to contain_exactly(
      ['bill_type', 'AGFS_EXPENSES'],
      ['bill_subtype', 'AGFS_TCT_TRV_BK'],
      ['date_incurred', 3.days.ago.strftime('%Y-%m-%d')],
      ['description', 'A court'],
      ['quantity', '27.0'],
      ['rate', '0.2']
    )
  end
end
