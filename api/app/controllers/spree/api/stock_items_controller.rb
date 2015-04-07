module Spree
  module Api
    class StockItemsController < Spree::Api::BaseController
      before_filter :load_updateable_stock_locations, only: [:create]
      before_filter :load_readable_stock_locations, only: [:index, :show]

      def index
        @stock_items = scope.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@stock_items)
      end

      def show
        @stock_item = scope.find(params[:id])
        respond_with(@stock_item)
      end

      def create
        authorize! :create, StockItem

        count_on_hand = 0
        if params[:stock_item].has_key?(:count_on_hand)
          count_on_hand = params[:stock_item][:count_on_hand].to_i
        end

        @stock_item = scope.new(stock_item_params)

        if @stock_item.save && adjust_stock_item_count_on_hand(count_on_hand)
          respond_with(@stock_item, status: 201, default_template: :show)
        else
          invalid_resource!(@stock_item)
        end
      end

      def update
        @stock_item = StockItem.accessible_by(current_ability, :update).find(params[:id])

        count_on_hand_adjustment = 0
        if params[:stock_item].has_key?(:count_on_hand)
          count_on_hand_adjustment = params[:stock_item][:count_on_hand].to_i
          params[:stock_item].delete(:count_on_hand)
        end
        count_on_hand_adjustment -= @stock_item.count_on_hand if params[:stock_item][:force]

        if @stock_item.update_attributes(stock_item_params) && adjust_stock_item_count_on_hand(count_on_hand_adjustment)
          respond_with(@stock_item, status: 200, default_template: :show)
        else
          invalid_resource!(@stock_item)
        end
      end

      def destroy
        @stock_item = StockItem.accessible_by(current_ability, :destroy).find(params[:id])
        @stock_item.destroy
        respond_with(@stock_item, status: 204)
      end

      private

      def load_readable_stock_locations
        load_stock_location_by_ability(:read)
      end

      def load_updateable_stock_locations
        load_stock_location_by_ability(:update)
      end

      def load_stock_location_by_ability(ability)
        render 'spree/api/shared/stock_location_required', status: 422 and return unless params[:stock_location_id]
        @stock_location ||= StockLocation.accessible_by(current_ability, ability).find(params[:stock_location_id])
      end

      def scope
        includes = {:variant => [{ :option_values => :option_type }, :product] }
        @stock_location.stock_items.accessible_by(current_ability, :read).includes(includes)
      end

      def stock_item_params
        params.require(:stock_item).permit(permitted_stock_item_attributes)
      end

      def adjust_stock_item_count_on_hand(count_on_hand_adjustment)
        if @stock_item.should_track_inventory?
          Spree::StockMovement.new(stock_item: @stock_item, quantity: count_on_hand_adjustment, originator: current_api_user).save
        else
          @stock_item.adjust_count_on_hand(count_on_hand_adjustment)
        end
      end
    end
  end
end
