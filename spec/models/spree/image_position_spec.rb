require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Image do
  describe 'moving a photograph' do
    def create_product_with_photos
      product = create(:product)
      photos = Array.new(3) { |index| create(:image, viewable: product.master, alt: "View #{index}") }
      product.update!(updated_at: 1.day.ago)
      [product, photos]
    end

    it 'changes the product timestamp so the cached product page is rebuilt' do
      product, photos = create_product_with_photos
      before = product.reload.updated_at

      photos.last.set_list_position(1)

      expect(product.reload.updated_at).to be > before
    end

    it 'puts a new photograph at the bottom' do
      product, = create_product_with_photos
      newest = create(:image, viewable: product.master, alt: 'Newest')

      expect(product.reload.gallery.images.last).to eq(newest)
    end
  end
end
