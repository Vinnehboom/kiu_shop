require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Product photographs', type: :request do
  include SolidusStarterFrontend::ProductPhotoHelpers

  def create_product_with_photos(*alts)
    product = create(:product)
    alts.each { |alt| create(:image, viewable: product.master, alt: alt) }
    product
  end

  def move_photo(product, alt, position)
    product.master.images.find_by!(alt: alt).set_list_position(position)
  end

  it 'lists the thumbnails in the order the seller set' do
    product = create_product_with_photos('Third view', 'First view', 'Second view')
    move_photo(product, 'Third view', 3)

    get product_path(product)

    expect(thumbnail_alts).to eq(['First view', 'Second view', 'Third view'])
  end

  it 'shows the first photograph in the main image with its alt text' do
    product = create_product_with_photos('Side view', 'Top view')
    move_photo(product, 'Top view', 1)

    get product_path(product)

    main = response.parsed_body.at_css("[data-js='product-main-image']")
    expect(main['alt']).to eq('Top view')
  end

  it 'links the main image to the large size of the first photograph' do
    product = create_product_with_photos('Side view', 'Top view')
    move_photo(product, 'Top view', 1)

    get product_path(product)

    link = response.parsed_body.at_css("a[data-js='product-main-image-link']")
    expect(link['href']).to eq(product.gallery.images.first.url(:large))
  end

  it 'gives each thumbnail its large size and alt text for the page script' do
    product = create_product_with_photos('Top view')

    get product_path(product)

    thumbnail = response.parsed_body.at_css("[data-js='product-thumbnail'] a")
    expect(thumbnail['data-large-url']).to eq(product.gallery.images.first.url(:large))
    expect(thumbnail['data-alt']).to eq('Top view')
  end
end
