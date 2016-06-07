require 'rails_helper'

describe String do
  context '#zero?' do
    context 'for blank values' do
      it 'should be false' do
        expect(''.zero?).to eq(false)
      end
    end

    context 'for numeric non-zero values' do
      %w(1 0.1 0.01 1.0).each do |value|
        it "should be false for #{value}" do
          expect(value.zero?).to eq(false)
        end
      end
    end

    context 'for numeric zero values' do
      %w(0 0.0 0.00 000).each do |value|
        it "should be true for #{value}" do
          expect(value.zero?).to eq(true)
        end
      end
    end
  end
end
