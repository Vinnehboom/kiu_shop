require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Image do
  describe 'alternative text' do
    def build_photo(alt:)
      build(:image, viewable: build(:product).master, alt: alt)
    end

    it 'is required' do
      photo = build_photo(alt: nil)

      expect(photo).not_to be_valid
      expect(photo.errors[:alt]).to be_present
    end

    it 'cannot be blank' do
      expect(build_photo(alt: '  ')).not_to be_valid
    end

    it 'is accepted when the seller writes it' do
      expect(build_photo(alt: 'A celadon bowl seen from above')).to be_valid
    end
  end
end
