require 'rails_helper'

def amend_claim(claim, case_type_id, case_type_name)
  claim.update_attribute(:case_type_id, case_type_id)
  claim.update_attribute(:case_type, CaseType.where(name: case_type_name).first)
end

def find_row(month, scheme)
  csv.find { |row| row['Month'] == month && row['Fee scheme'] == scheme }
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

    let(:fee_scheme_array) do
      [
        'AGFS 9',
        'AGFS 10',
        'AGFS 11',
        'AGFS 12',
        'AGFS 13',
        'AGFS 14',
        'AGFS 15',
        'AGFS 16',
        'LGFS 9',
        'LGFS 10',
        'LGFS 11'
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
      expect(csv.headers).to eq(expected_headers)
    end

    context 'when generating the section 5 months ago' do
      subject(:call) { described_class.new.call }

      it 'correctly populates the LGFS 9 row' do
        expect(find_row(5.months.ago.strftime('%B'), 'LGFS 9')['Total number of claims']).to eq('1')
      end
    end

    context 'when generating the most recent month' do
      it 'returns rows containing the correct fee schemes' do
        expect(csv['Fee scheme'].uniq.compact).to eq(fee_scheme_array)
      end

      it 'returns the correct data for AGFS 9' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 9')[2..])
          .to contain_exactly('15', '380.0', anything, '13', '1', '0', '1', '0', '0', '0', '0', '1', '1',
                              '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '2')
      end

      it 'returns the correct data for LGFS 9' do
        expect(find_row(Time.zone.today.strftime('%B'), 'LGFS 9')[2..])
          .to contain_exactly('4', '75.02', anything, '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0',
                              '0', '0', '0', '0', '0', '0', '0', '0', '0', '2')
      end

      it 'returns the correct data for AGFS 13' do
        expect(find_row(Time.zone.today.strftime('%B'), 'AGFS 13')[2..])
          .to contain_exactly('1', '0.0', anything, '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0',
                              '0', '0', '0', '0', '0', '0', '0', '0', '1')
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
