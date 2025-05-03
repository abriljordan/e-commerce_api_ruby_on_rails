FactoryBot.define do
  factory :city do
    name { "Metropolis" }
    association :country
  end
end
