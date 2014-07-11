module Spree
  class ReviewComment < ActiveRecord::Base
    belongs_to :user, class_name: Spree.user_class
    belongs_to :order

    validates :user, :order, :comment, presence: true
  end
end
