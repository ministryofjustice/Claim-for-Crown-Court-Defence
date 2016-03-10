# == Schema Information
#
# Table name: external_users
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  supplier_number :string
#  uuid            :uuid
#  vat_registered  :boolean          default(TRUE)
#  provider_id     :integer
#  roles           :string
#

FactoryGirl.define do
  factory :external_user do
    after(:build) do |a|
      a.user ||= build(:user, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
    end

    provider
    roles ['advocate']
    supplier_number { generate_unique_supplier_number }

    trait :advocate do
      roles ['advocate']
      provider { create(:provider, :agfs) }
    end

    trait :litigator do
      roles ['litigator']
      supplier_number nil
      provider { create(:provider, :lgfs) }
    end

    trait :advocate_litigator do
      roles ['advocate', 'litigator']
      provider { create(:provider, :agfs_lgfs) }
    end

    trait :admin do
      roles ['admin']
      supplier_number nil
    end

    trait :advocate_and_admin do
      roles ['admin', 'advocate']
    end

    trait :litigator_and_admin do
      supplier_number nil
      roles ['litigator', 'admin']
      provider { create(:provider, :lgfs) }
    end

    trait :agfs_lgfs_admin do
      roles ['admin']
      provider { create(:provider, :agfs_lgfs) }
    end
  end
end

def generate_unique_supplier_number
  alpha_part = ""
  2.times{alpha_part  << (65 + rand(25)).chr}
  numeric_part = rand(999)
  "#{alpha_part}#{sprintf('%03d', numeric_part)}"
end
