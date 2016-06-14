module Spree
  module Api
    class ShipmentsController < Spree::Api::BaseController
      respond_to :json

      before_filter :find_order

      private

      def find_order
        @order = Spree::Order.find_by_number!(params[:order_id])
        authorize! :read, @order
      end
    end
  end
end
