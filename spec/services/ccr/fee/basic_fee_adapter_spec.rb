require 'rails_helper'

RSpec.describe CCR::Fee::BasicFeeAdapter, type: :adapter do
  it_behaves_like 'a simple bill adapter', bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE' do
    let(:fee) { instance_double(Fee::BasicFee) }
  end

  it_behaves_like 'a basic fee adapter', bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE' do
    let(:claim) { create(:advocate_final_claim) }
  end
end
