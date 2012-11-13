require 'spec_helper'

describe Spree::Admin::PricesController do
  stub_authorization!

  context "#create" do
    let(:product) { create :product }
    let(:variant) { create :variant, :product => product }
    let(:price) { variant.default_price }
    it "updates prices" do
      spree_post :create, { :product_id => product.to_param, :vp => { variant.id => { "USD" => "$123.45" }}}
      price.reload
      price.display_amount.should == "$123.45"
    end
  end
end
