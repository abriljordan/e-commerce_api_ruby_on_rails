class ProductReview < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :order_item, optional: true

  validates :rating, presence: true, numericality: { 
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }
  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }

  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }
  scope :lowest_rated, -> { order(rating: :asc) }

  after_save :update_product_rating
  after_destroy :update_product_rating
  after_create :notify_review_created
  after_update :notify_review_status_changed, if: :saved_change_to_approved?
  after_save :update_review_statistics
  after_destroy :update_review_statistics
  after_create :moderate_review
  after_save :update_recommendations
  after_destroy :update_recommendations

  private

  def update_product_rating
    product.update_average_rating
  end

  def update_review_statistics
    UpdateReviewStatisticsJob.perform_later(product_id)
  end

  def notify_review_created
    ReviewNotificationJob.perform_later(id, 'created')
  end

  def notify_review_status_changed
    action = approved ? 'approved' : 'rejected'
    ReviewNotificationJob.perform_later(id, action)
  end

  def moderate_review
    ModerateReviewJob.perform_later(id)
  end

  def update_recommendations
    CacheReviewRecommendationsJob.perform_later(user_id)
  end
end 