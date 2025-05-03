class ReviewAnalyticsService
  def initialize(start_date = 30.days.ago, end_date = Time.current)
    @start_date = start_date
    @end_date = end_date
  end

  def calculate
    {
      total_reviews: total_reviews,
      approved_reviews: approved_reviews,
      pending_reviews: pending_reviews,
      average_rating: average_rating,
      reviews_by_rating: reviews_by_rating,
      reviews_by_day: reviews_by_day,
      top_reviewers: top_reviewers,
      top_products: top_products,
      review_velocity: review_velocity
    }
  end

  private

  def total_reviews
    ProductReview.where(created_at: @start_date..@end_date).count
  end

  def approved_reviews
    ProductReview.approved.where(created_at: @start_date..@end_date).count
  end

  def pending_reviews
    ProductReview.pending.where(created_at: @start_date..@end_date).count
  end

  def average_rating
    ProductReview.approved
                .where(created_at: @start_date..@end_date)
                .average(:rating)
                &.round(2) || 0
  end

  def reviews_by_rating
    (1..5).map do |rating|
      {
        rating: rating,
        count: ProductReview.approved
                           .where(rating: rating, created_at: @start_date..@end_date)
                           .count
      }
    end
  end

  def reviews_by_day
    ProductReview.where(created_at: @start_date..@end_date)
                .group_by_day(:created_at)
                .count
  end

  def top_reviewers
    User.joins(:product_reviews)
        .where(product_reviews: { created_at: @start_date..@end_date })
        .group('users.id')
        .order('COUNT(product_reviews.id) DESC')
        .limit(10)
        .select('users.*, COUNT(product_reviews.id) as review_count')
  end

  def top_products
    Product.joins(:product_reviews)
           .where(product_reviews: { created_at: @start_date..@end_date })
           .group('products.id')
           .order('COUNT(product_reviews.id) DESC')
           .limit(10)
           .select('products.*, COUNT(product_reviews.id) as review_count')
  end

  def review_velocity
    {
      daily: calculate_velocity(1.day),
      weekly: calculate_velocity(7.days),
      monthly: calculate_velocity(30.days)
    }
  end

  def calculate_velocity(period)
    start_date = @end_date - period
    previous_period = start_date - period

    current_count = ProductReview.where(created_at: start_date..@end_date).count
    previous_count = ProductReview.where(created_at: previous_period..start_date).count

    {
      count: current_count,
      change: previous_count.zero? ? 0 : ((current_count - previous_count).to_f / previous_count * 100).round(2)
    }
  end
end 