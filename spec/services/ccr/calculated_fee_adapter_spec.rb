require 'rails_helper'

RSpec.describe CCR::CalculatedFeeAdapter, type: :adapter do
  let(:claim) { create(:advocate_hardship_claim) }

  describe '#ex_vat' do
    subject { described_class.new(claim).ex_vat }

    it "returns sum of basic fees" do
      is_expected.to eql 25
    end
  end

  describe '.ex_vat_for' do
    subject { described_class.ex_vat_for(claim) }
    let(:adapter) { instance_double 'CalculatedFeeAdapter' }
    it 'calls #ex_vat' do
      expect(described_class).to receive(:new).with(claim).and_return adapter
      expect(adapter).to receive(:ex_vat)
      subject
    end
  end
end
