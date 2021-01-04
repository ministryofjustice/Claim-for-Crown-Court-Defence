require 'rails_helper'

describe ExpenseReason do
  describe '.new' do
    it 'raises if allow_explanatory_text not boolean' do
      expect {
        ExpenseReason.new(5, 'reason', 'false')
      }.to raise_error ArgumentError, 'Allow explanatory text must be boolean'
    end

    it 'raises if id not fix num' do
      expect {
        ExpenseReason.new('a', 'reason', false)
      }.to raise_error ArgumentError, 'Id must be numeric'
    end
  end

  describe '#allow_explanatory_text?' do
    it 'responds true' do
      er = ExpenseReason.new(7, 'reason', true)
      expect(er.allow_explanatory_text?).to be true
    end

    it 'responds false' do
      er = ExpenseReason.new(11, 'reason', false)
      expect(er.allow_explanatory_text?).to be false
    end
  end

  describe '.id' do
    it 'returns the id' do
      er = ExpenseReason.new(34, 'reason', true)
      expect(er.id).to eq 34
    end
  end

  describe '#to_hash' do
    it 'returns the right keys and values' do
      er = ExpenseReason.new(34, 'reason', true)
      expect(er.to_hash).to eq({ id: 34, reason: 'reason', reason_text: true })
    end
  end
end
