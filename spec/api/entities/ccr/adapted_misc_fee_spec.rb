require 'rails_helper'
require 'spec_helper'

describe API::Entities::CCR::AdaptedMiscFee do
  subject(:response) { JSON.parse(described_class.represent(adapted_misc_fee).to_json).deep_symbolize_keys }

  let(:claim) { create(:claim) }
  let(:misc_fee) do
    create(:misc_fee, :mispf_fee, :with_date_attended,
      claim: claim,
      quantity: 1.1,
      rate: 25
    )
  end
  let(:adapted_misc_fee) { ::CCR::Fee::MiscFeeAdapter.new.call(misc_fee) }

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_MISC_FEES',
      bill_subtype: 'AGFS_SPCL_PREP',
      quantity: '1.1',
      rate: '25.0',
      amount: '27.5',
      case_numbers: nil
    )
  end

  it 'exposes dates attended in JSON compatible format' do
    from = misc_fee.dates_attended.first.date&.iso8601
    to = misc_fee.dates_attended.first.date_to&.iso8601
    expect(response[:dates_attended].first).to include(from: from, to: to)
  end
end
