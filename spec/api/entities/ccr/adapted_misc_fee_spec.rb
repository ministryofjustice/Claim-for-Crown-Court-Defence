require 'rails_helper'

describe API::Entities::CCR::AdaptedMiscFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_misc_fee).to_json).deep_symbolize_keys }

  let(:claim) { create(:advocate_claim) }

  let(:misc_fee) do
    create(
      :misc_fee, :mispf_fee, :with_date_attended,
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

  context '#number_of_defendants' do
    subject { response[:number_of_defendants] }

    let(:miaph) { create(:misc_fee_type, :miaph) }
    let(:miahu) { create(:misc_fee_type, :miahu) }
    let(:misc_fee) { claim.misc_fees.find_by(fee_type_id: miaph.id) }
    let(:adapted_misc_fee) { ::CCR::Fee::MiscFeeAdapter.new.call(misc_fee) }

    before do
      create(:misc_fee, :with_date_attended, fee_type: miaph, claim: claim, quantity: 1, rate: 25)
    end

    context 'when matching misc fee (defendant) uplift NOT claimed' do
      it 'returns 1 for the main defendant' do
        is_expected.to eq '1'
      end
    end

    context 'when 1 matching misc fee (defendant) uplift claimed' do
      before do
        create(:misc_fee, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
      end

      it 'returns sum of (defendant) uplift quantity plus one for the main defendant' do
        is_expected.to eq '3'
      end
    end

    context 'when more than 1 matching misc fee (defendant) uplift claimed' do
      before do
        create_list(:misc_fee, 2, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
      end

      it 'returns sum of all (defendant) uplift quantities plus one for the main defendant' do
        is_expected.to eq '5'
      end
    end
  end

  context 'when fee type type is excluded' do
    let(:misc_fee) { create(:misc_fee, :miphc_fee, claim: claim) }

    it 'exposes bill_type as nil' do
      expect(response).to include(bill_type: nil)
    end

    it 'exposes bill_subtype as nil' do
      expect(response).to include(bill_subtype: nil)
    end
  end
end
