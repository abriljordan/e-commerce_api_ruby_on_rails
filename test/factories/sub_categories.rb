FactoryBot.define do
  factory :sub_category do
    sequence(:name) { |n| "SubCategory #{n}" }
    association :category
  end
end
