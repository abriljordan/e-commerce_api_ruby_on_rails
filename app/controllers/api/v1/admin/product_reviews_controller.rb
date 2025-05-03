module Api
  module V1
    module Admin
      class ProductReviewsController < BaseController
        before_action :set_product
        before_action :set_review, only: [:show, :update, :destroy, :approve, :reject]

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

        def approve
          if @review.update(approved: true)
            render json: @review
          else
            render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def reject
          if @review.update(approved: false)
            render json: @review
          else
            render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def pending
          @reviews = ProductReview.pending
                                .includes(:user, :product)
                                .order(created_at: :desc)
                                .page(params[:page])
                                .per(params[:per_page])

          render json: {
            reviews: ActiveModelSerializers::SerializableResource.new(@reviews),
            meta: pagination_meta(@reviews)
          }
        end

        private

        def set_product
          @product = Product.find(params[:product_id])
        end

        def set_review
          @review = @product.product_reviews.find(params[:id])
        end

        def review_params
          params.require(:product_review).permit(
            :title,
            :content,
            :rating,
            :approved,
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
end 