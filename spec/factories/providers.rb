# == Schema Information
#
# Table name: providers
#
#  id                        :integer          not null, primary key
#  name                      :string
#  firm_agfs_supplier_number :string
#  provider_type             :string
#  vat_registered            :boolean
#  uuid                      :uuid
#  api_key                   :uuid
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  roles                     :string
#

FactoryBot.define do
  factory :provider do
    provider_type 'chamber'

    # NOTE: factory used for demo data and should therefore provide name that can be used to identify it for destruction if necessary
    #       see ClaimDestroyer
    sequence(:name) { |n| "#{Faker::Company.name} (Test-Provider-#{n})" }

    roles ['agfs']

    after(:build) { |provider| provider.vat_registered = false if provider.lgfs? && provider.vat_registered.nil? }

    before(:create) do |provider, evaluator|
      unless evaluator.__override_names__.include?(:lgfs_supplier_numbers)
        provider.lgfs_supplier_numbers << build(:supplier_number, provider: provider) if provider.lgfs?
      end
    end

    trait :agfs do
      provider_type 'chamber'
      roles ['agfs']
    end

    trait :lgfs do
      provider_type 'firm'
      firm_agfs_supplier_number nil
      roles ['lgfs']
      vat_registered false
    end

    trait :agfs_lgfs do
      provider_type 'firm'
      firm_agfs_supplier_number '123AB'
      roles ['agfs', 'lgfs']
      vat_registered false
    end

    trait :firm do
      provider_type 'firm'
      firm_agfs_supplier_number nil
      vat_registered { true }
      roles ['lgfs']
    end

    # does not require supplier number
    trait :chamber do
      provider_type 'chamber'
      firm_agfs_supplier_number nil
    end

    trait :with_lgfs_supplier_numbers do
      after(:build) do |provider|
        3.times do
          provider.lgfs_supplier_numbers << build(:supplier_number, provider: provider)
        end
      end
    end
  end
end
