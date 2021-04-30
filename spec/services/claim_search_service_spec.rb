require 'rails_helper'

RSpec.describe ClaimSearchService, type: :service do
  subject(:result) { described_class.call(**params) }

  context 'when there are no options' do
    let(:params) { {} }
    let(:expected_search) do
      [
        create(:authorised_claim),
        create(:authorised_claim)
      ]
    end

    it 'returns all the claims' do
      expect(result).to match_array expected_search
    end

    it 'does not return a deleted claim' do
      expected_search.first.delete
      expect(result).not_to include expected_search.first
    end
  end

  context 'when the status is archived' do
    let(:params) { { status: 'archived' } }
    let(:expected_search) do
      [
        create(:authorised_claim),
        create(:part_authorised_claim),
        create(:rejected_claim),
        create(:refused_claim),
        create(:archived_pending_delete_claim),
        create(:hardship_archived_pending_review_claim)
      ]
    end

    before do
      create :allocated_claim
      create :submitted_claim
      create :redetermination_claim
      create :awaiting_written_reasons_claim
    end

    it { is_expected.to match_array expected_search }
  end

  context 'when the status is allocated' do
    let(:params) { { status: 'allocated' } }
    let(:expected_search) { [create(:allocated_claim)] }

    before do
      create :submitted_claim
      create :redetermination_claim
      create :awaiting_written_reasons_claim
      create :authorised_claim
      create :part_authorised_claim
      create :rejected_claim
      create :refused_claim
      create :archived_pending_delete_claim
      # create :hardship_archived_pending_review_claim
    end

    it { is_expected.to match_array expected_search }
  end
end
