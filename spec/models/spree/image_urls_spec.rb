require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Image do
  include SolidusStarterFrontend::ProductPhotoHelpers

  describe '#url' do
    it 'serves each size from a stable path in the app' do
      photo = create_photo

      %i[small product large].each do |size|
        expect(photo.url(size)).to start_with('/rails/active_storage/representations/')
      end
    end

    it 'gives the same path to a fresh copy of the record' do
      photo = create_photo

      expect(described_class.find(photo.id).url(:product)).to eq(photo.url(:product))
    end

    it 'gives a different path for each size' do
      photo = create_photo
      paths = %i[small product large].map { |size| photo.url(size) }

      expect(paths.uniq.size).to eq(3)
    end

    it 'falls back to the placeholder when the file is missing' do
      photo = create_photo
      photo.attachment.blob.service.delete(photo.attachment.blob.key)

      expect(photo.reload.url(:large)).to eq('noimage/large.png')
    end
  end
end
