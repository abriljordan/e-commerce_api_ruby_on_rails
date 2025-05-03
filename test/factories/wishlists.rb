FactoryBot.define do
  factory :wishlist do
    association :user
    product { association(:product) }
  end
end
