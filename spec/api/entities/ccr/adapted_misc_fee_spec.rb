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

  context '#number_of_defendants' do
    subject { response[:number_of_defendants] }

    let(:miaph) { create(:misc_fee_type, :miaph) }
    let(:miahu) { create(:misc_fee_type, :miahu) }
    let(:misc_fee) { claim.misc_fees.find_by(fee_type_id: miaph.id) }
    let(:adapted_misc_fee) { ::CCR::Fee::MiscFeeAdapter.new.call(misc_fee) }

    before do
      create(:misc_fee, :with_date_attended, fee_type: miaph, claim: claim, quantity: 1.1, rate: 25)
    end

    context 'when matching misc fee uplift NOT claimed' do
      it 'returns 1 for the main defendant' do
        is_expected.to eq "1"
      end
    end

    context 'when 1 matching misc fee (defendant) uplift claimed' do
      before do
        create(:misc_fee, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
      end

      it 'returns sum of (defendant) uplift quantity plus one for the main defendant' do
        is_expected.to eq "3"
      end
    end

    context 'when more than 1 matching misc fee (defendant) uplift claimed' do
      before do
        create_list(:misc_fee, 2, fee_type: miahu, claim: claim, quantity: 2, amount: 21.01)
      end

      it 'returns sum of all (defendant) uplift quantities plus one for the main defendant' do
        is_expected.to eq "5"
      end
    end

    describe '::DEFENDANT_UPLIFT_MAPPINGS' do
      subject { described_class::DEFENDANT_UPLIFT_MAPPINGS[code] }

      EXPECTED_MAPPINGS = {
          BASAF: 'MISAU', # Standard appearance fee uplift
          MIAPH: 'MIAHU', # Abuse of process hearings (half day uplift)
          MIAPW: 'MIAWU', # Abuse of process hearings (whole day uplift)
          MIADC1: 'MIADC3', # Application to dismiss a charge (half day uplift)
          MIADC2: 'MIADC4', # Application to dismiss a charge (whole day uplift)
          MIDTH: 'MIDHU', # Confiscation hearings (half day uplift)
          MIDTW: 'MIDWU', # Confiscation hearings (whole day uplift)
          MIDSE: 'MIDSU', # Deferred sentence hearings uplift
          MIAEH: 'MIEHU', # Hearings relating to admissibility of evidence (half day uplift)
          MIAEW: 'MIEWU', # Hearings relating to admissibility of evidence (whole day uplift)
          MIHDH: 'MIHHU', # Hearings relating to disclosure (half day uplift)
          MIHDW: 'MIHWU', # Hearings relating to disclosure (whole day uplift)
          MIPPC: 'MIPCU', # Paper plea & case management uplift
          MIPCH: 'MICHU', # Proceeds of crime hearings (half day uplift)
          MIPCW: 'MICHW', # Proceeds of crime hearings (whole day uplift)
          MIPIH1: 'MIPIU3', # Public interest immunity hearings (half day uplift)
          MIPIH2: 'MIPIH4', # Public interest immunity hearings (whole day uplift)
          MISHR: 'MISHU', # Sentence hearings uplift
          MITNP: 'MITNU', # Trial not proceed uplift
          MIUAV1: 'MIUAV3', # Unsuccessful application to vacate a guilty plea (half day uplift)
          MIUAV2: 'MIUAV4', # Unsuccessful application to vacate a guilty plea (whole day uplift)
      }.freeze

      context 'mappings' do
        EXPECTED_MAPPINGS.each do |code, uplift_code|
          context "code #{code}" do
            let(:code) { code }

            it "returns #{uplift_code}" do
              is_expected.to eql uplift_code
            end
          end
        end
      end
    end
  end
end
