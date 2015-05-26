module Spree
  module Api
    class ShipmentsController < Spree::Api::BaseController

      before_filter :find_order
      before_filter :find_and_update_shipment, only: [:ship, :ready, :add, :remove]
      before_filter :load_transfer_params, only: [:transfer_to_location, :transfer_to_shipment]

      def create
        # TODO Can remove conditional here once deprecated #find_order is removed.
        unless @order.present?
          @order = Spree::Order.find_by!(number: params[:shipment][:order_id])
          authorize! :read, @order
        end
        authorize! :create, Shipment
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i
        @shipment = @order.shipments.create(stock_location_id: params[:stock_location_id])
        @order.contents.add(variant, quantity, nil, @shipment)

        @shipment.save!

        respond_with(@shipment.reload, default_template: :show)
      end

      def update
        if @order.present?
          @shipment = @order.shipments.accessible_by(current_ability, :update).find_by!(number: params[:id])
        else
          @shipment = Spree::Shipment.accessible_by(current_ability, :update).readonly(false).find_by!(number: params[:id])
        end

        @shipment.update_attributes_and_order(shipment_params)
        respond_with(@shipment.reload, default_template: :show)
      end

      def ready
        unless @shipment.ready?
          if @shipment.can_ready?
            @shipment.ready!
          else
            render 'spree/api/shipments/cannot_ready_shipment', status: 422 and return
          end
        end
        respond_with(@shipment, default_template: :show)
      end

      def ship
        unless @shipment.shipped?
          @shipment.ship!
        end
        respond_with(@shipment, default_template: :show)
      end

      def add
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i

        @shipment.order.contents.add(variant, quantity, nil, @shipment)

        respond_with(@shipment, default_template: :show)
      end

      def remove
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i

        @shipment.order.contents.remove(variant, quantity, @shipment)
        @shipment.reload if @shipment.persisted?
        respond_with(@shipment, default_template: :show)
      end

      def transfer_to_location
        success, message = @original_shipment.transfer_to_location(@variant, @quantity, @stock_location)
        status = success ? 201 : 422
        render json: {success: success, message: message}, status: status
      end

      def transfer_to_shipment
        success, message = @original_shipment.transfer_to_shipment(@variant, @quantity, @target_shipment)
        status = success ? 201 : 422
        render json: {success: success, message: message}, status: status
      end

      private

      def find_order
        if params[:order_id].present?
          ActiveSupport::Deprecation.warn "Spree::Api::ShipmentsController#find_order is deprecated and will be removed from Spree 2.3.x, access shipments directly without being nested to orders route instead.", caller
          @order = Spree::Order.find_by!(number: params[:order_id])
          authorize! :read, @order
        end
      end

      def load_transfer_params
        @original_shipment         = Spree::Shipment.where(number: params[:original_shipment_number]).first
        @target_shipment           = params[:target_shipment_number] ? Spree::Shipment.where(number: params[:target_shipment_number]).first : nil
        @variant                   = Spree::Variant.find(params[:variant_id])
        @quantity                  = params[:quantity].to_i
        @stock_location            = params[:stock_location_id] ? Spree::StockLocation.find(params[:stock_location_id]) : nil
        authorize! :read, @original_shipment
        authorize! :create, Shipment
      end

      def find_and_update_shipment
        if @order.present?
          @shipment = @order.shipments.accessible_by(current_ability, :update).find_by!(number: params[:id])
        else
          @shipment = Spree::Shipment.accessible_by(current_ability, :update).readonly(false).find_by!(number: params[:id])
        end
        @shipment.update_attributes(shipment_params)
        @shipment.reload
      end

      def shipment_params
        if params[:shipment] && !params[:shipment].empty?
          params.require(:shipment).permit(permitted_shipment_attributes)
        else
          {}
        end
      end
    end
  end
end
