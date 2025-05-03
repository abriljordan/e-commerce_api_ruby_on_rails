module Api
  module V1
    class OrdersController < BaseController
      before_action :set_order, only: [:show, :update, :cancel]

      def index
        @orders = current_user.orders
                            .includes(:order_items, :address)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(params[:per_page] || 10)

        render json: {
          orders: @orders,
          meta: {
            total_pages: @orders.total_pages,
            current_page: @orders.current_page,
            total_count: @orders.total_count
          }
        }
      end

      def show
        render json: @order
      end

      def create
        @order = current_user.orders.new(order_params)
        
        if @order.save
          # Clear the cart after successful order creation
          current_user.cart.cart_items.destroy_all
          render json: @order, status: :created
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @order.update(order_params)
          render json: @order
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def cancel
        if @order.may_cancel?
          @order.cancel!
          render json: @order
        else
          render json: { error: 'Order cannot be cancelled' }, status: :unprocessable_entity
        end
      end

      private

      def set_order
        @order = current_user.orders.find(params[:id])
      end

      def order_params
        params.require(:order).permit(
          :address_id,
          :payment_method,
          :notes,
          order_items_attributes: [
            :product_sku_id,
            :quantity,
            :price
          ]
        )
      end
    end
  end
end 