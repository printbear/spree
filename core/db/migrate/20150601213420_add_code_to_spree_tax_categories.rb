class AddCodeToSpreeTaxCategories < ActiveRecord::Migration
  def change
    add_column :spree_tax_categories, :code, :string
  end
end
