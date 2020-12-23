require 'rails_helper'

RSpec.describe CCLF::Fee::HardshipFeeAdapter, type: :adapter do
  it_behaves_like 'a simple bill adapter', bill_type: 'FEE_ADVANCE', bill_subtype: 'HARDSHIP' do
    let(:fee) { instance_double(Fee::HardshipFee) }
  end
end
