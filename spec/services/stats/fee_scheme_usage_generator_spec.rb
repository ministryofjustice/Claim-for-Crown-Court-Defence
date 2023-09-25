require 'rails_helper'

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
    # TODO: Would it be better to actually have this static for testing purposes?
    let(:total_claims_array) do
      ['1', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '1', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '0', '0', '0', '0', '0', '0', '0', '0', '0', nil,
       '3', '0', '0', '0', '0', '0', '0', '3', '0', nil]
    end
    let(:fee_scheme_array) do
      FeeScheme.where(name: 'AGFS')
               .map { |scheme| "#{scheme.name} #{scheme.version}" }
               .sort_by { |x| x[/\d+/].to_i } +
        FeeScheme.where(name: 'LGFS')
                 .map { |scheme| "#{scheme.name} #{scheme.version}" }
                 .sort_by { |x| x[/\d+/].to_i }
    end

    before do
      seed_case_types

      # excluded from MI report
      # create(:advocate_final_claim, :draft, case_type: CaseType.where(name: 'Trial').first)
      # create(:advocate_final_claim, :authorised, case_type: CaseType.where(name: 'Trial').first).soft_delete
      # travel_to(6.months.ago.beginning_of_day - 1.second) { create(:advocate_final_claim, :allocated, case_type: CaseType.where(name: 'Trial').first) }

      # included in MI report

      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Appeal against conviction').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Appeal against sentence').first)
      # # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Breach of crown court order').first)
      # ## create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Committal for sentence').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Contempt').first)
      # ## create(:advocate_claim, :submitted, )
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Cracked before retrial').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Discontinuance').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Elected cases not proceeded').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Guilty plea').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Hearing subsequent to sentence').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Retrial').first)
      # create(:advocate_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      # create(:advocate_supplementary_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      # create(:advocate_interim_claim, :submitted,
      #        create_defendant_and_rep_order_for_scheme_13: true,
      #        case_type: CaseType.where(name: 'Trial').first)
      #
      # create(:litigator_claim, :submitted, case_type: CaseType.where(name: 'Trial').first)
      # create(:interim_claim, :interim_warrant_fee, :submitted, case_type: CaseType.where(name: 'Trial').first)
      # create(:transfer_claim, :with_transfer_detail, :submitted)

      # Still creating false case type
      create(:litigator_hardship_claim_submitted, :submitted)
      # test = Claim::LitigatorHardshipClaim.create
      # binding.pry
      # This refuses to pass validation
      # create(:advocate_hardship_claim, :authorised)

      # travel_to(4.months.ago.beginning_of_day) do
      #   create(:litigator_final_claim, :authorised, case_type: CaseType.where(name: 'Trial').first)
      # end
      # travel_to(5.months.ago.beginning_of_day) do
      #   create(:advocate_final_claim, :authorised, case_type: CaseType.where(name: 'Trial').first)
      # end
    end

    xit 'has expected headers' do
      expect(csv.headers).to match_array(expected_headers)
    end

    context 'when generating all month sections' do
      subject(:call) { described_class.new.call }

      xit 'returns rows containing the correct numbers of total claims' do
        expect(csv['Total number of claims']).to match_array(total_claims_array)
      end
    end

    context 'when generating the most recent month' do
      xit 'returns rows containing the correct total value of claims' do
        expect(csv['Total value of claims'][50...60]).to contain_exactly(
          '75.0', '0', '0', '0', '0', '0', '0', '75.0', '0', nil
        )
      end

      xit 'has the correct fee scheme row headers' do # skipped

        expect(csv['Fee scheme'][50...59]).to match_array(fee_scheme_array)
      end

      it 'produces some debug files (remove this later)' do
        # TODO: remove this
        binding.pry
        test = Claim::BaseClaim.all.map { |claim| [claim.type, claim.state] }
        File.write('testclaims.txt', test)
        File.write('content.txt', call.content)
        File.write('csvP.txt', csv)
        File.write('debug.csv', csv)
      end
    end
  end

  context 'when logging without errors' do
    xit 'log start and end' do
      expect(LogStuff).to receive(:info).twice
      described_class.call
    end
  end

  context 'when logging errors' do
    before do
      allow(CSV).to receive(:generate).and_raise(StandardError)
    end

    xit 'uses LogStuff to log error' do
      expect(LogStuff).to receive(:error).once
      described_class.call
    end
  end
end
