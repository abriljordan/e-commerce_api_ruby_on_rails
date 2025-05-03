FactoryBot.define do
  factory :order do
    association :user
    total_price { 100.0 }
  end
end
