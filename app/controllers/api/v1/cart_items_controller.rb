module Api
  module V1
    class CartItemsController < BaseController
      before_action :set_cart_item, only: [:update, :destroy]

      def create
        @cart_item = current_user.cart.cart_items.new(cart_item_params)
        
        if @cart_item.save
          render json: @cart_item, status: :created
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @cart_item.update(cart_item_params)
          render json: @cart_item
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @cart_item.destroy
        head :no_content
      end

      private

      def set_cart_item
        @cart_item = current_user.cart.cart_items.find(params[:id])
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :product_variant_id, :quantity)
      end
    end
  end
end 