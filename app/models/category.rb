class Category < ApplicationRecord
  has_many :sub_categories, dependent: :destroy
  has_many :products, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
