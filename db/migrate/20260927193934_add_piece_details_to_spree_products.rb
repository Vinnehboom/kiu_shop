class AddPieceDetailsToSpreeProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :spree_products, :details, :jsonb, default: {}, null: false
    add_column :spree_products, :food_safe, :boolean, default: false, null: false
    add_column :spree_products, :dishwasher_safe, :boolean, default: false, null: false
  end
end
