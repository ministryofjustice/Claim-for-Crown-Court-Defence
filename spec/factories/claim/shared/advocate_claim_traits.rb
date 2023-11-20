FactoryBot.define do
  trait :agfs_scheme_9 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_fee_reform_release_date - 1)
      end
    end
  end

  trait :agfs_scheme_10 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_fee_reform_release_date)
      end
    end
  end

  trait :agfs_scheme_11 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_scheme_11_release_date)
      end
    end
  end

  trait :agfs_scheme_12 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.clar_release_date)
      end
    end
  end

  trait :agfs_scheme_13 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_scheme_13_clair_release_date)
      end
    end
  end

  trait :agfs_scheme_14 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_scheme_14_section_twenty_eight)
      end
    end
  end

  trait :agfs_scheme_15 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc)
      end
    end
  end

  trait :agfs_scheme_16 do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update_all(representation_order_date: Settings.agfs_scheme_16_section_twenty_eight_increase)
      end
    end
  end
end
