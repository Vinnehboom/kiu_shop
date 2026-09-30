module ShopSetup
  class FirstAdmin
    def initialize(email:, password:)
      @email = email.to_s.strip.downcase
      @password = password
    end

    def call
      return if Spree::User.admin.exists?
      return warn('Set ADMIN_EMAIL and ADMIN_PASSWORD to create the first admin') if credentials_missing?
      return warn('A user with ADMIN_EMAIL exists, so no admin was created') if Spree::User.exists?(email: email)

      create_admin
    end

    private

    attr_reader :email, :password

    def credentials_missing?
      email.blank? || password.blank?
    end

    def create_admin
      admin = Spree::User.new(email: email, password: password, password_confirmation: password)
      return warn_invalid(admin) unless admin.save

      admin.spree_roles << Spree::Role.find_or_create_by!(name: 'admin')
      admin.generate_spree_api_key!
    end

    def warn_invalid(admin)
      warn("The first admin was not created: #{admin.errors.full_messages.to_sentence}")
    end
  end
end
