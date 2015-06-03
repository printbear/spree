module Spree
  class TaxCategory < ActiveRecord::Base
    acts_as_paranoid
    validates :name, presence: true, uniqueness: { scope: :deleted_at }

    has_many :tax_rates, dependent: :destroy
    after_save :ensure_one_default

    def self.default
      find_by(is_default: true)
    end

    def ensure_one_default
      if is_default
        Spree::TaxCategory.where(is_default: true).where.not(id: self.id).update_all(is_default: false, updated_at: Time.now)
      end
    end
  end
end
