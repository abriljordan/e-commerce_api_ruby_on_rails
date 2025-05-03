FactoryBot.define do
  factory :address do
    user
    street { '123 Main St' }
    city { 'New York' }
    state { 'NY' }
    zip_code { '10001' }
    country { 'USA' }
    address_type { 'shipping' }
  end
end 