RSpec.shared_examples 'common basic fees presenters' do
  it {
    is_expected.to respond_to :raw_basic_fees_total,
      :raw_basic_fees_vat,
      :raw_basic_fees_gross,
      :basic_fees_vat,
      :basic_fees_vat,
      :basic_fees_gross,
      :mandatory_case_details?
  }

  describe '#raw_basic_fees_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:calculate_fees_total).with(:basic_fees)
      presenter.raw_basic_fees_total
    end
  end
end
