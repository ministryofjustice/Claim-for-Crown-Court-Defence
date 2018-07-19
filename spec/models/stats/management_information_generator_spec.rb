require 'rails_helper'

RSpec.describe Stats::ManagementInformationGenerator do
  let(:frozen_time) { Time.new(2015, 3, 10, 11, 44, 55) }

  context 'data generation' do
    let!(:valid_claims) {
      [
        create(:allocated_claim),
        create(:authorised_claim),
        create(:part_authorised_claim)
      ]
    }
    let!(:draft_claim) { create(:draft_claim) }
    let!(:non_active_claim) { Timecop.freeze(frozen_time) { create(:allocated_claim) } }

    it 'returns CSV content with a header and a row for all active non-draft claims' do
      result = described_class.call
      expect(result.split("\n").size).to eq(valid_claims.size + 1)
    end
  end
end
