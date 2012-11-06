module Spree
  class Price < ActiveRecord::Base
    belongs_to :variant, :class_name => 'Spree::Variant'

    validate :check_price
    validates :amount, :numericality => { :greater_than_or_equal_to => 0 }, :presence => true

    attr_accessible :variant_id, :currency, :amount

    def display_amount
      money.to_s
    end
    alias :display_price :display_amount

    def money
      Spree::Money.new(amount, { :currency => currency })
    end

    def price
      amount
    end

    def price=(price)
      self[:amount] = parse_price(price) if price.present?
    end

    private
    def check_price
      raise "Price must belong to a variant" if variant.nil?
      if amount.nil?
        self.amount = variant.product.master.default_price.amount
      end
      if currency.nil?
        self.currency = variant.product.master.default_price.currency
      end
    end

    # strips all non-price-like characters from the price, taking into account locale settings
    def parse_price(price)
      return price unless price.is_a?(String)

      separator, delimiter = I18n.t([:'number.currency.format.separator', :'number.currency.format.delimiter'])
      non_price_characters = /[^0-9\-#{separator}]/
      price.gsub!(non_price_characters, '') # strip everything else first
      price.gsub!(separator, '.') unless separator == '.' # then replace the locale-specific decimal separator with the standard separator if necessary

      price.to_d
    end

  end
end

