require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::AdaptedMiscFee do
  subject(:response) { JSON.parse(described_class.represent(adapted_misc_fee).to_json).deep_symbolize_keys }

  let(:claim) { create(:claim) }
  let(:misc_fee) { create(:misc_fee, :mispf_fee, claim: claim, quantity: 1.1, rate: 25) }
  let(:adapted_misc_fee) { ::CCR::Fee::MiscFeeAdapter.new.call(misc_fee) }

  it 'has expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_MISC_FEES',
      bill_subtype: 'SPECIAL_PREP',
      quantity: '1.1',
      rate: '25.0',
      amount: '27.5',
      case_numbers: nil
    )
  end
end
