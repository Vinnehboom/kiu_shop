module PotteryShop
  module StockLocationDefaults
    def self.enforce!
      Spree::StockLocation.find_each { |location| location.update!(backorderable_default: false) }
      Spree::StockItem.find_each { |item| item.update!(backorderable: false) }
    end
  end
end
