class OrderItemSerializer < ApplicationSerializer
  attributes :id, :quantity, :price, :created_at, :updated_at

  belongs_to :product_sku

  def price
    object.price * object.quantity
  end
end 