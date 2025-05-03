FactoryBot.define do
  factory :product_variant do
    product
    sequence(:sku) { |n| "SKU#{n}" }
    price { 99.99 }
    stock_quantity { 50 }
    option_values { { size: 'M', color: 'Black' } }
  end
end 