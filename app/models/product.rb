class Product < ApplicationRecord
  include PgSearch::Model
  include Reviewable

  belongs_to :category
  belongs_to :sub_category, optional: true
  has_many :product_variants, dependent: :destroy
  has_many :order_items, through: :product_variants
  has_many :product_reviews, dependent: :destroy
  has_many :cart_items, through: :product_variants
  has_many :wishlists, dependent: :destroy
  has_one_attached :main_image
  has_many_attached :additional_images

  validates :name, :description, :base_price, presence: true
  validates :name, uniqueness: true
  validates :summary, length: { maximum: 500 }, allow_blank: true
  validates :base_price, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :featured, inclusion: { in: [true, false] }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :main_image, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
                        size: { less_than: 5.megabytes }

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { joins(:product_variants).where('product_variants.stock_quantity > 0').distinct }
  scope :low_stock, -> { joins(:product_variants).where('product_variants.stock_quantity <= 5').distinct }
  scope :out_of_stock, -> { joins(:product_variants).where(product_variants: { stock_quantity: 0 }).distinct }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_sub_category, ->(sub_category_id) { where(sub_category_id: sub_category_id) }

  pg_search_scope :search_by_name_and_description,
    against: [:name, :description],
    using: {
      tsearch: { prefix: true }
    }

  pg_search_scope :search_by_category,
    associated_against: {
      category: [:name],
      sub_category: [:name]
    }

  def update_average_rating
    update_column(:average_rating, product_reviews.approved.average(:rating))
  end

  def total_stock
    product_variants.sum(:stock_quantity)
  end

  def in_stock?
    total_stock.positive?
  end

  def low_stock?
    total_stock <= 5
  end

  def out_of_stock?
    total_stock.zero?
  end

  def available_variants
    product_variants.in_stock
  end

  def default_variant
    product_variants.first
  end

  def price_range
    return [base_price, base_price] if product_variants.empty?
    [product_variants.minimum(:price), product_variants.maximum(:price)]
  end

  def toggle_active
    update(active: !active)
  end

  def toggle_featured
    update(featured: !featured)
  end

  def update_stock(quantity)
    update(stock_quantity: stock_quantity - quantity)
  end

  def restore_stock(quantity)
    update(stock_quantity: stock_quantity + quantity)
  end
end
