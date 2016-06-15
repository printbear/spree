module Spree
  module Api
    class TaxonsController < Spree::Api::BaseController
      respond_to :json

      def index
        if taxonomy
          @taxons = taxonomy.root.children
        else
          if params[:ids]
            @taxons = Taxon.accessible_by(current_ability, :read).where(:id => params[:ids].split(","))
          else
            @taxons = Taxon.accessible_by(current_ability, :read).order(:taxonomy_id, :lft).ransack(params[:q]).result
          end
        end

        @taxons = @taxons.page(params[:page]).per(params[:per_page])
        respond_with(@taxons)
      end

      def show
        @taxon = taxon
        respond_with(@taxon)
      end

      def jstree
        show
      end

      private

      def taxonomy
        if params[:taxonomy_id].present?
          @taxonomy ||= Taxonomy.find(params[:taxonomy_id])
        end
      end

      def taxon
        @taxon ||= taxonomy.taxons.find(params[:id])
      end

    end
  end
end
