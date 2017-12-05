require 'rails_helper'

describe HostMemory do
  let(:free) { "total  used  free  shared  buffers  cached\nMem:  4046828  3266332  780496  1636  338564  1470868\n-/+ buffers/cache:  1456900  2589928\nSwap:  0  0  0" }

  before do
    expect(described_class).to receive(:`).with('free -k').and_return free
  end

  describe '.total' do
    subject { described_class.total }

    it 'returns total memory using linux free command' do
      is_expected.to eql 4046828
    end
  end

  describe '.used' do
    subject { described_class.used }

    it 'returns used memory using linux free command' do
      is_expected.to eql 3266332
    end
  end

  describe '.free' do
    subject { described_class.free }
    it 'returns free memory using linux free command' do
      is_expected.to eql 780496
    end
  end
end
