module Spree
  module Api
    class PropertiesController < Spree::Api::BaseController
      respond_to :json

      before_filter :find_property, :only => [:show]

      def index
        @properties = Spree::Property.
                      ransack(params[:q]).result.
                      page(params[:page]).per(params[:per_page])
        respond_with(@properties)
      end

      def show
        respond_with(@property)
      end

      private

      def find_property
        @property = Spree::Property.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @property = Spree::Property.find_by_name!(params[:id])
      end

    end
  end
end
