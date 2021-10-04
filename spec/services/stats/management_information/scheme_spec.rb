# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::Scheme do
  subject(:scheme) { described_class.new(scheme_arg) }

  let(:scheme_arg) { 'agfs' }

  it { is_expected.to respond_to(:name, :valid?) }
  it { is_expected.to delegate_method(:nil?).to(:name) }
  it { is_expected.to delegate_method(:present?).to(:name) }
  it { is_expected.to delegate_method(:blank?).to(:name) }

  describe '#==' do
    context 'when comparing similar scheme objects' do
      it 'is case insensitive' do
        one = described_class.new('agfs')
        other = described_class.new('AGFS')
        expect(one).to be == other
      end

      it 'accepts symbols' do
        one = described_class.new(:agfs)
        other = described_class.new(:AGFS)
        expect(one).to be == other
      end
    end

    context 'when comparing different scheme objects' do
      it 'is case insensitive' do
        one = described_class.new('agfs')
        other = described_class.new('foo')
        expect(one).not_to be == other
      end

      it 'accepts symbols' do
        one = described_class.new(:agfs)
        other = described_class.new(:bar)
        expect(one).not_to be == other
      end
    end

    context 'when comparing scheme object with symbol' do
      it { expect(described_class.new(:foo)).to be == :foo }
      it { expect(described_class.new(:FOO)).to be == :foo }
      it { expect(described_class.new('foo')).to be == :foo }
      it { expect(described_class.new('FOO')).to be == :foo }
      it { expect(described_class.new('fOo')).to be == :foo }
      it { expect(described_class.new('fOo')).to be == :FOO }
      it { expect(described_class.new('fOo')).to be == 'FOO' }
      it { expect(described_class.new('fOo')).to be == 'foo' }
    end
  end

  describe '#eql?' do
    it { expect(scheme.method(:eql?)).to eq(scheme.method(:==)) }
  end

  describe '#valid?' do
    it { expect(described_class.new('agfs')).to be_valid }
    it { expect(described_class.new('AGFS')).to be_valid }
    it { expect(described_class.new(:agfs)).to be_valid }
    it { expect(described_class.new(:AGFS)).to be_valid }
    it { expect(described_class.new('lgfs')).to be_valid }
    it { expect(described_class.new('LGFS')).to be_valid }
    it { expect(described_class.new(:lgfs)).to be_valid }
    it { expect(described_class.new(:LGFS)).to be_valid }

    it { expect(described_class.new(:foo)).not_to be_valid }
    it { expect(described_class.new(:BAR)).not_to be_valid }
  end
end
