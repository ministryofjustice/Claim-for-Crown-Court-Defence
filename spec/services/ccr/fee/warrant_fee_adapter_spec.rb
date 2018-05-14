require 'rails_helper'

RSpec.describe CCR::Fee::WarrantFeeAdapter, type: :adapter do
  it_behaves_like 'a simple bill adapter', bill_type: 'AGFS_ADVANCE', bill_subtype: 'AGFS_WARRANT' do
    let(:fee) { instance_double(Fee::WarrantFee) }
  end
end
