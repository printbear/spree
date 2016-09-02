module Spree
  class StoreController < Spree::BaseController
    include Spree::Core::ControllerHelpers::Order

    protected
    
    def config_locale
      Spree::Frontend::Config[:locale]
    end
  end
end

