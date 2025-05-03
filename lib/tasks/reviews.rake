namespace :reviews do
  desc 'Update review statistics for all products'
  task update_statistics: :environment do
    Product.find_each do |product|
      UpdateReviewStatisticsJob.perform_later(product.id)
    end
  end

  desc 'Clean up unapproved reviews older than 30 days'
  task cleanup: :environment do
    ProductReview.pending
                .where('created_at < ?', 30.days.ago)
                .destroy_all
  end

  desc 'Cache review analytics'
  task cache_analytics: :environment do
    CacheReviewAnalyticsJob.perform_later
  end
end 