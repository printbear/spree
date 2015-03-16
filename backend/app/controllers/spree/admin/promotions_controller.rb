module Spree
  module Admin
    class PromotionsController < ResourceController
      before_filter :load_data
      before_filter :load_bulk_code_information, only: [:edit]

      create.before :build_promotion_codes

      helper 'spree/promotion_rules'

      def create
        @bulk_base = params[:bulk_base] if params[:bulk_base].present?
        @bulk_number = Integer(params[:bulk_number]) if params[:bulk_number].present?

        builder = Spree::PromotionCodeBuilder.new(promotion_attrs: permitted_resource_params,
                                                  base_code: @bulk_base,
                                                  number_of_codes: @bulk_number,
                                                  user: spree_current_user)
        @promotion = builder.promotion

        if builder.perform
          flash[:success] = create_success_message(builder)
          redirect_to location_after_save
        else
          flash[:error] = builder.promotion.errors.full_messages.join(", ")
          render action: 'new'
        end
      end

      protected
        def load_bulk_code_information
          @bulk_base = @promotion.codes.first.try!(:value)
          @bulk_number = @promotion.codes.count
        end

        def create_success_message(promotion_code_builder)
          flash_message_for(promotion_code_builder.promotion, :successfully_created)
        end

        def location_after_save
          spree.edit_admin_promotion_url(@promotion)
        end

        def load_data
          @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
          @promotion_categories = Spree::PromotionCategory.order(:name)
        end

        def collection
          return @collection if @collection.present?
          params[:q] ||= HashWithIndifferentAccess.new
          params[:q][:s] ||= 'id desc'

          @collection = super
          @search = @collection.ransack(params[:q])
          @collection = @search.result(distinct: true).
            includes(promotion_includes).
            page(params[:page]).
            per(params[:per_page] || Spree::Config[:promotions_per_page])

          @collection
        end

        def promotion_includes
          [:promotion_actions]
        end
    end
  end
end
