class AddressSerializer < ApplicationSerializer
  attributes :id, :street_address, :state, :postal_code,
             :phone_number, :default, :created_at, :updated_at

  belongs_to :city
  belongs_to :country

  attribute :full_address do
    [
      object.street_address,
      object.city.name,
      object.state,
      object.postal_code,
      object.country.name
    ].compact.join(', ')
  end
end 