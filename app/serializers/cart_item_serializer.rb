class CartItemSerializer < ApplicationSerializer
  attributes :id, :quantity, :price, :created_at, :updated_at

  belongs_to :product_variant

  def price
    object.product_variant.price * object.quantity
  end
end 