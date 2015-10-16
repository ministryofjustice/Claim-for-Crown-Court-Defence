require 'rails_helper'

RSpec.describe Claims::Cloner, type: :model do
  let!(:rejected_claim) do
    rejected_claim = create(:rejected_claim)
    rejected_claim.expenses << create(:expense)
    rejected_claim.expenses.each do |expense|
      expense.dates_attended << create(:date_attended)
    end
    rejected_claim.documents << create(:document)
    rejected_claim
  end

  describe '#clone_rejected_to_new_draft' do
    let!(:cloned_claim) { rejected_claim.clone_rejected_to_new_draft }

    it 'cannot be used to clone non-rejected claims' do
      [
        create(:draft_claim),
        create(:submitted_claim),
        create(:allocated_claim),
        create(:authorised_claim),
        create(:part_authorised_claim),
        create(:refused_claim),
        create(:redetermination_claim),
        create(:awaiting_written_reasons_claim)
      ].each do |claim|
        expect{ claim.clone_rejected_to_new_draft }.to raise_error
      end
    end

    it 'creates a draft claim' do
      expect(cloned_claim).to be_draft
    end

    it 'does not clone the submitted_at date' do
      expect(cloned_claim.submitted_at).to be_nil
    end

    it 'does not clone the uuid' do
      expect(cloned_claim.reload.uuid).to_not eq(rejected_claim.uuid)
    end

    it 'does not clone the uuids of fees' do
      expect(cloned_claim.fees.map(&:reload).map(&:uuid)).to_not match_array(rejected_claim.fees.map(&:reload).map(&:uuid))
    end

    it 'does not clone the uuids of expenses' do
      expect(cloned_claim.expenses.map(&:reload).map(&:uuid)).to_not match_array(rejected_claim.expenses.map(&:reload).map(&:uuid))
    end

    it 'does not clone the uuids of documents' do
      expect(cloned_claim.documents.map(&:reload).map(&:uuid)).to_not match_array(rejected_claim.documents.map(&:reload).map(&:uuid))
    end

    it 'does not clone the uuids of defendants' do
      expect(cloned_claim.defendants.map(&:reload).map(&:uuid)).to_not match_array(rejected_claim.defendants.map(&:reload).map(&:uuid))
    end

    it 'does not clone the uuids of representation orders' do
      cloned_claim_uuids = cloned_claim.defendants.map(&:reload).map { |d| d.representation_orders.map(&:reload).map(&:uuid ) }.flatten
      rejected_claim_uuids = rejected_claim.defendants.map(&:reload).map { |d| d.representation_orders.map(&:reload).map(&:uuid ) }.flatten
      expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
    end

    it 'does not clone the uuids of dates attended' do
      cloned_claim_uuids = cloned_claim.expenses.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
      rejected_claim_uuids = rejected_claim.expenses.map(&:reload).map { |e| e.dates_attended.map(&:reload).map(&:uuid ) }.flatten
      expect(cloned_claim_uuids).to_not match_array(rejected_claim_uuids)
    end

    it 'clones the fees' do
      expect(cloned_claim.fees.count).to eq(rejected_claim.fees.count)

      cloned_claim.fees.each_with_index do |fee, index|
        expect(fee.amount).to eq(rejected_claim.fees[index].amount)
      end
    end

    it 'clones the expenses' do
      expect(cloned_claim.reload.expenses.count).to eq(rejected_claim.expenses.count)
    end

    it 'clones the expenses\' dates attended' do
      expect(cloned_claim.expenses.map { |e| e.dates_attended.count }).to eq(rejected_claim.expenses.map { |e| e.dates_attended.count })
    end

    it 'clones the defendants' do
      expect(cloned_claim.defendants.count).to eq(rejected_claim.defendants.count)
      expect(cloned_claim.defendants.map(&:name)).to eq(rejected_claim.defendants.map(&:name))
    end

    it 'clones the defendant\'s representation orders' do
      expect(cloned_claim.defendants.map { |d| d.representation_orders.count }).to eq(rejected_claim.defendants.map { |d| d.representation_orders.count })
    end

    it 'clones the documents' do
      expect(cloned_claim.documents.count).to eq(1)
      expect(cloned_claim.documents.count).to eq(rejected_claim.documents.count)
    end
  end
end
