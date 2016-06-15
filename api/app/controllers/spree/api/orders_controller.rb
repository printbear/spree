module Spree
  module Api
    class OrdersController < Spree::Api::BaseController
      respond_to :json

      before_filter :find_and_authorize!, :except => [:index, :search]

      def index
        # should probably look at turning this into a CanCan step
        raise CanCan::AccessDenied unless current_api_user.has_spree_role?("admin")
        @orders = Order.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@orders)
      end

      def show
        respond_with(@order)
      end

      private

      def find_order(lock = false)
        @order = Spree::Order.lock(lock).find_by_number!(params[:id])
        authorize! :update, @order, params[:order_token]
      end

      def find_and_authorize!
        find_order(true)
        authorize! :read, @order
      end
    end
  end
end
