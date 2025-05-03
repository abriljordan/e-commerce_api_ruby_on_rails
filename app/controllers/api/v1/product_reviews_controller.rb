module Api
  module V1
    class ProductReviewsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product
      before_action :set_review, only: [:show, :update, :destroy]
      before_action :authorize_review, only: [:update, :destroy]

      def index
        @reviews = @product.product_reviews
                          .includes(:user)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(params[:per_page])

        render json: {
          reviews: ActiveModelSerializers::SerializableResource.new(@reviews),
          meta: pagination_meta(@reviews)
        }
      end

      def show
        render json: @review
      end

      def create
        @review = @product.product_reviews.build(review_params)
        @review.user = current_user

        if @review.save
          render json: @review, status: :created
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: @review
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @review.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def set_review
        @review = @product.product_reviews.find(params[:id])
      end

      def authorize_review
        unless @review.user == current_user || current_user.admin?
          render json: { error: 'Not authorized' }, status: :forbidden
        end
      end

      def review_params
        params.require(:product_review).permit(
          :title,
          :content,
          :rating,
          :metadata
        )
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end 