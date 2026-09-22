# frozen_string_literal: true

Devise.secret_key = '8386d0f1720bb655d82aa5a95b7c7f5b81a53637ce9b1e0d03e48baa360b9d57b604130ae2d3442b41ee32148bdfb652fff7d91ef78e8e17595cd7913959e46e'
Devise.email_regexp = Spree::Config[:default_email_regexp]
Devise.setup do |config|
  config.parent_controller = 'StoreDeviseController'
  config.mailer = 'UserMailer'
end
