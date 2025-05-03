class OrderHistory < ApplicationRecord
  belongs_to :order
  belongs_to :user, optional: true

  validates :status, presence: true
  validates :note, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
end 