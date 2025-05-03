class CacheReviewRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    recommendations = ReviewRecommendationService.new(user).recommended_products
    Rails.cache.write("user:#{user_id}:review_recommendations", recommendations, expires_in: 1.day)
  end
end 