FactoryGirl.define do
  factory :evidence_list_item do
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
    sequence(:item_order) { |n| max_item_order+n }
  end
end

def max_item_order
	EvidenceListItem.maximum(:item_order).nil? ? 0 : EvidenceListItem.maximum(:item_order)
end
