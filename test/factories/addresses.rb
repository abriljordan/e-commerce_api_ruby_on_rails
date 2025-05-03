FactoryBot.define do
  factory :address do
    association :user
    city { association(:city) }
    address_line_1 { "123 Main St" }
    postal_code { "12345" }
  end
end
