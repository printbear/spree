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
  def initialize(attributes={}, promotion_attributes={})
    @promotion = Spree::Promotion.new(promotion_attributes)
    super(attributes)
  end

  def perform
    build_promotion_codes if @base_code && @number_of_codes
    @promotion.save
  end

  def number_of_codes=value
    @number_of_codes = value.presence.try(:to_i)
  end

  private

  # Build promo codes. If @number_of_codes is greater than one then generate
  # multiple codes by adding a random suffix to each code.
  def build_promotion_codes
    codes.each do |code|
      @promotion.codes.build(value: code)
    end
  end

  def codes
    if number_of_codes == 1
      [base_code]
    else
      random_codes
    end
  end

  def random_codes
    loop do 
      code_list = number_of_codes.times.map { code_with_randomness }
      if code_list.length == code_list.uniq.length && Spree::PromotionCode.where(value: code_list).empty?
        return code_list
      end
    end
  end

  def code_with_randomness
    "#{@base_code}_#{Array.new(Spree::PromotionBuilder.default_random_code_length){ ('a'..'z').to_a.sample }.join}"
  end

  def promotion_validity
    if !@promotion.valid?
      @promotion.errors.each do |attribute, error|
        errors[attribute].push error
      end
    end
  end
end
