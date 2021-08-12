# frozen_string_literal: true

RSpec.describe ErrorMessage::Detail do
  subject(:ed0) { described_class.new(:key0, 'long error', 'short error', 'api message') }

  let(:ed1) { described_class.new(:key3, 'long error', 'short error', 'api message', 10) }
  let(:ed2) { described_class.new(:key2, 'long error', 'short error', 'api message', 11) }
  let(:ed3) { described_class.new(:key1, 'long error', 'short error', 'api message', 12) }
  let(:ed4) { described_class.new(:key1, 'long error', 'short error', 'api message', 12) }
  let(:ed5) { described_class.new(:key1, 'long error', 'different short error', 'api message', 12) }
  let(:ed6) { described_class.new(:key1, 'different long error', 'short error', 'api message', 12) }
  let(:ed7) { described_class.new(:key1, 'long error', 'short error', 'different api message', 12) }

  it { is_expected.to respond_to(:attribute, :long_message, :short_message, :api_message, :sequence) }

  it 'defaults sequence to 99999' do
    expect(ed0.sequence).to eq 99999
  end

  it 'sorts against other ErrorMessage::Detail instances by sequence' do
    expect([ed1, ed2].sort!).to eql [ed1, ed2]
  end

  it 'compares all message attributes when testing for equality' do
    expect(ed1).not_to eq ed2
    expect(ed3).to eq ed4
    expect(ed3).not_to eq ed5
    expect(ed3).not_to eq ed6
    expect(ed3).not_to eq ed7
  end
end
