module Spree
  module Api
    class OptionValuesController < Spree::Api::BaseController
      def index
        if params[:ids]
          @option_values = scope.where(:id => params[:ids])
        else
          @option_values = scope.ransack(params[:q]).result
        end
        respond_with(@option_values)
      end

      def show
      	@option_value = scope.find(params[:id])
      	respond_with(@option_value)
      end

      private

        def scope
          if params[:option_type_id]
            @scope ||= Spree::OptionType.find(params[:option_type_id]).option_values
          else
            @scope ||= Spree::OptionValue.scoped
          end
        end
    end
  end
end
