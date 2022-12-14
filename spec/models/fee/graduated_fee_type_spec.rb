require 'rails_helper'

RSpec.describe Fee::GraduatedFeeType do
  describe '.by_unique_code' do
    subject { described_class.by_unique_code(fee_type.unique_code) }

    let(:fee_type) { create(:graduated_fee_type, :grtrl) }

    it { is_expected.to eql fee_type }
  end

  describe '#fee_category_name' do
    subject { described_class.new.fee_category_name }

    it { is_expected.to eql 'Graduated Fees' }
  end
end
