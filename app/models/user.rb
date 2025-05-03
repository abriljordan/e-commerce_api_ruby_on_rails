class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :payment_details, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false }, 
                   format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, presence: true, 
                      length: { minimum: 8 },
                      format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
                               message: "must include at least one lowercase letter, one uppercase letter, and one digit" }
  validates :phone_number, format: { with: /\A\+?[\d\s-]+\z/ }, allow_blank: true

  enum :role, { customer: 0, admin: 1 }, default: :customer

  before_create :set_default_role
  after_create :create_cart

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def default_address
    addresses.find_by(default: true)
  end

  def active_orders
    orders.where.not(status: %w[completed cancelled])
  end

  def total_spent
    orders.completed.sum(:total_amount)
  end

  def reviewed_product?(product)
    product_reviews.exists?(product_id: product.id)
  end

  private

  def set_default_role
    self.role ||= :customer
  end

  def create_cart
    Cart.create(user: self)
  end
end
