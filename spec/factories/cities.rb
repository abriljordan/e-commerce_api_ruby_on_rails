FactoryBot.define do
  factory :city do
    name { 'New York' }
    association :country
  end
end 