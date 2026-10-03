require 'solidus_starter_frontend_spec_helper'

RSpec.describe "A piece's photographs in the admin", type: :system do
  include Warden::Test::Helpers

  after { Warden.test_reset! }

  def sign_in_admin
    admin = create(:admin_user)
    login_as(admin, scope: :spree_user)
  end

  def visit_images_page(product)
    sign_in_admin
    visit spree.admin_product_images_path(product)
  end

  it 'offers New Image as the only way to add a photograph' do
    product = create(:product)
    visit_images_page(product)

    expect(page).to have_link('New Image')
    expect(page).to have_no_css('#upload-zone')
  end
end
