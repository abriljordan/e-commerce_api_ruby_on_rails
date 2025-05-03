module Api
  module V1
    module Admin
      class OrdersController < BaseController
        before_action :set_order, only: [:show, :update, :cancel, :fulfill, :ship]

        def index
          @orders = Order.includes(:user, :address, :order_items)
                        .by_status(params[:status])
                        .by_date_range(params[:start_date], params[:end_date])
                        .recent
                        .page(params[:page])
                        .per(params[:per_page])

          render json: {
            orders: @orders,
            meta: pagination_meta(@orders)
          }
        end

        def show
          render json: @order, include: [:user, :address, :order_items, :order_histories]
        end

        def update
          if @order.update(order_params)
            render json: @order
          else
            render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def cancel
          if @order.can_cancel?
            @order.cancel!
            render json: @order
          else
            render json: { error: 'Order cannot be cancelled' }, status: :unprocessable_entity
          end
        end

        def fulfill
          if @order.may_fulfill?
            @order.fulfill!
            render json: @order
          else
            render json: { error: 'Order cannot be fulfilled' }, status: :unprocessable_entity
          end
        end

        def ship
          if @order.can_ship?
            @order.ship!
            render json: @order
          else
            render json: { error: 'Order cannot be shipped' }, status: :unprocessable_entity
          end
        end

        def statistics
          stats = {
            total_orders: Order.count,
            total_revenue: Order.completed.sum(:total_amount),
            average_order_value: Order.completed.average(:total_amount),
            orders_by_status: Order.group(:status).count,
            recent_orders: Order.includes(:user).recent.limit(5)
          }

          render json: stats
        end

        private

        def set_order
          @order = Order.find(params[:id])
        end

        def order_params
          params.require(:order).permit(
            :status,
            :tracking_number,
            :shipping_carrier,
            :total_amount,
            order_items_attributes: [
              :id,
              :product_id,
              :quantity,
              :price,
              :_destroy
            ]
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