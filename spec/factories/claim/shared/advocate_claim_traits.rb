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
end
