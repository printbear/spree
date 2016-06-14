module Spree
  module Api
    class InventoryUnitsController < Spree::Api::BaseController
      def show
        @inventory_unit = inventory_unit
      end

      private

      def inventory_unit
        @inventory_unit ||= InventoryUnit.find(params[:id])
      end
    end
  end
end
