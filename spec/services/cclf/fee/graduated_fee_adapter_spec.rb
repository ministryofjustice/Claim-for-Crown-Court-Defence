require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_cclf_fee_adapters'

RSpec.describe CCLF::Fee::GraduatedFeeAdapter, type: :adapter do
  it_behaves_like 'Litigator Fee Adapter', graduated_fee_bill_scenarios
end
