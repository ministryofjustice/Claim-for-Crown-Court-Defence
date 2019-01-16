RSpec.describe Conversion::Currency, :currency_vcr do
  subject(:call) { described_class.call(date, usd_value) }

  let(:date) { Date.new(2018, 1, 30) }
  let(:usd_value) { '1842.39' }

  it { is_expected.to be_a Float }

  context 'when the usd_value has no formatting' do
    it { is_expected.to eq 1301.5 }
  end

  context 'when the usd_value has commas as thousand separators' do
    let(:usd_value) { '1,842.39' }

    it { is_expected.to eq 1301.5 }
  end

  context 'when the conversion fails' do
    let(:date) { 'date' }
    let(:usd_value) { 'dollars' }

    it 'raises an error' do
      expect(Rails.logger).to receive(:error).with(/Error converting currency.*/)
      call
    end

    it { is_expected.to be nil }
  end
end
