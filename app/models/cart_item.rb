class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :product_sku

  validates :quantity, numericality: { greater_than: 0 }
end
