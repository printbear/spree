FactoryGirl.define do
  factory :carton, class: Spree::Carton do
    order
    address
    stock_location
    shipping_method
    inventory_units { [create(:inventory_unit)] }
    shipped_at { Time.now }
  end
end
