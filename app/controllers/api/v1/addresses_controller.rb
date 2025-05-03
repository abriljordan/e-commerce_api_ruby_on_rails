module Api
  module V1
    class AddressesController < BaseController
      before_action :set_address, only: [:show, :update, :destroy]

      def index
        @addresses = current_user.addresses
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(params[:per_page] || 10)

        render json: {
          addresses: @addresses,
          meta: {
            total_pages: @addresses.total_pages,
            current_page: @addresses.current_page,
            total_count: @addresses.total_count
          }
        }
      end

      def show
        render json: @address
      end

      def create
        @address = current_user.addresses.new(address_params)
        
        if @address.save
          render json: @address, status: :created
        else
          render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @address.update(address_params)
          render json: @address
        else
          render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @address.destroy
        head :no_content
      end

      def set_default
        @address = current_user.addresses.find(params[:id])
        current_user.addresses.update_all(default: false)
        @address.update(default: true)
        render json: @address
      end

      private

      def set_address
        @address = current_user.addresses.find(params[:id])
      end

      def address_params
        params.require(:address).permit(
          :street_address,
          :city_id,
          :state,
          :postal_code,
          :country_id,
          :phone_number,
          :default
        )
      end
    end
  end
end 