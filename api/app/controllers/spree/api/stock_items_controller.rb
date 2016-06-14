module Spree
  module Api
    class StockItemsController < Spree::Api::BaseController
      def index
        authorize! :read, StockItem
        @stock_items = scope.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@stock_items)
      end

      def show
        authorize! :read, StockItem
        @stock_item = scope.find(params[:id])
        respond_with(@stock_item)
      end

      private

      def stock_location
        render 'spree/api/shared/stock_location_required', status: 422 and return unless params[:stock_location_id]
        @stock_location ||= StockLocation.find(params[:stock_location_id])
      end

      def scope
        includes = {:variant => [{ :option_values => :option_type }, :product] }
        @stock_location.stock_items.includes(includes)
      end
    end
  end
end
