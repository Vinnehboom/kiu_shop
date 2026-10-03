require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Photo sizes', type: :request do
  include SolidusStarterFrontend::ProductPhotoHelpers

  it 'redirects a size path to the stored file' do
    get create_photo.url(:small)

    expect(response).to have_http_status(:redirect)
  end
end
