require 'rails_helper'

describe API::Entities::InjectionAttempt do
  let(:injection_attempt) { build(:injection_attempt, :with_errors) }

  it 'represents the injection_attempt entity' do
    result = described_class.represent(injection_attempt)
    expect(result.to_json).to eq '{"succeeded":false,"error_messages":["injection error 1","injection error 2"],"deleted_at":null}'
  end
end
