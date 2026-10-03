module SolidusStarterFrontend
  module ProductPhotoHelpers
    def create_photo(alt: 'A photograph of the piece')
      create(:image, viewable: create(:product).master, alt: alt)
    end

    def thumbnail_alts
      response.parsed_body.css("[data-js='product-thumbnail'] img").pluck('alt')
    end
  end
end
