module Spree
  module Api
    class StockLocationsController < Spree::Api::BaseController
      def index
        authorize! :read, StockLocation
        @stock_locations = StockLocation.accessible_by(current_ability, :read).order('name ASC').ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@stock_locations)
      end

      def show
        authorize! :read, StockLocation
        respond_with(stock_location)
      end

      private

      def stock_location
        @stock_location ||= StockLocation.find(params[:id])
      end
    end
  end
end
