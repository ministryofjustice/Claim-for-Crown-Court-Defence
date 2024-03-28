RSpec.describe CaseWorkers::DefendantPresenter do
  subject(:defendant_presenter) { described_class.new(defendant, view) }

  describe '#representation_orders' do
    subject(:representation_orders) { defendant_presenter.representation_orders }

    context 'when there are representation orders' do
      let(:defendant) { build(:defendant, representation_orders: build_list(:representation_order, 3)) }

      it { expect(representation_orders.length).to eq 3 }
      it { is_expected.to all(be_a(CaseWorkers::RepresentationOrder)) }
    end

    context 'when there are no representation orders' do
      let(:defendant) { build(:defendant, representation_orders: []) }

      it { is_expected.to be_empty }
    end
  end
end
