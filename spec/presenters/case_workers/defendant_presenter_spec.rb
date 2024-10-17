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

  describe '#cases' do
    subject { defendant_presenter.cases }

    let(:defendant) { build(:defendant) }

    let(:cases) do
      [
        LAA::Cda::ProsecutionCase.new('prosecution_case_reference' => 'TEST1', 'case_status' => 'INACTIVE'),
        LAA::Cda::ProsecutionCase.new('prosecution_case_reference' => 'TEST2', 'case_status' => 'ACTIVE')
      ]
    end

    before do
      allow(LAA::Cda::ProsecutionCase)
        .to receive(:search)
        .with({ name: defendant.name, date_of_birth: defendant.date_of_birth })
        .and_return(cases)
    end

    it { is_expected.to eq(cases) }
  end
end
