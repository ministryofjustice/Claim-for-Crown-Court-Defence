require 'rails_helper'

RSpec.describe CCR::Fee::HardshipFeeAdapter, type: :adapter do
  context 'when instantiated without a claim object' do
    subject(:instance) { described_class.new }

    it_behaves_like 'a simple bill adapter', bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_HARDSHIP' do
      let(:fee) { instance_double(Fee::BasicFee) }
    end

    it_behaves_like 'a basic fee adapter', bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_HARDSHIP' do
      let(:claim) { create(:advocate_hardship_claim) }
    end
  end
end
