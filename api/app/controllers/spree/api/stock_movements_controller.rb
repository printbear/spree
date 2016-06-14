module Spree
  module Api
    class StockMovementsController < Spree::Api::BaseController
      def index
        authorize! :read, StockMovement
        @stock_movements = scope.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@stock_movements)
      end

      def show
        authorize! :read, StockMovement
        @stock_movement = scope.find(params[:id])
        respond_with(@stock_movement)
      end

      private

      def stock_location
        render 'spree/api/shared/stock_location_required', status: 422 and return unless params[:stock_location_id]
        @stock_location ||= StockLocation.find(params[:stock_location_id])
      end

      def scope
        @stock_location.stock_movements
      end
    end
  end
end
