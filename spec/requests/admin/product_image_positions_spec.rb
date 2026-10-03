require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Setting the order of a piece\'s photographs', type: :request do
  include SolidusStarterFrontend::ProductPhotoHelpers

  def create_product_with_four_photos
    product = create(:product)
    photos = %w[First Second Third Fourth].map do |name|
      create(:image, viewable: product.master, alt: "#{name} view")
    end
    [product, photos]
  end

  def save_order(product, photos)
    positions = photos.each_with_index.to_h { |photo, index| [photo.id, index + 1] }
    post spree.update_positions_admin_product_images_path(product), params: { positions: positions }, xhr: true
  end

  before do
    sign_in create(:admin_user), scope: :spree_user
  end

  it 'saves the new order' do
    product, photos = create_product_with_four_photos

    save_order(product, photos.reverse)

    expect(response).to have_http_status(:no_content)
    expect(product.reload.gallery.images.map(&:alt))
      .to eq(['Fourth view', 'Third view', 'Second view', 'First view'])
  end

  it 'shows the photographs on the product page in the new order' do
    product, photos = create_product_with_four_photos
    save_order(product, photos.reverse)

    get product_path(product)

    expect(thumbnail_alts).to eq(['Fourth view', 'Third view', 'Second view', 'First view'])
  end
end
