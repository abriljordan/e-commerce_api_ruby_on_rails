FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { 'A sample category description' }
  end
end 