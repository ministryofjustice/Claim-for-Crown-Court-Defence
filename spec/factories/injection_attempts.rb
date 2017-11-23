FactoryBot.define do
  factory :injection_attempt do
    claim
    succeeded true
    error_message nil
  end
end

