shop = Rails.configuration.x.shop

unless Spree::Store.exists?
  ActiveRecord::Base.transaction do
    %w[
      store_credit
      countries
      return_reasons
      states
      stock_locations
      zones
      refund_reasons
      roles
      shipping_categories
    ].each do |seed|
      load Spree::Core::Engine.root.join("db/default/spree/#{seed}.rb")
    end

    ShopSetup::DefaultPermissionSets.new.call
    PotteryShop::StockLocationDefaults.enforce!
    ShopSetup::DefaultStore.new(name: shop.name, url: shop.host, mail_from: shop.mail_from).call
  end
end

ShopSetup::FirstAdmin.new(email: ENV.fetch('ADMIN_EMAIL', nil), password: ENV.fetch('ADMIN_PASSWORD', nil)).call
