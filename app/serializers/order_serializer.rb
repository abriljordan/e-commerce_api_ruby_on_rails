class OrderSerializer < ApplicationSerializer
  attributes :id, :status, :total_amount, :payment_method, :notes,
             :created_at, :updated_at

  belongs_to :address
  has_many :order_items

  def total_amount
    object.order_items.sum { |item| item.quantity * item.price }
  end
end 