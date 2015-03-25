# A class responsible for building PromotionCodes
class ::Spree::PromotionCode::CodeBuilder
  attr_reader :promotion, :num_codes, :base_code

  class_attribute :random_code_length
  self.random_code_length = 6

  # Requres a +promotion+, +base_code+ and +num_codes+
  #
  # +promotion+ Must be a Spree::Promotion.
  # +base_code+ Must be a String.
  # +num_codes+ Must be a positive integer greater than zero.
  def initialize promotion, base_code, num_codes
    @base_code = base_code
    @num_codes = num_codes
    @promotion = promotion
  end

  # Builds and returns an array of Spree::PromotionCode's
  def build_promotion_codes
    codes.map do |code|
      promotion.codes.build(value: code)
    end
  end

  private

  def codes
    if num_codes > 1
      generate_random_codes
    else
      [base_code]
    end
  end

  def generate_random_codes
    loop do
      code_list = num_codes.times.map { generate_random_code }

      return code_list if code_list_unique?(code_list)
    end
  end

  def generate_random_code
    suffix = Array.new(self.class.random_code_length) do
      sample_characters.sample
    end.join

    "#{@base_code}_#{suffix}"
  end

  def sample_characters
    @sample_characters ||= ('a'..'z').to_a
  end

  def code_list_unique? code_list
    code_list.length == code_list.uniq.length &&
      Spree::PromotionCode.where(value: code_list).empty?
  end
end
