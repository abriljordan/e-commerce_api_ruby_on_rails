class CartSerializer < ApplicationSerializer
  attributes :id, :total_items, :subtotal, :created_at, :updated_at

  has_many :cart_items

  def total_items
    object.cart_items.sum(:quantity)
  end

  def subtotal
    object.cart_items.sum { |item| item.quantity * item.product_sku.price }
  end
end 