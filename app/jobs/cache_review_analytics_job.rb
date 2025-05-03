class CacheReviewAnalyticsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.cache.write('review_analytics', calculate_analytics, expires_in: 1.hour)
  end

  private

  def calculate_analytics
    {
      daily: ReviewAnalyticsService.new(1.day.ago, Time.current).calculate,
      weekly: ReviewAnalyticsService.new(7.days.ago, Time.current).calculate,
      monthly: ReviewAnalyticsService.new(30.days.ago, Time.current).calculate
    }
  end
end 