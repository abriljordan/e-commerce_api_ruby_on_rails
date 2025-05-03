module Api
  module V1
    class AuthenticationController < ApplicationController
      include Authentication
      skip_before_action :authenticate_user!, only: [:login, :register, :refresh]

      def login
        user = User.find_by(email: params[:email])
        
        if user&.authenticate(params[:password])
          access_token = JsonWebToken.encode(user_id: user.id)
          refresh_token = JsonWebToken.refresh_encode(user_id: user.id)
          
          render json: {
            access_token: access_token,
            refresh_token: refresh_token,
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
          access_token = JsonWebToken.encode(user_id: user.id)
          refresh_token = JsonWebToken.refresh_encode(user_id: user.id)
          
          render json: {
            access_token: access_token,
            refresh_token: refresh_token,
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

      def refresh
        refresh_token = params[:refresh_token]
        
        if refresh_token.blank?
          return render json: { error: 'Refresh token is missing' }, status: :unauthorized
        end

        decoded = JsonWebToken.refresh_decode(refresh_token)
        
        if decoded.blank? || decoded[:user_id].blank?
          return render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end

        user = User.find_by(id: decoded[:user_id])
        
        if user.nil?
          return render json: { error: 'User not found' }, status: :unauthorized
        end

        new_access_token = JsonWebToken.encode(user_id: user.id)
        new_refresh_token = JsonWebToken.refresh_encode(user_id: user.id)

        render json: {
          access_token: new_access_token,
          refresh_token: new_refresh_token,
          user: {
            id: user.id,
            email: user.email,
            username: user.username,
            role: user.role
          }
        }
      end

      def logout
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
    end
  end
end 