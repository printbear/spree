module Spree
  module PromotionHandler
    class Coupon
      attr_reader :order
      attr_accessor :error, :success

      def initialize(order)
        @order = order
      end

      def apply
        if order.coupon_code.present?
          if promotion.present? && promotion.actions.exists?
            handle_present_promotion(promotion)
          else
            if promotion_code && promotion_code.promotion.expired?
              self.error = Spree.t(:coupon_code_expired)
            else
              self.error = Spree.t(:coupon_code_not_found)
            end
          end
        end

        self
      end

      def promotion
        @promotion ||= begin
          if promotion_code && promotion_code.promotion.active?
            promotion_code.promotion
          end
        end
      end

      def successful?
        success.present? && error.blank?
      end

      private

      def promotion_code
        @promotion_code ||= Spree::PromotionCode.where(value: order.coupon_code.downcase).first
      end

      def handle_present_promotion(promotion)
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded?(order) || promotion_code.usage_limit_exceeded?(order)
        return promotion_applied if promotion_exists_on_order?(order, promotion)
        return ineligible_for_this_order unless promotion.eligible?(order, promotion_code: promotion_code)

        # If any of the actions for the promotion return `true`,
        # then result here will also be `true`.
        result = promotion.activate(order: order, promotion_code: promotion_code)
        if result
          determine_promotion_application_result
        else
          self.error = Spree.t(:coupon_code_unknown_error)
        end
      end

      def promotion_usage_limit_exceeded
        self.error = Spree.t(:coupon_code_max_usage)
      end

      def ineligible_for_this_order
        self.error = Spree.t(:coupon_code_not_eligible)
      end

      def promotion_applied
        self.error = Spree.t(:coupon_code_already_applied)
      end

      def promotion_exists_on_order?(order, promotion)
        order.promotions.include? promotion
      end

      def determine_promotion_application_result
        detector = lambda { |p|
          p.source.promotion.codes.any? { |code| code.value == order.coupon_code.downcase }
        }

        discount = order.line_item_adjustments.promotion.detect(&detector)
        discount ||= order.shipment_adjustments.promotion.detect(&detector)
        discount ||= order.adjustments.promotion.detect(&detector)

        if discount.eligible
          order.update_totals
          order.persist_totals
          self.success = Spree.t(:coupon_code_applied)
        else
          # if the promotion was created after the order
          self.error = Spree.t(:coupon_code_not_found)
        end
      end
    end
  end
end
