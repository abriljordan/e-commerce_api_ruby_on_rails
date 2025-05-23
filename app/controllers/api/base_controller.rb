module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    
    before_action :authenticate_user
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def authenticate_user
      token = request.headers['Authorization']&.split(' ')&.last
      return unauthorized unless token

      decoded = JsonWebToken.decode(token)
      return unauthorized unless decoded && decoded[:user_id]

      @current_user = User.find_by(id: decoded[:user_id])
      unauthorized unless @current_user
    end

    def current_user
      @current_user
    end

    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { error: exception.message }, status: :bad_request
    end

    def unauthorized
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end 