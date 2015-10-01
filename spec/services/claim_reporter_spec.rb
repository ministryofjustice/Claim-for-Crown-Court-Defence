require 'rails_helper'

RSpec.describe ClaimReporter do
  subject { ClaimReporter.new }

  let!(:draft_claim_1) { create(:draft_claim) }
  let!(:paid_claim_1) { create(:paid_claim) }
  let!(:submitted_claim_1) { create(:submitted_claim) }
  let!(:allocated_claim_1) { create(:allocated_claim) }
  let!(:allocated_claim_2) { create(:allocated_claim) }
  let!(:part_paid_claim_1) { create(:part_paid_claim) }
  let!(:part_paid_claim_2) { create(:part_paid_claim) }
  let!(:rejected_claim_1) { create(:rejected_claim) }
  let!(:rejected_claim_2) { create(:rejected_claim) }

  let!(:old_part_paid_claim) { create(:part_paid_claim).update_column(:submitted_at, 5.weeks.ago) }
  let!(:old_rejected_claim) { create(:rejected_claim).update_column(:submitted_at, 5.weeks.ago) }

  describe '#paid_in_full' do
    it 'returns the percentage of claims paid in full this month' do
      expect(subject.paid_in_full).to eq(12.5)
    end
  end

  describe '#paid_in_part' do
    it 'returns the percentage of claims paid in part this month' do
      expect(subject.paid_in_part).to eq(25)
    end
  end

  describe '#rejected' do
    it 'returns the percentage of claims rejected this month' do
      expect(subject.rejected).to eq(25)
    end
  end

  describe '#outstanding' do
    it 'returns all outstanding claims' do
      expect(subject.outstanding).to match_array([submitted_claim_1, allocated_claim_1, allocated_claim_2])
    end
  end

  describe '#oldest_outstanding' do
    it 'returns the oldest outstanding claim' do
      expect(subject.oldest_outstanding).to eq(submitted_claim_1)
    end
  end
end
