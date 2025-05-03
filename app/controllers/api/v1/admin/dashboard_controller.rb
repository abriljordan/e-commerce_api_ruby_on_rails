module Api
  module V1
    module Admin
      class DashboardController < BaseController
        def statistics
          stats = {
            overview: {
              total_products: Product.count,
              total_orders: Order.count,
              total_users: User.count,
              total_revenue: Order.completed.sum(:total_amount)
            },
            recent_activity: {
              recent_orders: Order.includes(:user)
                               .order(created_at: :desc)
                               .limit(5),
              recent_users: User.includes(:addresses)
                             .order(created_at: :desc)
                             .limit(5),
              recent_products: Product.includes(:category)
                                   .order(created_at: :desc)
                                   .limit(5)
            },
            sales_analytics: {
              daily_sales: Order.completed
                              .where(created_at: 30.days.ago..Time.current)
                              .group("DATE(created_at)")
                              .sum(:total_amount),
              monthly_sales: Order.completed
                                .where(created_at: 1.year.ago..Time.current)
                                .group("DATE_TRUNC('month', created_at)")
                                .sum(:total_amount),
              top_products: OrderItem.joins(:product)
                                   .group('products.name')
                                   .sum('order_items.quantity * order_items.price')
                                   .sort_by { |_, v| -v }
                                   .first(5)
            },
            user_analytics: {
              new_users: User.where(created_at: 30.days.ago..Time.current)
                           .group("DATE(created_at)")
                           .count,
              user_roles: User.group(:role).count,
              top_customers: User.joins(:orders)
                               .where(orders: { status: 'completed' })
                               .group('users.id')
                               .sum('orders.total_amount')
                               .sort_by { |_, v| -v }
                               .first(5)
            }
          }
          render json: stats
        end
      end
    end
  end
end 