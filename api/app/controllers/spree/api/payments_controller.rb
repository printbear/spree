module Spree
  module Api
    class PaymentsController < Spree::Api::BaseController
      respond_to :json

      before_filter :find_order
      before_filter :find_payment, only: [:show]

      def index
        @payments = @order.payments.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@payments)
      end

      def show
        respond_with(@payment)
      end

      private

      def find_order
        @order = Order.find_by_number(params[:order_id])
        authorize! :read, @order
      end

      def find_payment
        @payment = @order.payments.find(params[:id])
      end
    end
  end
end
