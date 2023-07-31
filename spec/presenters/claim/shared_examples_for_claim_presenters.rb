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

  describe '#raw_basic_fees_vat' do
    it 'sends message to VatRate' do
      allow(VatRate).to receive(:vat_amount).and_return(20.00)
      presenter.raw_basic_fees_vat
      expect(VatRate).to have_received(:vat_amount).at_least(:once)
    end
  end

  describe '#raw_basic_fees_gross' do
    it 'sends message to VatRate' do
      allow(presenter).to receive_messages(raw_basic_fees_total: 101.00, raw_basic_fees_vat: 20.20)
      expect(presenter.raw_basic_fees_gross).to eq 121.20
    end
  end

  describe '#basic_fees_vat' do
    it 'sends message to VatRate' do
      allow(presenter).to receive(:raw_basic_fees_vat).and_return(20.20)
      expect(presenter.basic_fees_vat).to eq '£20.20'
    end
  end

  describe '#basic_fees_gross' do
    it 'sends message to VatRate' do
      allow(presenter).to receive(:raw_basic_fees_gross).and_return(101.00)
      expect(presenter.basic_fees_gross).to eq '£101.00'
    end
  end
end
