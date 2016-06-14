module Spree
  module Api
    class ReturnAuthorizationsController < Spree::Api::BaseController
      respond_to :json

      before_filter :authorize_admin!

      def index
        @return_authorizations = order.return_authorizations.
                                 ransack(params[:q]).result.
                                 page(params[:page]).per(params[:per_page])
        respond_with(@return_authorizations)
      end

      def show
        @return_authorization = order.return_authorizations.find(params[:id])
        respond_with(@return_authorization)
      end

      private

      def order
        @order ||= Order.find_by_number!(params[:order_id])
      end

      def authorize_admin!
        authorize! :manage, Spree::ReturnAuthorization
      end
    end
  end
end
