FactoryBot.define do
  factory :product_sku do
    sequence(:sku) { |n| "SKU#{n}" }
    price { 19.99 }
    association :product
  end
end
