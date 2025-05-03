module Reviewable
  extend ActiveSupport::Concern

  included do
    has_many :product_reviews, as: :reviewable, dependent: :destroy
    has_many :reviewers, through: :product_reviews, source: :user
  end

  def average_rating
    product_reviews.approved.average(:rating)&.round(2) || 0
  end

  def review_count
    product_reviews.approved.count
  end

  def rating_distribution
    (1..5).map do |rating|
      {
        rating: rating,
        count: product_reviews.approved.by_rating(rating).count,
        percentage: calculate_percentage(rating)
      }
    end
  end

  private

  def calculate_percentage(rating)
    total = review_count
    return 0 if total.zero?
    (product_reviews.approved.by_rating(rating).count.to_f / total * 100).round(2)
  end
end 