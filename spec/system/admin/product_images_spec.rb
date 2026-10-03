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

  def photo_path
    Spree::Core::Engine.root.join('lib', 'spree', 'testing_support', 'fixtures', 'blank.jpg')
  end

  def upload_photo(alt:)
    click_link 'New Image'
    attach_file 'Filename', photo_path
    fill_in 'Alternative Text', with: alt
    click_button 'Update'
    expect(page).to have_content(I18n.t('spree.successfully_created', resource: Spree::Image.model_name.human))
  end

  def upload_photos(product, alts)
    visit_images_page(product)
    alts.each { |alt| upload_photo(alt: alt) }
  end

  def saved_alts(product)
    Spree::Product.find(product.id).gallery.images.map(&:alt)
  end

  def wait_for_saved_order(product, expected_alts)
    deadline = Time.current + Capybara.default_max_wait_time
    sleep 0.1 until saved_alts(product) == expected_alts || Time.current > deadline
    expect(saved_alts(product)).to eq(expected_alts)
  end

  def thumbnail_alts_on_product_page(product, count:)
    visit product_path(product)
    thumbnails = page.all("[data-js='product-thumbnail'] img", visible: :all, minimum: count)
    thumbnails.map { |thumbnail| thumbnail[:alt] }
  end

  def four_alts
    ['Top of the bowl', 'Side of the bowl', 'Base of the bowl', 'Glaze up close']
  end

  it 'offers New Image as the only way to add a photograph' do
    product = create(:product)
    visit_images_page(product)

    expect(page).to have_link('New Image')
    expect(page).to have_no_css('#upload-zone')
  end

  it 'marks the alternative text field as required' do
    visit_images_page(create(:product))
    click_link 'New Image'

    expect(page).to have_css('textarea#image_alt[required]')
  end

  it 'keeps the photograph only when the seller writes alt text' do
    product = create(:product)
    visit_images_page(product)
    click_link 'New Image'
    attach_file 'Filename', photo_path
    click_button 'Update'

    expect(page).to have_content("Alternative Text can't be blank")
    expect(product.reload.gallery.images).to be_empty
  end

  it 'shows four uploaded photographs on the product page in the order they were added' do
    product = create(:product)
    upload_photos(product, four_alts)

    expect(thumbnail_alts_on_product_page(product, count: 4)).to eq(four_alts)
  end

  it 'saves the order the seller sets by dragging', :js do
    product = create(:product)
    upload_photos(product, four_alts)
    visit spree.admin_product_images_path(product)
    rows = page.all('#images-table tbody tr', count: 4)

    rows.last.find('.handle').drag_to(rows.first.find('.handle'), html5: true)

    expected = [four_alts.last, *four_alts.first(3)]
    wait_for_saved_order(product, expected)
    expect(thumbnail_alts_on_product_page(product, count: 4)).to eq(expected)
  end
end
