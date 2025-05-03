FactoryBot.define do
  factory :product do
    category
    sequence(:name) { |n| "Product #{n}" }
    description { 'A sample product description' }
    base_price { 99.99 }
    active { true }
    featured { false }
    stock_quantity { 100 }

    trait :with_image do
      after(:build) do |product|
        product.main_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.jpg')),
          filename: 'sample.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end 