require 'rails_helper'

RSpec.describe Stats::ManagementInformationGenerator do
  let(:frozen_time) { Time.new(2015, 3, 10, 11, 44, 55) }
  let(:report_columns) do
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
      'Misc fees'
    ]
  end

  describe '#call' do
    subject(:call) { described_class.new.call }

    let(:rows) { call.content.split("\n") }

    let!(:valid_claims) {
      [
        create(:submitted_claim),
        create(:allocated_claim),
        create(:authorised_claim),
        create(:part_authorised_claim)
      ]
    }
    let!(:draft_claim) { create(:draft_claim) }
    let!(:non_active_claim) { travel_to(frozen_time) { create(:allocated_claim) } }

    it 'returns a row for all active non-draft claims' do
      expect(rows.size).to eq(valid_claims.size + 1)
    end

    it 'has expected headers' do
      expect(rows.first.split(',')).to match_array(report_columns)
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
