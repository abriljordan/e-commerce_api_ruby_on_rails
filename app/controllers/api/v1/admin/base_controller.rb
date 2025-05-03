module Api
  module V1
    module Admin
      class BaseController < Api::BaseController
        before_action :authorize_admin

        private

        def authorize_admin
          unauthorized unless current_user.admin?
        end
      end
    end
  end
end 