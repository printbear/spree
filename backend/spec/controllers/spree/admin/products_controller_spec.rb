require 'spec_helper'

describe Spree::Admin::ProductsController do
  stub_authorization!

  context "#index" do
    let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }

    # Regression test for #1259
    it "can find a product by SKU" do
      product = create(:product, :sku => "ABC123")
      spree_get :index, :q => { :sku_start => "ABC123" }
      assigns[:collection].should_not be_empty
      assigns[:collection].should include(product)
    end
  end

  # regression test for #1370
  context "adding properties to a product" do
    let!(:product) { create(:product) }
    specify do
      spree_put :update, :id => product.to_param, :product => { :product_properties_attributes => { "1" => { :property_name => "Foo", :value => "bar" } } }
      flash[:success].should == "Product #{product.name.inspect} has been successfully updated!"
    end

  end


  # regression test for #801
  context "destroying a product" do
    let(:product) do
      product = create(:product)
      create(:variant, :product => product)
      product
    end

    it "deletes all the variants (including master) for the product" do
      spree_delete :destroy, :id => product
      product.reload.deleted_at.should_not be_nil
      product.variants_including_master.each do |variant|
        variant.reload.deleted_at.should_not be_nil
      end
    end
  end

  context "stock" do
    let!(:product) { create(:product) }
    let!(:variant_1) { create(:variant, product: product) }
    let!(:variant_2) { create(:variant, product: product, option_values: variant_1.option_values) }
    let!(:variant_3) { create(:variant, product: product, option_values: []) }

    subject { spree_get :stock, { variant_search_term: search_term, id: product.slug } }

    it "restricts stock location based on accessible attributes" do
      Spree::StockLocation.should_receive(:accessible_by).and_return([])
      spree_get :stock, :id => product
    end

    context "with a given sku" do
      let(:search_term) { variant_1.sku }

      it "finds the correct variants" do
        subject
        expect(assigns(:variants)).to match_array [variant_1]
      end
    end

    context "with an option value" do
      let(:search_term) { variant_1.option_values.first.presentation }

      it "finds the correct variants" do
        subject
        expect(assigns(:variants)).to match_array [variant_1, variant_2]
      end
    end

    context "with no search term" do
      let(:search_term) { "" }

      it "finds all variants associated to the product" do
        subject
        expect(assigns(:variants)).to match_array product.variants
      end
    end
  end
end
