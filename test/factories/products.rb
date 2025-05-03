FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "This is a detailed product description." }
    summary { "Short summary of the product." }
    cover { "https://example.com/product-cover.jpg" }
    association :category
    association :sub_category
  end
end
