module Spree
  module Api
    class ShipmentsController < Spree::Api::BaseController
      respond_to :json

      before_filter :find_order

      def update
        authorize! :read, Shipment
        @shipment = @order.shipments.find_by_number!(params[:id])
        params[:shipment] ||= []
        unlock = params[:shipment].delete(:unlock)

        if unlock == 'yes'
          @shipment.adjustment.open
        end

        @shipment.update_attributes(params[:shipment])

        if unlock == 'yes'
          @shipment.adjustment.close
        end

        @shipment.reload
        respond_with(@shipment, :default_template => :show)
      end

      private

      def find_order
        @order = Spree::Order.find_by_number!(params[:order_id])
        authorize! :read, @order
      end
    end
  end
end
