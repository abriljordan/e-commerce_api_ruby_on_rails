class CartItemSerializer < ApplicationSerializer
  attributes :id, :quantity, :price, :created_at, :updated_at

  belongs_to :product_sku

  def price
    object.product_sku.price * object.quantity
  end
end 