class Order < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :address
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :payment_detail, dependent: :destroy
  has_many :order_histories, dependent: :destroy

  validates :status, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tracking_number, presence: true, if: :shipped?
  validates :shipping_carrier, presence: true, if: :shipped?

  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :fulfilled
    state :shipped
    state :completed
    state :cancelled

    event :process do
      transitions from: :pending, to: :processing, after: :create_order_history
    end

    event :fulfill do
      transitions from: :processing, to: :fulfilled, after: :create_order_history
    end

    event :ship do
      transitions from: :fulfilled, to: :shipped, after: :create_order_history
    end

    event :complete do
      transitions from: :shipped, to: :completed, after: :create_order_history
    end

    event :cancel do
      transitions from: [:pending, :processing], to: :cancelled, after: :handle_cancellation
    end
  end

  scope :completed, -> { where(status: 'completed') }
  scope :active, -> { where.not(status: %w[completed cancelled]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  def calculate_total
    update(total_amount: order_items.sum { |item| item.quantity * item.price })
  end

  def update_stock
    order_items.each do |item|
      item.product_sku.update_stock(item.quantity)
    end
  end

  def restore_stock
    order_items.each do |item|
      item.product_sku.restore_stock(item.quantity)
    end
  end

  def can_cancel?
    pending? || processing?
  end

  def can_ship?
    fulfilled? && tracking_number.present? && shipping_carrier.present?
  end

  def shipping_address
    address.full_address
  end

  def billing_address
    user.billing_address&.full_address
  end

  private

  def create_order_history
    order_histories.create!(
      status: status,
      note: "Order #{status}",
      user: user
    )
  end

  def handle_cancellation
    create_order_history
    restore_stock
  end
end
