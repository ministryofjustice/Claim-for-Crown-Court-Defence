FactoryBot.define do
  factory :multi_firm_user_link do
    user { create(:external_user, user: build(:user, multi_firm_user: true)).user }
    linked_user { create(:external_user).user }
  end
end
