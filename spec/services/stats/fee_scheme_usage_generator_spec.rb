require 'rails_helper'

def amend_claim(claim, case_type_id, case_type_name)
  claim.update_attribute(:case_type_id, case_type_id)
  claim.update_attribute(:case_type, CaseType.where(name: case_type_name).first)
end

RSpec.describe Stats::FeeSchemeUsageGenerator do
  let(:expected_headers) do
    [
      'Month',
      'Fee scheme',
      'Total number of claims',
      'Total value of claims',
      'Most recent claim',
      'Advocate claim',
      'Advocate hardship claim',
      'Advocate interim claim',
      'Advocate supplementary claim',
      'Interim claim',
      'Litigator claim',
      'Litigator hardship claim',
      'Transfer claim',
      'Appeal against conviction',
      'Appeal against sentence',
      'Breach of crown court order',
      'Committal for sentence',
      'Contempt',
      'Cracked trial',
      'Cracked before retrial',
      'Discontinuance',
      'Elected cases not proceeded',
      'Guilty plea',
      'Hearing subsequent to sentence',
      'Retrial',
      'Trial'
    ]
  end

  describe '#call' do
    subject(:call) { described_class.new.call }

    let(:csv) { CSV.parse(call.content, headers: true) }

    let(:total_claims_array) do
      ['0', '0', '0', '0', '0', '0', '0', '1', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '1', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '15', '0', '0', '0', '1', '0', '0', '4', '0', nil]
    end
    let(:fee_scheme_array) do
      [
        'AGFS 9',
        'AGFS 10',
        'AGFS 11',
        'AGFS 12',
        'AGFS 13',
        'AGFS 14',
        'AGFS 15',
        'LGFS 9',
        'LGFS 10'
      ]
    end

    before do
      seed_case_types

      # excluded from MI report
      create(:advocate_final_claim, :draft, case_type: CaseType.where(name: 'Trial').first)
      create(:advocate_final_claim, :authorised, case_type: CaseType.where(name: 'Trial').first).soft_delete
      travel_to(6.months.ago.beginning_of_day - 1.second) do
        create(:advocate_final_claim, :allocated, case_type: CaseType.where(name: 'Trial').first)
      end

      # included in MI report, advocate claims
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Appeal against conviction').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Appeal against sentence').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Breach of Crown Court order').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Committal for Sentence').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Contempt').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Discontinuance').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Elected cases not proceeded').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Guilty plea').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Hearing subsequent to sentence').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Retrial').first)
      create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      # This is a brute-force way of generating the following two test claims, but required due to factory errors
      cracked_trial = create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      cracked_before_retrial = create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      amend_claim(cracked_trial, 6, 'Cracked Trial')
      amend_claim(cracked_before_retrial, 7, 'Cracked before retrial')
      create(:advocate_hardship_claim, :authorised)
      create(:advocate_supplementary_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      create(:advocate_interim_claim, :submitted,
             create_defendant_and_rep_order_for_scheme_13: true,
             case_type: CaseType.where(name: 'Trial').first)

      # Included in MI report, litigator claims
      create(:litigator_hardship_claim, :submitted)
      create(:litigator_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      create(:interim_claim, :interim_warrant_fee, :submitted, case_type: CaseType.where(name: 'Trial').first)
      create(:transfer_claim, :with_transfer_detail, :submitted)

      # Included in MI report, past claims
      travel_to(4.months.ago.beginning_of_day) do
        create(:transfer_claim, :with_transfer_detail, :submitted)
      end
      travel_to(5.months.ago.beginning_of_day) do
        create(:transfer_claim, :with_transfer_detail, :submitted)
      end
    end

    it 'has expected headers' do
      expect(csv.headers).to match_array(expected_headers)
    end

    context 'when generating all month sections' do
      subject(:call) { described_class.new.call }

      it 'returns rows containing the correct numbers of total claims' do
        expect(csv['Total number of claims']).to match_array(total_claims_array)
      end
    end

    context 'when generating the most recent month' do
      it 'returns rows containing the correct fee schemes' do
        expect(csv['Fee scheme'][50...59]).to match_array(fee_scheme_array)
      end

      it 'returns rows containing the correct total value of claims' do
        expect(csv['Total value of claims'][50...60]).to contain_exactly(
          '380.0', '0', '0', '0', '0.0', '0', '0', '75.02', '0', nil
        )
      end

      it 'has the correct totals of claim and case types for AGFS 9' do
        expect(csv[50][5...26]).to contain_exactly(
          '13', '1', '0', '1', '0', '0', '0', '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '2'
        )
      end

      it 'has the correct totals of claim and case types for AGFS 13' do
        expect(csv[54][5...26]).to contain_exactly(
          '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1'
        )
      end

      it 'has the correct totals of claim and case types for LGFS 9' do
        expect(csv[57][5...26]).to contain_exactly(
          '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '2'
        )
      end
    end
  end

  context 'when logging without errors' do
    before do
      allow(LogStuff).to receive(:info)
    end

    it 'log start and end' do
      described_class.call
      expect(LogStuff).to have_received(:info).twice
    end
  end

  context 'when logging errors' do
    before do
      allow(CSV).to receive(:generate).and_raise(StandardError)
      allow(LogStuff).to receive(:error)
    end

    it 'uses LogStuff to log error' do
      described_class.call
      expect(LogStuff).to have_received(:error).once
    end
  end
end
