require 'rails_helper'

RSpec.describe CCLF::Fee::WarrantFeeAdapter, type: :adapter do
  it_behaves_like 'a simple bill adapter', bill_type: 'FEE_ADVANCE', bill_subtype: 'WARRANT' do
    let(:fee) { instance_double(Fee::WarrantFee) }
  end
end
