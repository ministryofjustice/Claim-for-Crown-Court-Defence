RSpec.describe Claims::FeeCalculator::Exceptions do
  let(:message) { 'local message' }

  describe described_class::PriceNotFound do
    subject(:exception) { described_class.new(message) }

    it 'provides its own message' do
      expect(exception.message).to eql 'Price not found'
    end
  end

  describe described_class::TooManyPrices do
    subject(:exception) { described_class.new(message) }

    it 'provides its own message' do
      expect(exception.message).to eql 'Too many prices'
    end
  end

  describe described_class::InterimWarrantExclusion do
    subject(:exception) { described_class.new(message) }

    it 'interpolates provided message into a predefined message' do
      expect(exception.message).to eql 'price calculation excluded: local message cannot determine warrant prices without more details'
    end
  end

  describe described_class::RetrialReductionExclusion do
    subject(:exception) { described_class.new(message) }

    it 'interpolates provided message into a predefined message' do
      expect(exception.message).to eql 'price calculation excluded: local message cannot determine retrial prices where retrial started before trial concluded'
    end
  end

  describe described_class::CrackedBeforeRetrialExclusion do
    subject(:exception) { described_class.new(message) }

    it 'interpolates provided message into a predefined message' do
      expect(exception.message).to eql 'price calculation excluded: local message cannot determine cracked before retrial prices without more details'
    end
  end
end