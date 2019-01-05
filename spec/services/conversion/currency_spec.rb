RSpec.describe Conversion::Currency, :currency_vcr do
  subject(:call) { described_class.call(date, usd_value) }

  let(:date) { Date.new(2018, 1, 30) }
  let(:usd_value) { 1842.39 }

  it { is_expected.to eq 1301.5 }
end
