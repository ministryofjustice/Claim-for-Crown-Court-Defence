require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_cclf_fee_adapters'

RSpec.describe CCLF::Fee::FixedFeeAdapter, type: :adapter do
  it_behaves_like 'a simple bill adapter'
  it_behaves_like 'Litigator Fee Adapter', fixed_fee_bill_scenarios
end
