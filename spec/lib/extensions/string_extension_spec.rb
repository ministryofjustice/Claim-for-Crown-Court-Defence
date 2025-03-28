require 'rails_helper'

describe String do
  describe '#zero?' do
    context 'for blank values' do
      it 'is false' do
        expect(''.zero?).to be(false)
      end
    end

    context 'for numeric non-zero values' do
      %w[1 0.1 0.01 1.0].each do |value|
        it "is false for #{value}" do
          expect(value.zero?).to be(false)
        end
      end
    end

    context 'for numeric zero values' do
      %w[0 0.0 0.00 000].each do |value|
        it "is true for #{value}" do
          expect(value.zero?).to be(true)
        end
      end
    end
  end

  describe '#to_bool' do
    context 'for blank values' do
      it 'is false for empty string' do
        expect(''.to_bool).to be(false)
      end

      it 'is false for only spaces string' do
        expect(' '.to_bool).to be(false)
      end
    end

    context 'for truthy values' do
      %w[true t yes y 1].each do |value|
        it "is true for '#{value}'" do
          expect(value.to_bool).to be(true)
        end
      end
    end

    context 'for falsey values' do
      %w[false f no n 0].each do |value|
        it "is false for '#{value}'" do
          expect(value.to_bool).to be(false)
        end
      end
    end
  end

  describe '#alpha?' do
    context 'for blank values' do
      it 'is false for empty string' do
        expect(''.alpha?).to be(false)
      end

      it 'is false for only spaces string' do
        expect(' '.alpha?).to be(false)
      end
    end

    context 'truthy values' do
      %w[abc ABC].each do |value|
        it "is true for '#{value}'" do
          expect(value.alpha?).to be(true)
        end
      end
    end

    context 'falsey values' do
      %w[123 a1b z1 0].each do |value|
        it "is false for '#{value}'" do
          expect(value.alpha?).to be(false)
        end
      end
    end
  end

  describe '#digit?' do
    context 'for blank values' do
      it 'is false for empty string' do
        expect(''.digit?).to be(false)
      end

      it 'is false for only spaces string' do
        expect(' '.digit?).to be(false)
      end
    end

    context 'truthy values' do
      %w[0 1 123].each do |value|
        it "is true for '#{value}'" do
          expect(value.digit?).to be(true)
        end
      end
    end

    context 'falsey values' do
      %w[a a1b z1 1z 1.5].each do |value|
        it "is false for '#{value}'" do
          expect(value.digit?).to be(false)
        end
      end
    end
  end

  describe '#to_css_class' do
    it 'downcases all chars' do
      expect('part AUTHORISED'.to_css_class).to eq('part-authorised')
    end

    it 'replaces whitespace with hyphens' do
      expect('part authorised'.to_css_class).to eq('part-authorised')
    end

    it 'replaces underscore with hyphens' do
      expect('part_authorised'.to_css_class).to eq('part-authorised')
    end

    it 'replaces braces with blank' do
      expect('authorised (in part)'.to_css_class).to eq('authorised-in-part')
    end

    it 'strips whitespace from ends' do
      expect(' part authorised '.to_css_class).to eq('part-authorised')
    end
  end
end
