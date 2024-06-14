RSpec.shared_examples 'data for an MI report' do
  it { expect(described_class::COLUMNS).to be_an(Array) }
  it { expect(described_class.call).to be_an(Array) }
  it { expect(described_class.new.call).to be_an(Array) }
end
