class ReviewRecommendationService
  def initialize(user)
    @user = user
  end

  def recommended_products
    # Get products the user has purchased but not reviewed
    purchased_products = Product.joins(order_items: :order)
                              .where(orders: { user_id: @user.id, status: 'completed' })
                              .where.not(id: @user.product_reviews.select(:product_id))
                              .distinct

    # Get products similar to those the user has reviewed positively
    positively_reviewed_products = Product.joins(:product_reviews)
                                        .where(product_reviews: { user_id: @user.id, rating: 4..5 })
                                        .distinct

    similar_products = positively_reviewed_products.flat_map do |product|
      find_similar_products(product)
    end.uniq

    # Combine and rank recommendations
    (purchased_products + similar_products)
      .uniq
      .sort_by { |product| calculate_recommendation_score(product) }
      .reverse
      .first(10)
  end

  private

  def find_similar_products(product)
    # Find products in the same category with similar ratings
    Product.joins(:category)
           .where(category: product.category)
           .where(average_rating: (product.average_rating - 1)..(product.average_rating + 1))
           .where.not(id: product.id)
           .limit(5)
  end

  def calculate_recommendation_score(product)
    score = 0

    # Higher score for purchased products
    score += 100 if @user.orders.completed.joins(:order_items).where(order_items: { product_id: product.id }).exists?

    # Higher score for products with more reviews
    score += product.review_count

    # Higher score for products with better ratings
    score += (product.average_rating * 20)

    # Higher score for products in categories the user likes
    if @user.product_reviews.joins(:product).where(products: { category_id: product.category_id }).exists?
      score += 50
    end

    score
  end
end 