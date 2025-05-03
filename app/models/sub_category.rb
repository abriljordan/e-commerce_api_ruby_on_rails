class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :products, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
