require 'rails_helper'

RSpec.describe Stats::ManagementInformationGenerator do
  let(:expected_headers) do
    [
      'Id',
      'Scheme',
      'Case number',
      'Supplier number',
      'Organisation',
      'Case type name',
      'Bill type',
      'Claim total',
      'Submission type',
      'Transitioned at',
      'Last submitted at',
      'Originally submitted at',
      'Allocated at',
      'Completed at',
      'Current or end state',
      'State reason code',
      'Rejection reason',
      'Case worker',
      'Disk evidence case',
      'Main defendant',
      'Maat reference',
      'Rep order issued date',
      'AF1/LF1 processed by',
      'Misc fees',
      'Main hearing date',
      'Source'
    ]
  end

  describe '#call' do
    subject(:call) { described_class.new.call }

    let(:csv) { CSV.parse(call.content, headers: true) }

    before do
      # excluded from MI report
      create(:advocate_final_claim, :draft)
      create(:advocate_final_claim, :authorised).soft_delete
      travel_to(6.months.ago.beginning_of_day - 1.second) { create(:advocate_final_claim, :allocated) }

      # included in MI report
      create(:litigator_final_claim, :submitted)
      create(:litigator_final_claim, :rejected)
      create(:advocate_final_claim, :submitted)
      create(:advocate_final_claim, :allocated)
      create(:advocate_final_claim, :part_authorised)
      travel_to(6.months.ago.beginning_of_day) { create(:advocate_final_claim, :authorised) }
    end

    it 'has expected headers' do
      expect(csv.headers).to match_array(expected_headers)
    end

    context 'with no scope' do
      subject(:call) { described_class.new.call }

      it 'returns rows of all active non-draft claims' do
        expect(csv['Scheme']).to match_array(%w[LGFS LGFS AGFS AGFS AGFS AGFS])
      end
    end

    context 'with AGFS scope' do
      subject(:call) { described_class.new(scheme: :agfs).call }

      it 'returns rows of AGFS active non-draft claims' do
        expect(csv['Scheme']).to match_array(%w[AGFS] * 4)
      end
    end

    context 'with LGFS scope' do
      subject(:call) { described_class.new(scheme: :lgfs).call }

      it 'returns rows of LGFS active non-draft claims' do
        expect(csv['Scheme']).to match_array(%w[LGFS] * 2)
      end
    end
  end

  context 'when logging without errors' do
    it 'log start and end' do
      expect(LogStuff).to receive(:info).twice
      described_class.call
    end
  end

  context 'when logging errors' do
    before do
      allow(CSV).to receive(:generate).and_raise(StandardError)
    end

    it 'uses LogStuff to log error' do
      expect(LogStuff).to receive(:error).once
      described_class.call
    end
  end
end
