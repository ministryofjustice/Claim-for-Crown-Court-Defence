RSpec.describe Claims::FeeCalculator::Response do
  it { is_expected.to be_a Struct }
  it { is_expected.to respond_to(:success?) }
  it { is_expected.to respond_to(:data) }
  it { is_expected.to respond_to(:errors) }
  it { is_expected.to respond_to(:message) }
end
