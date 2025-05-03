module Api
  module V1
    class ProductsController < BaseController
      before_action :set_product, only: [:show, :update, :destroy]
      before_action :authorize_admin, only: [:create, :update, :destroy]

      def index
        @products = Product.active
                          .includes(:category, :sub_category)
                          .by_category(params[:category_id])
                          .by_sub_category(params[:sub_category_id])
                          .page(params[:page])
                          .per(params[:per_page] || 20)

        render json: {
          products: @products,
          meta: {
            total_pages: @products.total_pages,
            current_page: @products.current_page,
            total_count: @products.total_count
          }
        }
      end

      def show
        render json: @product, include: [:category, :sub_category, :product_skus]
      end

      def create
        @product = Product.new(product_params)
        
        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @product.destroy
        head :no_content
      end

      def search
        @products = Product.active
                          .where("name ILIKE :query OR description ILIKE :query", 
                                query: "%#{params[:q]}%")
                          .page(params[:page])
                          .per(params[:per_page] || 20)

        render json: {
          products: @products,
          meta: {
            total_pages: @products.total_pages,
            current_page: @products.current_page,
            total_count: @products.total_count
          }
        }
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(
          :name, :description, :summary, :price, :stock_quantity,
          :category_id, :sub_category_id, :active, :featured,
          :main_image, additional_images: []
        )
      end

      def authorize_admin
        unauthorized unless current_user.admin?
      end
    end
  end
end 