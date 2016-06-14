module Spree
  module Api
    class OptionTypesController < Spree::Api::BaseController
      def index
        if params[:ids]
          @option_types = Spree::OptionType.where(:id => params[:ids].split(','))
        else
          @option_types = Spree::OptionType.scoped.ransack(params[:q]).result
        end
        respond_with(@option_types)
      end

      def show
      	@option_type = Spree::OptionType.find(params[:id])
      	respond_with(@option_type)
      end
    end
  end
end
