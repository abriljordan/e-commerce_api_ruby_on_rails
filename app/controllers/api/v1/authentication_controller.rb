module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_user, only: [:login, :register]

      def login
        user = User.find_by(email: params[:email])
        
        if user&.authenticate(params[:password])
          token = generate_token(user)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              username: user.username,
              role: user.role
            }
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def register
        user = User.new(user_params)
        
        if user.save
          token = generate_token(user)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              username: user.username,
              role: user.role
            }
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def logout
        current_user.update(api_token: nil)
        head :no_content
      end

      private

      def user_params
        params.require(:user).permit(
          :username,
          :email,
          :password,
          :password_confirmation,
          :first_name,
          :last_name,
          :phone_number
        )
      end

      def generate_token(user)
        token = SecureRandom.hex(32)
        user.update(api_token: token)
        token
      end
    end
  end
end 