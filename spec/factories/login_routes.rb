FactoryBot.define do
  factory :login_route do
    user
    id { user.id }
    login_method { LoginRoute::LEGACY }

    trait :entra do
      login_method { LoginRoute::ENTRA }
    end
  end
end
