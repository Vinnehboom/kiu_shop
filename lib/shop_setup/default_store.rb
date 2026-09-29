module ShopSetup
  class DefaultStore
    def initialize(name:, url:, mail_from:)
      @name = name
      @url = url
      @mail_from = mail_from
    end

    def call
      return if Spree::Store.exists?

      Spree::Store.create!(
        name: name,
        code: name.to_s.parameterize,
        url: url,
        mail_from_address: mail_from
      )
    end

    private

    attr_reader :name, :url, :mail_from
  end
end
