require 'rails_helper'

RSpec.shared_examples 'data for an MI report' do
  it { expect(described_class::COLUMNS).to be_an(Array) }
  it { expect(described_class.call).to be_an(Array) }
  it { expect(described_class.new.call).to be_an(Array) }
end

RSpec.describe Reports::ProvisionalAssessmentsNew do
  subject(:report) { described_class.new }

  it_behaves_like 'data for an MI report'

  describe '#call' do
    subject(:call) { described_class.call }

    context 'with a single draft claim' do
      before { create(:claim, :draft) }

      it { is_expected.to be_empty }
    end

    context 'with a single submitted claim' do
      before { create(:claim, :submitted) }

      it { is_expected.to be_empty }
    end

    context 'with a single allocated claim' do
      before { create(:claim, :allocated) }

      it { is_expected.to be_empty }
    end

    context 'with a single rejected claim' do
      before { create(:claim, :rejected) }

      it { is_expected.to be_empty }
    end

    context 'with a single redetermination claim' do
      before { create(:claim, :redetermination) }

      it { is_expected.to be_empty }
    end

    context 'with a single authorised claim' do
      before { create(:claim, :authorised) }

      it { expect(call.length).to eq(1) }
    end

    context 'with a single part_authorised claim' do
      let!(:claim) do
        create(
          :claim, :part_authorised,
          external_user:
        )
      end
      let(:external_user) { build(:external_user, provider: build(:provider, name: 'Test provider')) }

      it { expect(call.length).to eq(1) }
      it { expect(call.first[0]).to eq('Test provider') }
      it { expect(call.first[1]).to eq(claim.total_including_vat) }
      it { expect(call.first[2]).to eq(claim.amount_assessed) }
      it { expect(call.first[3]).to eq(claim.total_including_vat - claim.amount_assessed) }
      it { expect(call.first[4]).to eq('AdvocateClaim') }
      it { expect(call.first[5]).to eq(claim.case_type.name) }
      it { expect(call.first[6]).to eq(claim.earliest_representation_order_date) }
      it { expect(call.first[7]).to eq(claim.case_workers.last.name) }
      it { expect(call.first[8]).to eq(claim.defendants.last.representation_orders.last.maat_reference) }
    end
  end
end
