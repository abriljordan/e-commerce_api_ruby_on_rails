class ReviewStatisticsService
  def initialize(product)
    @product = product
  end

  def calculate
    {
      total_reviews: total_reviews,
      average_rating: average_rating,
      rating_distribution: rating_distribution,
      recent_reviews: recent_reviews,
      verified_purchases: verified_purchases,
      helpful_reviews: helpful_reviews
    }
  end

  private

  def total_reviews
    @product.review_count
  end

  def average_rating
    @product.average_rating
  end

  def rating_distribution
    @product.rating_distribution
  end

  def recent_reviews
    @product.product_reviews
            .approved
            .includes(:user)
            .order(created_at: :desc)
            .limit(5)
  end

  def verified_purchases
    @product.product_reviews
            .approved
            .joins(:order_item)
            .distinct
            .count
  end

  def helpful_reviews
    @product.product_reviews
            .approved
            .where("metadata->>'helpful_count' > '0'")
            .order("(metadata->>'helpful_count')::integer DESC")
            .limit(5)
  end
end 