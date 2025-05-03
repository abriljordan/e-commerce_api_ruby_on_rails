module Api
  module V1
    module Admin
      class UsersController < BaseController
        before_action :set_user, only: [:show, :update, :destroy, :toggle_admin]

        def index
          @users = User.includes(:addresses, :orders)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(params[:per_page] || 20)

          if params[:role].present?
            @users = @users.where(role: params[:role])
          end

          if params[:search].present?
            @users = @users.where("username ILIKE :search OR email ILIKE :search", 
                                search: "%#{params[:search]}%")
          end

          render json: {
            users: @users,
            meta: {
              total_pages: @users.total_pages,
              current_page: @users.current_page,
              total_count: @users.total_count
            }
          }
        end

        def show
          render json: @user
        end

        def create
          @user = User.new(user_params)
          
          if @user.save
            render json: @user, status: :created
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @user.update(user_params)
            render json: @user
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          if @user.destroy
            head :no_content
          else
            render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def toggle_admin
          @user.toggle!(:admin)
          render json: @user
        end

        def statistics
          stats = {
            total_users: User.count,
            total_customers: User.customer.count,
            total_admins: User.admin.count,
            users_by_month: User.group("DATE_TRUNC('month', created_at)").count,
            recent_users: User.includes(:addresses)
                           .order(created_at: :desc)
                           .limit(5)
          }
          render json: stats
        end

        private

        def set_user
          @user = User.find(params[:id])
        end

        def user_params
          params.require(:user).permit(
            :username,
            :email,
            :password,
            :password_confirmation,
            :first_name,
            :last_name,
            :phone_number,
            :role
          )
        end
      end
    end
  end
end 