module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', :find_by => :permalink

      before_filter :load_supported_currencies

      def create
        params[:vp].each do |variant_id, prices|
          variant = Spree::Variant.find(variant_id)
          if variant
            supported_currencies.each do |currency|
              price = variant.price_in(currency.iso_code)
              price.amount = ((prices[currency.iso_code].nil? || prices[currency.iso_code].empty?) ? nil : prices[currency.iso_code])
              price.save! if price.changed?
            end
          end
        end
        render :action => :index
      end

      private
        def load_supported_currencies
          @supported_currencies = supported_currencies
        end
    end
  end
end
