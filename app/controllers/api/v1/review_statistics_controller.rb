module Api
  module V1
    class ReviewStatisticsController < ApplicationController
      before_action :set_product

      def show
        statistics = ReviewStatisticsService.new(@product).calculate
        render json: statistics, serializer: ReviewStatisticsSerializer
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end
    end
  end
end 