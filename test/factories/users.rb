FactoryBot.define do
  factory :user do
      sequence(:username) { |n| "user#{n}" }
      sequence(:email) { |n| "user#{n}@example.com" }
      password { "password123" }


    after(:create) do |user|
      create(:cart, user: user)
      create(:address, user: user)
      category = create(:category)
      product = create(:product, category: category)
      create(:order, user: user)
      create(:wishlist, user: user, product: product)
    end
  end
end
