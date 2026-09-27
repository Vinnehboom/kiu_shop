require 'solidus_starter_frontend_spec_helper'

RSpec.describe "A piece's details on its product page", type: :system do
  def visit_piece(attributes = {})
    piece = create(:product, attributes)
    visit product_path(piece)
  end

  it "shows the piece's size, weight, material and safety facts when they are set" do
    visit_piece(
      weight: 0.85, height: 12, width: 9, depth: 9,
      clay: 'Stoneware', glaze: 'Celadon',
      food_safe: true, dishwasher_safe: true
    )

    expect(page).to have_content('0.85')
    expect(page).to have_content('12 x 9 x 9')
    expect(page).to have_content('Stoneware')
    expect(page).to have_content('Celadon')
    expect(page).to have_content('Food safe')
    expect(page).to have_content('Dishwasher safe')
  end

  it 'does not claim facts that were never set' do
    visit_piece(weight: 0, height: nil, width: nil, depth: nil, clay: nil, glaze: nil)

    expect(page).not_to have_content('Weight')
    expect(page).not_to have_content('Dimensions')
    expect(page).not_to have_content('Clay')
    expect(page).not_to have_content('Glaze')
    expect(page).not_to have_content('Food safe')
    expect(page).not_to have_content('Dishwasher safe')
  end
end
