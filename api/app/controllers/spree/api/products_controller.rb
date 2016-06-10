module Spree
  module Api
    class ProductsController < Spree::Api::BaseController
      respond_to :json

      def index
        if params[:ids]
          @products = product_scope.where(:id => params[:ids].split(","))
        else
          @products = product_scope.ransack(params[:q]).result
        end

        @products = @products.page(params[:page]).per(params[:per_page])

        respond_with(@products)
      end

      def show
        @product = find_product(params[:id])
        respond_with(@product)
      end
    end
  end
end
