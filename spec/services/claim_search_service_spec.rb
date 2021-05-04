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

  context 'with a case number search' do
    let(:params) { { status: 'allocated', search: 'T202001' } }
    let!(:expected_search) { [create(:allocated_claim, case_number: 'T20200101')] }

    before { create :allocated_claim, case_number: 'T20209999' }

    it { is_expected.to match_array expected_search }
  end

  context 'with a case-insensitive case number search' do
    let(:params) { { status: 'allocated', search: 't202001' } }
    let!(:expected_search) { [create(:allocated_claim, case_number: 'T20200101')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a defendants forename search' do
    let(:params) { { status: 'allocated', search: 'mic' } }
    let(:expected_search) { [create(:allocated_claim, defendants: [build(:defendant, first_name: 'Michael')])] }

    before { create :allocated_claim, defendants: [build(:defendant, first_name: 'Tom', last_name: 'Cruise')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a defendants surname search' do
    let(:params) { { status: 'allocated', search: 'cai' } }
    let(:expected_search) { [create(:allocated_claim, defendants: [build(:defendant, last_name: 'Caine')])] }

    before { create :allocated_claim, defendants: [build(:defendant, first_name: 'Tom', last_name: 'Cruise')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a MAAT reference search' do
    let(:params) { { status: 'allocated', search: '5123' } }
    let(:representation_order) { build :representation_order, maat_reference: 5_123_456 }
    let(:defendant) { build :defendant, representation_orders: [representation_order] }
    let(:expected_search) { [create(:allocated_claim, defendants: [defendant])] }

    before { create :allocated_claim, defendants: [build(:defendant)] }

    it { is_expected.to match_array expected_search }
  end
end
