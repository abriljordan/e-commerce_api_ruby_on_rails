class ReviewAnalyticsSerializer < ActiveModel::Serializer
  attributes :total_reviews, :approved_reviews, :pending_reviews, :average_rating,
             :reviews_by_rating, :reviews_by_day, :review_velocity

  has_many :top_reviewers, serializer: UserSerializer
  has_many :top_products, serializer: ProductSerializer

  def reviews_by_rating
    object[:reviews_by_rating].map do |rating_data|
      {
        rating: rating_data[:rating],
        count: rating_data[:count],
        percentage: calculate_percentage(rating_data[:count])
      }
    end
  end

  def reviews_by_day
    object[:reviews_by_day].transform_keys { |date| date.strftime('%Y-%m-%d') }
  end

  private

  def calculate_percentage(count)
    total = object[:total_reviews]
    return 0 if total.zero?
    (count.to_f / total * 100).round(2)
  end
end 