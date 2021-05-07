require 'rails_helper'

RSpec.describe ClaimSearchService, type: :service do
  subject(:result) { described_class.call(**params) }

  context 'when there are no options' do
    let(:params) { {} }
    let(:expected_search) do
      [
        create(:authorised_claim),
        create(:authorised_claim),
        create(:rejected_claim),
        create(:refused_claim),
        create(:part_authorised_claim),
        create(:archived_pending_delete_claim),
        create(:allocated_claim),
        create(:submitted_claim),
        create(:redetermination_claim),
        create(:awaiting_written_reasons_claim)
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

  context 'when there is a state filter' do
    let(:params) { { state: [:authorised, :rejected, :refused] } }
    let(:expected_search) do
      [
        create(:authorised_claim),
        create(:rejected_claim),
        create(:refused_claim)
      ]
    end

    before do
      create :part_authorised_claim
      create :archived_pending_delete_claim
      create :allocated_claim
      create :submitted_claim
      create :redetermination_claim
      create :awaiting_written_reasons_claim
    end

    it { is_expected.to match_array expected_search }
  end

  context 'with a case number search' do
    let(:params) { { term: 'T202001' } }
    let!(:expected_search) { [create(:allocated_claim, case_number: 'T20200101')] }

    before { create :allocated_claim, case_number: 'T20209999' }

    it { is_expected.to match_array expected_search }
  end

  context 'with a case-insensitive case number search' do
    let(:params) { { term: 't202001' } }
    let!(:expected_search) { [create(:allocated_claim, case_number: 'T20200101')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a defendants forename search' do
    let(:params) { { term: 'mic' } }
    let(:expected_search) { [create(:allocated_claim, defendants: [build(:defendant, first_name: 'Michael')])] }

    before { create :allocated_claim, defendants: [build(:defendant, first_name: 'Tom', last_name: 'Cruise')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a defendants surname search' do
    let(:params) { { term: 'cai' } }
    let(:expected_search) { [create(:allocated_claim, defendants: [build(:defendant, last_name: 'Caine')])] }

    before { create :allocated_claim, defendants: [build(:defendant, first_name: 'Tom', last_name: 'Cruise')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a defendants full name search' do
    let(:params) { { term: 'michael caine' } }
    let(:expected_search) do
      [create(:allocated_claim, defendants: [build(:defendant, first_name: 'Michael', last_name: 'Caine')])]
    end

    before { create :allocated_claim, defendants: [build(:defendant, first_name: 'Tom', last_name: 'Cruise')] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a MAAT reference search' do
    let(:params) { { term: '5123' } }
    let(:representation_order) { build :representation_order, maat_reference: 5_123_456 }
    let(:defendant) { build :defendant, representation_orders: [representation_order] }
    let(:expected_search) { [create(:allocated_claim, defendants: [defendant])] }

    before { create :allocated_claim, defendants: [build(:defendant)] }

    it { is_expected.to match_array expected_search }
  end

  context 'with a caseworker name search' do
    let(:case_worker) { build :case_worker, user: build(:user, first_name: 'Michael', last_name: 'Caine') }
    let(:params) { { user: user, term: 'michael caine' } }

    context 'when the user is an admin' do
      let(:user) { create :case_worker, :admin }
      let(:expected_search) { [create(:allocated_claim, case_workers: [case_worker])] }

      it { is_expected.to match_array expected_search }
    end

    context 'when the user is not an admin' do
      let(:user) { create :case_worker }
      let!(:claim) { create :allocated_claim, case_workers: [case_worker] }

      it { is_expected.not_to include claim }
    end
  end

  context 'with a caseworker email search' do
    let(:case_worker) { build :case_worker, user: build(:user, email: 'michaelcaine@example.com') }
    let(:params) { { user: user, term: 'haelcai' } }

    context 'when the user is an admin' do
      let(:user) { create :case_worker, :admin }
      let(:expected_search) { [create(:allocated_claim, case_workers: [case_worker])] }

      it { is_expected.to match_array expected_search }
    end

    context 'when the user is not an admin' do
      let(:user) { create :case_worker }
      let!(:claim) { create :allocated_claim, case_workers: [case_worker] }

      it { is_expected.not_to include claim }
    end
  end

  context 'with an agfs scheme' do
    let(:params) { { scheme: 'agfs' } }
    let(:expected_search) do
      [
        create(:advocate_claim),
        create(:advocate_interim_claim),
        create(:advocate_supplementary_claim),
        create(:advocate_hardship_claim)
      ]
    end

    before do
      create :litigator_claim
      create :interim_claim
      create :transfer_claim
      create :litigator_hardship_claim
    end

    it { is_expected.to match_array expected_search }
  end

  context 'with an lgfs scheme' do
    let(:params) { { scheme: 'lgfs' } }
    let(:expected_search) do
      [
        create(:litigator_claim),
        create(:interim_claim),
        create(:transfer_claim),
        create(:litigator_hardship_claim)
      ]
    end

    before do
      create :advocate_claim
      create :advocate_interim_claim
      create :advocate_supplementary_claim
      create :advocate_hardship_claim
    end

    it { is_expected.to match_array expected_search }
  end
end
