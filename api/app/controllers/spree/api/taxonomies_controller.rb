module Spree
  module Api
    class TaxonomiesController < Spree::Api::BaseController
      respond_to :json

      def index
        @taxonomies = Taxonomy.order('name').includes(:root => :children).
                      ransack(params[:q]).result.
                      page(params[:page]).per(params[:per_page])
        respond_with(@taxonomies)
      end

      def show
        @taxonomy = Taxonomy.find(params[:id])
        respond_with(@taxonomy)
      end

      # Because JSTree wants parameters in a *slightly* different format
      def jstree
        show
      end

      private

      def taxonomy
        @taxonomy ||= Taxonomy.find(params[:id])
      end

    end
  end
end
