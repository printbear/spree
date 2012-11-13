module Spree
  class CurrencyController < Spree::StoreController
    def set
      currency = supported_currencies.find { |currency| currency.iso_code == params[:currency] }
      session[:currency] = params[:currency]
      render :json => !currency.nil?
    end
  end
end
