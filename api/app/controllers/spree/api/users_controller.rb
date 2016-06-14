module Spree
  module Api
    class UsersController < Spree::Api::BaseController
      respond_to :json

      def index
        @users = Spree.user_class.accessible_by(current_ability,:read).ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        respond_with(@users)
      end

      def show
        authorize! :show, user
        respond_with(user)
      end

      private

      def user
        @user ||= Spree.user_class.find(params[:id])
      end
    end
  end
end
