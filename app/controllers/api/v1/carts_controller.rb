module Api
  module V1
    class CartsController < BaseController
      before_action :set_cart, only: [:show, :update, :destroy]

      def show
        render json: @cart
      end

      def update
        if @cart.update(cart_params)
          render json: @cart
        else
          render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @cart.cart_items.destroy_all
        head :no_content
      end

      private

      def set_cart
        @cart = current_user.cart
      end

      def cart_params
        params.require(:cart).permit(
          cart_items_attributes: [
            :id,
            :product_sku_id,
            :quantity,
            :_destroy
          ]
        )
      end
    end
  end
end 