require 'solidus_starter_frontend_spec_helper'

RSpec.describe "Editing a piece's details in the admin", type: :system do
  include Warden::Test::Helpers

  after { Warden.test_reset! }

  def sign_in_admin
    admin = create(:admin_user)
    login_as(admin, scope: :spree_user)
  end

  def edit_piece(product)
    sign_in_admin
    visit spree.edit_admin_product_path(product)

    fill_in 'Weight', with: '0.85'
    fill_in 'Height', with: '12'
    fill_in 'Width', with: '9'
    fill_in 'Depth', with: '9'
    fill_in 'Clay', with: 'Stoneware'
    fill_in 'Glaze', with: 'Celadon'
    check 'Food safe'
    check 'Dishwasher safe'
    click_button 'Update'
  end

  it "saves the piece's size and weight" do
    product = create(:product)
    edit_piece(product)
    product.reload

    expect(product.weight).to eq(0.85)
    expect(product.height).to eq(12)
    expect(product.width).to eq(9)
    expect(product.depth).to eq(9)
  end

  it "saves the piece's material and safety facts" do
    product = create(:product)
    edit_piece(product)
    product.reload

    expect(product.clay).to eq('Stoneware')
    expect(product.glaze).to eq('Celadon')
    expect(product.food_safe).to be(true)
    expect(product.dishwasher_safe).to be(true)
  end
end
