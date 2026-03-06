require 'rails_helper'

RSpec.describe Claims::CaseWorkerClaimsLocal do
  let(:case_worker) { create(:case_worker) }

  describe '#claims' do
    subject(:claims) do
      described_class.new(
        current_user: case_worker.user, action:, sort_column:, sort_direction:
      ).claims
    end

    before do
      admin = create(:case_worker, :admin)
      allocator_options = {
        current_user: admin.user,
        case_worker_id: case_worker.id,
        deallocate: false,
        allocating: true
      }
      [
        create(:claim, case_number: 'C123'),
        create(:claim, case_number: 'C124'),
        create(:claim, case_number: 'C122')
      ].each do |claim|
        claim.submit!
        allocator_options[:claim_ids] = [claim.id]
        allocator = Allocation.new(allocator_options)
        allocator.save
        claim.reload
      end
      [
        create(:claim, :archived_pending_delete, case_number: 'C126'),
        create(:claim, :archived_pending_delete, case_number: 'C127'),
        create(:claim, :archived_pending_delete, case_number: 'C125')
      ].each { |claim| claim.case_workers = [case_worker] }
    end

    context 'with current action' do
      let(:action) { 'current' }

      let(:sort_column) { nil }
      let(:sort_direction) { nil }

      it { expect(claims.count).to eq(3) }

      context 'when sorting by case number ascending' do
        let(:sort_column) { 'case_number' }
        let(:sort_direction) { 'asc' }

        it { expect(claims[0].case_number).to eq('C122') }
        it { expect(claims[1].case_number).to eq('C123') }
        it { expect(claims[2].case_number).to eq('C124') }
      end

      context 'when sorting by case number descending' do
        let(:sort_column) { 'case_number' }
        let(:sort_direction) { 'desc' }

        it { expect(claims[0].case_number).to eq('C124') }
        it { expect(claims[1].case_number).to eq('C123') }
        it { expect(claims[2].case_number).to eq('C122') }
      end
    end

    context 'with archived action' do
      let(:action) { 'archived' }

      let(:sort_column) { nil }
      let(:sort_direction) { nil }

      it { expect(claims.count).to eq(3) }

      context 'when sorting by case number ascending' do
        let(:sort_column) { 'case_number' }
        let(:sort_direction) { 'asc' }

        it { expect(claims[0].case_number).to eq('C125') }
        it { expect(claims[1].case_number).to eq('C126') }
        it { expect(claims[2].case_number).to eq('C127') }
      end

      context 'when sorting by case number descending' do
        let(:sort_column) { 'case_number' }
        let(:sort_direction) { 'desc' }

        it { expect(claims[0].case_number).to eq('C127') }
        it { expect(claims[1].case_number).to eq('C126') }
        it { expect(claims[2].case_number).to eq('C125') }
      end
    end
  end

  describe '#navigation' do
    subject(:navigation) do
      described_class.new(current_user: case_worker.user, action: 'current').navigation(claim)
    end

    let(:claim) { instance_double(Claim::BaseClaim, id: 25) }

    before do
      selected_claims = instance_double(ActiveRecord::AssociationRelation, map: claim_ids)
      claims = instance_double(ActiveRecord::AssociationRelation, where: selected_claims)
      allow(case_worker).to receive(:claims).and_return(claims)
    end

    context 'when the claim is the first in the list' do
      let(:claim_ids) { [claim.id, 57, 19, 98] }

      it { expect(navigation[:previous]).to be_nil }
      it { expect(navigation[:next]).to eq(57) }
      it { expect(navigation[:position]).to eq(1) }
      it { expect(navigation[:count]).to eq(4) }
    end

    context 'when the claim is the second in the list' do
      let(:claim_ids) { [57, claim.id, 19, 98] }

      it { expect(navigation[:previous]).to eq(57) }
      it { expect(navigation[:next]).to eq(19) }
      it { expect(navigation[:position]).to eq(2) }
      it { expect(navigation[:count]).to eq(4) }
    end

    context 'when the claim is the third in the list' do
      let(:claim_ids) { [57, 19, claim.id, 98] }

      it { expect(navigation[:previous]).to eq(19) }
      it { expect(navigation[:next]).to eq(98) }
      it { expect(navigation[:position]).to eq(3) }
      it { expect(navigation[:count]).to eq(4) }
    end

    context 'when the claim is the fourth in the list' do
      let(:claim_ids) { [57, 19, 98, claim.id] }

      it { expect(navigation[:previous]).to eq(98) }
      it { expect(navigation[:next]).to be_nil }
      it { expect(navigation[:position]).to eq(4) }
      it { expect(navigation[:count]).to eq(4) }
    end

    context 'when there is only one claim in the list' do
      let(:claim_ids) { [claim.id] }

      it { expect(navigation[:previous]).to be_nil }
      it { expect(navigation[:next]).to be_nil }
      it { expect(navigation[:position]).to eq(1) }
      it { expect(navigation[:count]).to eq(1) }
    end

    context 'when the claim is not in the list' do
      let(:claim_ids) { [57, 19, 98] }

      it { expect(navigation[:previous]).to be_nil }
      it { expect(navigation[:next]).to be_nil }
      it { expect(navigation[:position]).to be_nil }
      it { expect(navigation[:count]).to eq(3) }
    end
  end
end
