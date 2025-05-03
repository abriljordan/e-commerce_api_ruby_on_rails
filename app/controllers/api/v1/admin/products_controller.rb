module Api
  module V1
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: [:show, :update, :destroy, :toggle_active, :toggle_featured]

        def index
          @products = Product.includes(:category, :sub_category, :product_skus)
                           .order(created_at: :desc)
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
          render json: @product
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
          if @product.destroy
            head :no_content
          else
            render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def toggle_active
          @product.toggle!(:active)
          render json: @product
        end

        def toggle_featured
          @product.toggle!(:featured)
          render json: @product
        end

        def bulk_update
          products = Product.where(id: params[:product_ids])
          if products.update_all(bulk_update_params)
            render json: { message: 'Products updated successfully' }
          else
            render json: { error: 'Failed to update products' }, status: :unprocessable_entity
          end
        end

        private

        def set_product
          @product = Product.find(params[:id])
        end

        def product_params
          params.require(:product).permit(
            :name, :description, :summary, :price, :stock_quantity,
            :category_id, :sub_category_id, :active, :featured,
            :main_image, additional_images: [],
            product_skus_attributes: [
              :id, :sku, :price, :stock_quantity, :_destroy,
              product_attribute_values_attributes: [
                :id, :product_attribute_id, :value, :_destroy
              ]
            ]
          )
        end

        def bulk_update_params
          params.require(:product).permit(:active, :featured)
        end
      end
    end
  end
end
