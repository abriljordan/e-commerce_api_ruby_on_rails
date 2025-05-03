class ProductSerializer < ApplicationSerializer
  attributes :id, :name, :description, :summary, :price, :stock_quantity,
             :active, :featured, :created_at, :updated_at

  belongs_to :category
  belongs_to :sub_category
  has_many :product_skus

  attribute :main_image_url do
    object.main_image.url if object.main_image.attached?
  end

  attribute :additional_image_urls do
    object.additional_images.map(&:url) if object.additional_images.attached?
  end
end 