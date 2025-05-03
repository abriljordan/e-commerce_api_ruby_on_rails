class ReviewStatisticsSerializer < ActiveModel::Serializer
  attributes :total_reviews, :average_rating, :rating_distribution, :verified_purchases

  has_many :recent_reviews, serializer: ProductReviewSerializer
  has_many :helpful_reviews, serializer: ProductReviewSerializer

  def rating_distribution
    object[:rating_distribution].map do |distribution|
      {
        rating: distribution[:rating],
        count: distribution[:count],
        percentage: distribution[:percentage]
      }
    end
  end
end 