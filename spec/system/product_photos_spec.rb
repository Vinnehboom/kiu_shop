require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Browsing a piece\'s photographs', type: :system do
  def create_piece_with_two_photos
    product = create(:product)
    create(:image, viewable: product.master, alt: 'Top view')
    create(:image, viewable: product.master, alt: 'Side view')
    product
  end

  it 'shows the first photograph with its alt text and a link to the large view' do
    product = create_piece_with_two_photos
    visit product_path(product)

    expect(page).to have_css("[data-js='product-main-image'][alt='Top view']")
    expect(page).to have_css("a[data-js='product-main-image-link'] picture img")
  end

  it 'switches the main image alt text and large view link when a thumbnail is clicked', :js do
    product = create_piece_with_two_photos
    side_photo = product.gallery.images.find_by!(alt: 'Side view')
    visit product_path(product)

    find("[data-js='product-thumbnail']:nth-child(2) a").click

    expect(page).to have_css("[data-js='product-main-image'][alt='Side view']")
    expect(page).to have_css("a[data-js='product-main-image-link'][href='#{side_photo.url(:large)}']")
  end
end
