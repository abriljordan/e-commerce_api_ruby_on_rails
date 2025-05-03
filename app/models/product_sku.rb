class ProductSku < ApplicationRecord
  belongs_to :product
  belongs_to :size_attribute, class_name: "SizeAttribute"
  belongs_to :color_attribute, class_name: "ColorAttribute"

  validates :sku, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
