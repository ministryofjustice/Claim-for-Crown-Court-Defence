FactoryBot.define do
  factory :login_route do
    user
    id { user.id }
    login_method { LoginRoute::LEGACY }

    initialize_with { user.login_route || user.build_login_route }

    trait :entra do
      login_method { LoginRoute::ENTRA }
    end
  end
end
