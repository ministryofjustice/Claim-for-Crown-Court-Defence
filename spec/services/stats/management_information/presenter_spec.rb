# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::Presenter do
  subject(:presenter) { described_class.new(record) }

  let(:query) { Stats::ManagementInformation::Query.call }

  describe '#submission_type' do
    subject { presenter.submission_type }

    before { create(:litigator_final_claim, :authorised).tap(&:redetermine!) }

    context 'when first journey transition is submitted' do
      let(:record) { query.first }

      it { is_expected.to eq('new') }
    end

    context 'when first journey transition is redetermination' do
      let(:record) { query.last }

      it { is_expected.to eq('redetermination') }
    end
  end

  describe '#transitioned_at' do
    subject { presenter.transitioned_at }

    let(:record) { query.first }

    context 'when journey contains no submissions' do
      before do
        travel_to(6.months.ago) do
          claim
        end
        claim.allocate!
      end

      let(:claim) { create(:litigator_final_claim, :submitted) }

      it { is_expected.to eq('n/a') }
    end

    context 'when journey contains one or more submissions' do
      before { create(:litigator_final_claim, :allocated) }

      it { is_expected.to match(%r{\d{2}/\d{2}/\d{4}}) }
    end
  end
end
