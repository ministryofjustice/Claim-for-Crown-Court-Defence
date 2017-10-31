require 'rails_helper'
require 'spec_helper'

describe API::Entities::BaseFeeType do
  subject(:response) { JSON.parse(described_class.represent(fee_type).to_json).deep_symbolize_keys }
  let(:fee_type) { build(:basic_fee_type) }

  it 'exposes all model attributes' do
    expect(response.keys).to include(:id, :type, :description, :code, :unique_code, :max_amount, :calculated, :roles, :quantity_is_decimal)
  end

  it 'exposes #case_uplift? as case_numbers_required attribute' do
    expect(fee_type).to receive(:case_uplift?)
    expect(response.keys).to include(:case_numbers_required)
  end
end
