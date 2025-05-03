class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :order_items
  has_many :cart_items

  validates :sku, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :option_values, presence: true

  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :low_stock, -> { where('stock_quantity <= 5') }
  scope :out_of_stock, -> { where(stock_quantity: 0) }

  def update_stock(quantity)
    update!(stock_quantity: stock_quantity - quantity)
  end

  def restore_stock(quantity)
    update!(stock_quantity: stock_quantity + quantity)
  end

  def in_stock?
    stock_quantity.positive?
  end

  def low_stock?
    stock_quantity <= 5
  end

  def out_of_stock?
    stock_quantity.zero?
  end

  def formatted_options
    option_values.map { |k, v| "#{k}: #{v}" }.join(', ')
  end
end 