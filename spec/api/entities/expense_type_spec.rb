require 'rails_helper'
require 'spec_helper'

describe API::Entities::ExpenseType do

  let(:expense_type) { instance_double(::ExpenseType, id: 123, name: 'Travel time', unique_code: 'TRAVL', roles: ['agfs'], reason_set: 'B') }

  it 'represents the expense type entity' do
    result = described_class.represent(expense_type).to_json
    expect(result).to eq '{"id":123,"unique_code":"TRAVL","name":"Travel time","roles":["agfs"],"reason_set":"B"}'
  end
end
