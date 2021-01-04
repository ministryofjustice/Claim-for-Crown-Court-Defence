require 'rails_helper'

describe API::Entities::CCR::AdaptedFixedFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_fixed_fees).to_json).deep_symbolize_keys }

  let(:claim) { create(:authorised_claim, case_number: 'T20160001') }
  let(:fxcbr) { create(:fixed_fee_type, :fxcbr) }
  let(:fxcbu) { create(:fixed_fee_type, :fxcbu) }
  let(:fxndr) { create(:fixed_fee_type, :fxndr) }
  let(:fxnoc) { create(:fixed_fee_type, :fxnoc) }

  let(:adapted_fixed_fees) { ::CCR::Fee::FixedFeeAdapter.new.call(claim) }

  context 'when an applicable fixed fee is claimed' do
    let(:case_type) { build(:case_type, :fixed_fee, fee_type_code: 'FXCBR', requires_maat_reference: false) }
    let(:claim) { create(:authorised_claim, case_number: 'T20160001', case_type: case_type) }

    before do |example|
      create(:fixed_fee, fee_type: fxcbr, claim: claim, quantity: 13) unless example.metadata[:skip_fee]
      create(:fixed_fee, fee_type: fxcbu, claim: claim, quantity: 2, case_numbers: 'T20170001,T20170002') unless example.metadata[:skip_uplifts]
    end

    it 'exposes expected json key-value pairs' do
      expect(response).to include(
        bill_type: 'AGFS_FEE',
        bill_subtype: 'AGFS_ORDER_BRCH',
        daily_attendances: '13',
        number_of_cases: '3',
        number_of_defendants: '1',
        case_numbers: 'T20170001,T20170002'
      )
    end

    it 'does not expose unneccesary fee attributes' do
      expect(response.keys).not_to include(:quantity, :rate, :amount)
    end

    context '#case_numbers (and #number_of_cases)' do
      subject { response[:case_numbers].split(',') }
      let(:number_of_cases) { response[:number_of_cases] }

      context 'when no case uplifts exist', :skip_uplifts do
        it 'returns 1 for number_of_cases' do
          is_expected.to be_blank
          expect(number_of_cases).to eql '1'
        end
      end

      context 'when one or more case uplifts exist' do
        it 'includes additional case numbers for all uplift versions of the fixed fee type' do
          create(:fixed_fee, fee_type: fxcbu, claim: claim, quantity: 2, case_numbers: 'T20170003,T20170004')
          is_expected.to match_array %w(T20170001 T20170002 T20170003 T20170004)
          expect(number_of_cases).to eq '5'
        end

        it 'includes additional case numbers for Number of cases uplift fixed fees' do
          create(:fixed_fee, fee_type: fxnoc, claim: claim, quantity: 2, case_numbers: 'T20170005,T20170006')
          is_expected.to match_array %w(T20170001 T20170002 T20170005 T20170006)
          expect(number_of_cases).to eq '5'
        end

        it 'strips whitespace' do
          create(:fixed_fee, fee_type: fxcbu, claim: claim, quantity: 2, case_numbers: ' T20170003, T20170004 ')
          is_expected.to match_array %w(T20170001 T20170002 T20170003 T20170004)
          expect(number_of_cases).to eq '5'
        end

        it 'excludes repeated additional case numbers' do
          create(:fixed_fee, fee_type: fxcbu, claim: claim, quantity: 2, case_numbers: 'T20170001,T20170003')
          is_expected.to contain_exactly('T20170001','T20170002','T20170003')
          expect(number_of_cases).to eq '4'
        end
      end
    end

    context '#daily_attendances' do
      subject { response[:daily_attendances] }

      context 'when no fixed fee matching the case type exists' do
        it 'returns at least 1', :skip_fee do
          is_expected.to eql '1'
        end
      end

      context 'when one fixed fee matching the case type exists' do
        it 'returns fee quantity' do
          is_expected.to eql '13'
        end
      end

      context 'when more than one fixed fee matching the case type exists' do
        it 'returns sum of fee quantities' do
          create(:fixed_fee, fee_type: fxcbr, claim: claim, quantity: 12)
          is_expected.to eql '25'
        end
      end
    end

    context '#number_of_defendants' do
      subject { response[:number_of_defendants] }

      context 'when "Number of defendant uplifts" NOT claimed' do
        it 'returns 1 for the main defendant' do
          is_expected.to eq '1'
        end
      end

      context 'when "Number of defendant uplifts" claimed' do
        before do
          create_list(:fixed_fee, 2, fee_type: fxndr, claim: claim, quantity: 2)
        end

        it 'returns sum of all Number of defendants uplift quantities plus one for the main defendant' do
          is_expected.to eq '5'
        end
      end
    end
  end
end
