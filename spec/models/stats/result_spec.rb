require 'rails_helper'

RSpec.describe Stats::Result do
  let(:result) { described_class.new(lines.join("\n"), format) }
  let(:lines) { ['Col 1,Col2', '3,6'] }
  let(:format) { 'csv' }

  describe '#io' do
    subject(:io) { result.io }

    it 'is an IO stream for the content' do
      expect(io.readlines.map(&:chomp)).to eq lines
    end
  end

  describe '#content_type' do
    subject(:content_type) { result.content_type }

    context 'when csv' do
      it { is_expected.to eq 'text/csv' }
    end

    context 'when json' do
      let(:format) { 'json' }

      it { is_expected.to eq 'application/json' }
    end
  end
end
