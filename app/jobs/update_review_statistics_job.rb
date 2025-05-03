class UpdateReviewStatisticsJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)
    statistics = ReviewStatisticsService.new(product).calculate

    product.update(
      average_rating: statistics[:average_rating],
      review_count: statistics[:total_reviews],
      metadata: product.metadata.merge(
        review_statistics: {
          rating_distribution: statistics[:rating_distribution],
          verified_purchases: statistics[:verified_purchases],
          last_updated_at: Time.current
        }
      )
    )
  end
end 