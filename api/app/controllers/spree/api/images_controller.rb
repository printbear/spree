module Spree
  module Api
    class ImagesController < Spree::Api::BaseController
      respond_to :json

      def show
        @image = Image.find(params[:id])
        respond_with(@image)
      end
    end
  end
end
