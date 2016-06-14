module Spree
  module Api
    class ZonesController < Spree::Api::BaseController

      def index
        @zones = Zone.order('name ASC').ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@zones)
      end

      def show
        respond_with(zone)
      end

      private
      def zone
        @zone ||= Spree::Zone.find(params[:id])
      end
    end
  end
end
