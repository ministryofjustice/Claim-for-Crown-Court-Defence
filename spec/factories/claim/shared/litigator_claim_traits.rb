FactoryBot.define do
  trait :pre_clar do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update(representation_order_date: Settings.clar_release_date - 1.day)
      end
    end
  end

  trait :clar do
    after(:create) do |claim|
      claim.defendants.each do |defendant|
        defendant
          .representation_orders
          .update(representation_order_date: Settings.clar_release_date)
      end
    end
  end
end
