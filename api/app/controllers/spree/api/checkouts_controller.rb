module Spree
  module Api
    class CheckoutsController < Spree::Api::BaseController
      include Spree::Core::ControllerHelpers::Auth
      include Spree::Core::ControllerHelpers::Order
      # This before_filter comes from Spree::Core::ControllerHelpers::Order
      skip_before_filter :set_current_order

      respond_to :json

      def show
        redirect_to(api_order_path(params[:id]), status: 301)
      end
    end
  end
end
