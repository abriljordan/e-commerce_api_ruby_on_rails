FactoryBot.define do
  factory :address do
    user
    city
    address_line_1 { '123 Main St' }
    address_line_2 { 'Apt 4B' }
    postal_code { '10001' }
    phone_number { '+1 555-123-4567' }
    landmark { 'Near Central Park' }
  end
end 