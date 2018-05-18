# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  unique_code      :string           default("anyoldrubbish"), not null
#

FactoryBot.define do
  factory :offence do
    offence_class { OffenceClass.first || create(:offence_class) }
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
    sequence(:unique_code) { |n| "ABCD-#{n}" }

    trait :miscellaneous do
      description 'Miscellaneous/other'
    end

    trait :with_fee_scheme do
      after(:build) do |offence|
        offence.fee_schemes << (FeeScheme.agfs.first || build(:fee_scheme, :agfs_nine))
      end
    end

    trait :with_fee_scheme_ten do
      offence_class nil
      offence_band
      after(:build) do |offence|
        offence.fee_schemes << (FeeScheme.agfs.where(version: 10).first || build(:fee_scheme))
      end
    end
  end
end
