FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { 'Password123' }
    first_name { 'John' }
    last_name { 'Doe' }
    role { 'customer' }
    jti { SecureRandom.uuid }
  end
end 