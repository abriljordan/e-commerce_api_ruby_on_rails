class ProductReviewSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :rating, :approved, :created_at, :updated_at, :metadata
  belongs_to :user
  belongs_to :product
  belongs_to :order_item, optional: true

  def metadata
    object.metadata || {}
  end
end 