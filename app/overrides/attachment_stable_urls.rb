module AttachmentStableUrls
  def url(style = nil)
    Rails.application.routes.url_helpers.rails_representation_path(variant(style), only_path: true)
  end

  Spree::ActiveStorageAdapter::Attachment.prepend self
end
