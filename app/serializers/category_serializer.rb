class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  has_many :sub_categories
  has_many :products

  attribute :product_count do
    object.products.count
  end
end 