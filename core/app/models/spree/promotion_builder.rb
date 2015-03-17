class Spree::PromotionBuilder
  include ActiveModel::Model

  attr_reader :promotion
  attr_accessor :base_code, :number_of_codes, :user

  validates :number_of_codes,
    numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true

  validate :promotion_validity

  class_attribute :default_random_code_length
  self.default_random_code_length = 6

  # @param promotion_attrs [Hash] The desired attributes for the newly promotion
  # @param attributes [Hash] The desired attributes for this builder
  # @param user [Spree::User] The user who triggered this promotion build
  def initialize(promotion_attrs, attributes)
    @promotion = Spree::Promotion.new(promotion_attrs)
    super(attributes)
  end

  def perform
    build_promotion_codes if @base_code && @number_of_codes
    @promotion.save
  end

  # Build promo codes. If @number_of_codes is greater than one then generate
  # multiple codes by adding a random suffix to each code.
  def build_promotion_codes
    if number_of_codes == 1
      @promotion.codes.build(value: @base_code)
    elsif number_of_codes > 1
      @number_of_codes.times do
        build_code_with_base
      end
    end
  end

  def number_of_codes=value
    @number_of_codes = value.presence.try(:to_i)
  end

  private
  def build_code_with_base
    random_code = code_with_randomness

    if Spree::PromotionCode.where(value: random_code).exists? || @promotion.codes.any? {|c| c.value == random_code }
      build_code_with_base
    else
      @promotion.codes.build(value: random_code)
    end
  end

  def code_with_randomness
    "#{@base_code}_#{Array.new(Spree::PromotionBuilder.default_random_code_length){ ('A'..'Z').to_a.sample }.join}"
  end

  def promotion_validity
    if !@promotion.valid?
      @promotion.errors.each do |attribute, error|
        errors[attribute].push error
      end
    end
  end
end
