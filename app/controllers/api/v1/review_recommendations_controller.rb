module Api
  module V1
    class ReviewRecommendationsController < ApplicationController
      before_action :authenticate_user!

      def index
        recommendations = Rails.cache.fetch("user:#{current_user.id}:review_recommendations", expires_in: 1.day) do
          ReviewRecommendationService.new(current_user).recommended_products
        end

        render json: recommendations, each_serializer: ProductSerializer
      end
    end
  end
end 