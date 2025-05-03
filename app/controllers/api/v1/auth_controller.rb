class Api::V1::AuthController < ApplicationController
  # ... existing code ...

  def logout
    if current_user
      current_user.update(jti: SecureRandom.uuid)
      render json: { message: 'Successfully logged out' }, status: :ok
    else
      render json: { error: 'Not logged in' }, status: :unauthorized
    end
  end

  # ... existing code ...
end 