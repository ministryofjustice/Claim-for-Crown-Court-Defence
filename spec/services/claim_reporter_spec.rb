require 'rails_helper'

RSpec.describe ClaimReporter do
  subject { ClaimReporter.new }

  let!(:draft_claim_1) { create(:draft_claim, form_id: SecureRandom.uuid) }
  let!(:authorised_claim_1) { create(:authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid) }
  let!(:submitted_claim_1) { create(:submitted_claim, form_id: SecureRandom.uuid) }
  let!(:allocated_claim_1) { create(:allocated_claim, form_id: SecureRandom.uuid) }
  let!(:allocated_claim_2) { create(:allocated_claim, form_id: SecureRandom.uuid) }
  let!(:part_authorised_claim_1) { create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid) }
  let!(:part_authorised_claim_2) { create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid) }
  let!(:rejected_claim_1) { create(:rejected_claim, form_id: SecureRandom.uuid) }
  let!(:rejected_claim_2) { create(:rejected_claim, form_id: SecureRandom.uuid) }

  let!(:old_part_authorised_claim) { create(:part_authorised_claim, form_id: SecureRandom.uuid).update_column(:authorised_at, 5.weeks.ago) }
  let!(:old_rejected_claim) { create(:rejected_claim, form_id: SecureRandom.uuid).claim_state_transitions.last.update_column(:created_at, 5.weeks.ago) }

  describe '#authorised_in_full' do
    it 'returns the percentage of claims authorised in full this month' do
      expect(subject.authorised_in_full).to eq(10)
    end
  end

  describe '#authorised_in_part' do
    it 'returns the percentage of claims authorised in part this month' do
      expect(subject.authorised_in_part).to eq(20)
    end
  end

  describe '#rejected' do
    it 'returns the percentage of claims rejected this month' do
      expect(subject.rejected).to eq(20)
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

  describe '#completion_rate' do
    before do
      create(:claim_intention, form_id: submitted_claim_1.form_id)
      create(:claim_intention, form_id: allocated_claim_1.form_id)

      create(:claim_intention, form_id: SecureRandom.uuid)
      create(:claim_intention, form_id: SecureRandom.uuid)

    end

    it 'returns the completion rate for claims in the last 16 weeks' do
      expect(subject.completion_rate).to eq(50.0)
    end
  end
end
