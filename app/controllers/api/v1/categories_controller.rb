module Api
  module V1
    class CategoriesController < BaseController
      before_action :set_category, only: [:show, :update, :destroy]
      before_action :authorize_admin, only: [:create, :update, :destroy]

      def index
        @categories = Category.includes(:sub_categories)
                           .order(:name)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

        render json: {
          categories: @categories,
          meta: {
            total_pages: @categories.total_pages,
            current_page: @categories.current_page,
            total_count: @categories.total_count
          }
        }
      end

      def show
        render json: @category
      end

      def create
        @category = Category.new(category_params)
        
        if @category.save
          render json: @category, status: :created
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @category.products.empty?
          @category.destroy
          head :no_content
        else
          render json: { error: 'Cannot delete category with associated products' }, status: :unprocessable_entity
        end
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :description)
      end

      def authorize_admin
        unauthorized unless current_user.admin?
      end
    end
  end
end 