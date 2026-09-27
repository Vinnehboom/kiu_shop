class MakeStockLocationsNotBackorderable < ActiveRecord::Migration[7.1]
  def up
    execute 'UPDATE spree_stock_locations SET backorderable_default = false'
    execute 'UPDATE spree_stock_items SET backorderable = false'
  end

  def down; end
end
