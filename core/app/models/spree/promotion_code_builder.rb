class Spree::PromotionCodeBuilder
  attr_reader :promotion

  class_attribute :default_random_code_length
  self.default_random_code_length = 6

  def initialize(promotion_attrs:, base_code:, number_of_codes:, user: nil)
    @promotion_attrs = promotion_attrs
    @promotion = Spree::Promotion.new(@promotion_attrs)
    @base_code = base_code
    @number_of_codes = number_of_codes
    @user = user
  end

  def perform
    build_promotion_codes if @base_code && @number_of_codes
    @promotion.save
  end

  # Build promo codes. If number_of_codes is great than one then generate
  # multiple codes by adding a random suffix to each code.
  #
  # @param base_code [String] When number_of_codes=1 this is the code. When
  #   number_of_codes > 1 it is the base of the generated codes.
  # @param number_of_codes [Integer] Number of codes to generate
  # @param usage_limit [Integer] Usage limit for each code
  def build_promotion_codes
    if @number_of_codes == 1
      @promotion.codes.build(value: @base_code)
    elsif @number_of_codes > 1
      @number_of_codes.times do
        build_code_with_base
      end
    end
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
    "#{@base_code}_#{Array.new(Spree::PromotionCodeBuilder.default_random_code_length){ ('A'..'Z').to_a.sample }.join}"
  end
end
